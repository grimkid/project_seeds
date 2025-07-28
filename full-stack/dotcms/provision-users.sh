#!/bin/bash

DOTCMS_URL="https://192.168.88.32:8086"
ADMIN_USER="admin@dotcms.com"
ADMIN_PASS="7e2e1b2c-2e2e-4e2e-8e2e-2e2e2e2e2e2e"  # update if needed

USERS=(
  "rares@local.com"
  "seby@local.com"
  "mihai@keydigital.com"
  "admin@renar.ro"
)
PASSWORD="admin"

# Log in as admin and get session cookie
COOKIE_JAR="dotcms_cookie.txt"
LOGIN_RESPONSE=$(curl -k -s -c $COOKIE_JAR -X POST "$DOTCMS_URL/api/v1/authentication" \
  -H "Content-Type: application/json" \
  -H "DNT: 1" \
  -d "{\"userId\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\",\"rememberMe\":false,\"language\":\"en\",\"country\":\"US\",\"backEndLogin\":true}")

ADMIN_EMAIL_FOUND=$(echo "$LOGIN_RESPONSE" | jq -r 'try .entity.emailAddress // empty')
echo "LOGIN_RESPONSE: $LOGIN_RESPONSE"
echo "ADMIN_EMAIL_FOUND: $ADMIN_EMAIL_FOUND"
if [[ "$ADMIN_EMAIL_FOUND" != "$ADMIN_USER" ]]; then
  echo "Admin login failed. Response: $LOGIN_RESPONSE"
  exit 1
fi

# Assign only key backend/admin roles
ROLE_KEYS=("CMS_ADMIN" "BACKEND_USER" "ADMIN")
for EMAIL in "${USERS[@]}"; do

  # Check if user exists
  USER_ID=$(curl -k -s -b $COOKIE_JAR "$DOTCMS_URL/api/v1/user/email/$EMAIL" | jq -r 'try .entity.userId // empty')
  if [[ -n "$USER_ID" ]]; then
    echo "User $EMAIL exists. Deleting..."
    DELETE_RESPONSE=$(curl -k -s -w "%{http_code}" -o delete_user_resp.txt -b $COOKIE_JAR -X DELETE "$DOTCMS_URL/api/v1/users/$USER_ID")
    DELETE_BODY=$(cat delete_user_resp.txt)
    if [[ $DELETE_RESPONSE != "200" && $DELETE_RESPONSE != "204" ]]; then
      echo "Failed to delete $EMAIL. HTTP $DELETE_RESPONSE. Response: $DELETE_BODY"
      continue
    fi
    echo "Deleted $EMAIL."
  fi

  # Create user and check response
  CREATE_RESPONSE=$(curl -k -s -w "%{http_code}" -o create_user_resp.txt -b $COOKIE_JAR -X POST "$DOTCMS_URL/api/v1/users" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"firstName\":\"${EMAIL%%@*}\",\"lastName\":\"User\"}")
  CREATE_BODY=$(cat create_user_resp.txt)
  if [[ $CREATE_RESPONSE != "200" && $CREATE_RESPONSE != "201" ]]; then
    echo "Failed to create $EMAIL. HTTP $CREATE_RESPONSE. Response: $CREATE_BODY"
    continue
  fi

  for ROLE_KEY in "${ROLE_KEYS[@]}"; do
    ROLE_ID=$(curl -k -s -b $COOKIE_JAR "$DOTCMS_URL/api/v1/role" | jq -r --arg key "$ROLE_KEY" '.entity[] | select(.roleKey==$key) | .id')
    if [[ -n "$ROLE_ID" ]]; then
      ASSIGN_RESPONSE=$(curl -k -s -w "%{http_code}" -o assign_role_resp.txt -b $COOKIE_JAR -X POST "$DOTCMS_URL/api/v1/role/$ROLE_ID/user/$EMAIL")
      ASSIGN_BODY=$(cat assign_role_resp.txt)
      if [[ $ASSIGN_RESPONSE != "200" && $ASSIGN_RESPONSE != "201" ]]; then
        echo "Failed to assign role $ROLE_KEY ($ROLE_ID) to $EMAIL. HTTP $ASSIGN_RESPONSE. Response: $ASSIGN_BODY"
      fi
    fi
  done

  echo "Provisioned $EMAIL with roles: ${ROLE_KEYS[*]}."
done

rm -f $COOKIE_JAR
rm -f create_user_resp.txt assign_role_resp.txt
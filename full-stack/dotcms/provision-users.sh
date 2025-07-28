#!/bin/bash

DOTCMS_URL="https://dotcms-app:8443"
ADMIN_USER="admin@dotcms.com"
ADMIN_PASS="7e2e1b2c-2e2e-4e2e-8e2e-2e2e2e2e2e2e"  # update if needed

USERS=(
  "rares@local.com"
  "seby@local.com"
  "mihai@keydigital.com"
  "user@local.com"
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

# Fetch all users via DWR endpoint and build email->userId map
echo "[INFO] Fetching user list from DWR endpoint..."
DWR_PAYLOAD=$'callCount=1\nwindowName=c0-param2\nc0-scriptName=UserAjax\nc0-methodName=getUsersList\nc0-id=0\nc0-param0=null:null\nc0-param1=null:null\nc0-e1=number:0\nc0-e2=number:1000\nc0-e3=boolean:false\nc0-param2=Object_Object:{start:reference:c0-e1, limit:reference:c0-e2, includeDefault:reference:c0-e3}\nbatchId=2\ninstanceId=0\npage=%2Fc%2Fportal%2Flayout\nscriptSessionId=xxxxxx\n'
DWR_USERS=$(curl -k -s -b $COOKIE_JAR -X POST "$DOTCMS_URL/dwr/call/plaincall/UserAjax.getUsersList.dwr" \
  -H "Content-Type: text/plain" \
  --data-raw "$DWR_PAYLOAD")
echo "[DEBUG] DWR_USERS: $DWR_USERS"

# Parse DWR response: extract userId and email for each user
declare -A EMAIL_TO_USERID
while read -r line; do
  # Look for lines like: s0[0].userId="dotcms.org.2"; s0[0].email="rares@local.com";
  if [[ $line =~ userId=\"([^"]+)\" ]]; then
    uid="${BASH_REMATCH[1]}"
  fi
  if [[ $line =~ email=\"([^"]+)\" ]]; then
    em="${BASH_REMATCH[1]}"
    EMAIL_TO_USERID[$em]="$uid"
  fi
done < <(echo "$DWR_USERS" | grep -E 'userId=|email=')

for EMAIL in "${USERS[@]}"; do
  USER_ID="${EMAIL_TO_USERID[$EMAIL]}"
  if [[ -z "$USER_ID" ]]; then
    # Try to create user if not found
    CREATE_RESPONSE=$(curl -k -s -w "%{http_code}" -o create_user_resp.txt -b $COOKIE_JAR -X POST "$DOTCMS_URL/api/v1/users" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"firstName\":\"${EMAIL%%@*}\",\"lastName\":\"User\"}")
    CREATE_BODY=$(cat create_user_resp.txt)
    echo "[DEBUG] CREATE_RESPONSE for $EMAIL: $CREATE_RESPONSE"
    echo "[DEBUG] CREATE_BODY for $EMAIL: $CREATE_BODY"
    if [[ $CREATE_RESPONSE != "200" && $CREATE_RESPONSE != "201" ]]; then
      echo "Failed to create $EMAIL. HTTP $CREATE_RESPONSE. Response: $CREATE_BODY"
      continue
    fi
    echo "Created $EMAIL."
    # Fetch user list again to get new userId
    DWR_USERS_NEW=$(curl -k -s -b $COOKIE_JAR -X POST "$DOTCMS_URL/dwr/call/plaincall/UserAjax.getUsersList.dwr" \
      -H "Content-Type: text/plain" \
      --data-raw "$DWR_PAYLOAD")
    while read -r line; do
      if [[ $line =~ userId=\"([^"]+)\" ]]; then
        uid="${BASH_REMATCH[1]}"
      fi
      if [[ $line =~ email=\"([^"]+)\" ]]; then
        em="${BASH_REMATCH[1]}"
        EMAIL_TO_USERID[$em]="$uid"
      fi
    done < <(echo "$DWR_USERS_NEW" | grep -E 'userId=|email=')
    USER_ID="${EMAIL_TO_USERID[$EMAIL]}"
    echo "[DEBUG] USER_ID after creation for $EMAIL: $USER_ID"
    if [[ -z "$USER_ID" ]]; then
      echo "[ERROR] Could not find userId for $EMAIL after creation."
      continue
    fi
  else
    echo "User $EMAIL exists. Will ensure correct roles."
  fi

  # Always check and assign required roles
  for ROLE_KEY in "${ROLE_KEYS[@]}"; do
    ROLE_LOOKUP=$(curl -k -s -b $COOKIE_JAR "$DOTCMS_URL/api/v1/role")
    echo "[DEBUG] ROLE_LOOKUP for $ROLE_KEY: $ROLE_LOOKUP"
    ROLE_ID=$(echo "$ROLE_LOOKUP" | jq -er --arg key "$ROLE_KEY" 'select(type=="object") | .entity[]? | select(.roleKey==$key) | .id' 2>/dev/null || echo "")
    echo "[DEBUG] ROLE_ID for $ROLE_KEY: $ROLE_ID"
    if [[ -n "$ROLE_ID" ]]; then
      # Check if user already has this role
      USER_ROLES=$(curl -k -s -b $COOKIE_JAR "$DOTCMS_URL/api/v1/user/$USER_ID/roles")
      echo "[DEBUG] USER_ROLES for $EMAIL: $USER_ROLES"
      HAS_ROLE=$(echo "$USER_ROLES" | jq -er --arg rid "$ROLE_ID" 'select(type=="object") | .entity[]? | select(.id==$rid)' 2>/dev/null || echo "")
      echo "[DEBUG] HAS_ROLE for $EMAIL and $ROLE_KEY: $HAS_ROLE"
      if [[ -z "$HAS_ROLE" ]]; then
        echo "[DEBUG] Assigning role: curl -k -b $COOKIE_JAR -X POST $DOTCMS_URL/api/v1/role/$ROLE_ID/user/$USER_ID"
        ASSIGN_RESPONSE=$(curl -k -s -w "%{http_code}" -o assign_role_resp.txt -b $COOKIE_JAR -X POST "$DOTCMS_URL/api/v1/role/$ROLE_ID/user/$USER_ID")
        ASSIGN_BODY=$(cat assign_role_resp.txt)
        echo "[DEBUG] Assign role response: HTTP $ASSIGN_RESPONSE, Body: $ASSIGN_BODY"
        if [[ $ASSIGN_RESPONSE != "200" && $ASSIGN_RESPONSE != "201" ]]; then
          echo "Failed to assign role $ROLE_KEY ($ROLE_ID) to $EMAIL. HTTP $ASSIGN_RESPONSE. Response: $ASSIGN_BODY"
        else
          echo "Assigned role $ROLE_KEY to $EMAIL."
        fi
      else
        echo "$EMAIL already has role $ROLE_KEY."
      fi
    else
      echo "[DEBUG] Could not find ROLE_ID for $ROLE_KEY."
    fi
  done

  echo "Provisioned $EMAIL with roles: ${ROLE_KEYS[*]}."
done

rm -f $COOKIE_JAR
rm -f create_user_resp.txt assign_role_resp.txt
#!/bin/bash
# Script to initialize a custom internal Docker network for project_seeds

NETWORK_NAME="internal-net"
SUBNET="172.28.0.0/16"
GATEWAY="172.28.0.1"

# Check if the network already exists
if docker network ls | grep -q "$NETWORK_NAME"; then
  echo "Docker network $NETWORK_NAME already exists."
else
  echo "Creating Docker network $NETWORK_NAME with subnet $SUBNET..."
  docker network create --subnet=$SUBNET --gateway=$GATEWAY $NETWORK_NAME
  echo "Docker network $NETWORK_NAME created."
fi

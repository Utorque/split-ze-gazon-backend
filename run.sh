#!/bin/bash

# Stop and remove the container if it exists (even if it's not running)
docker rm -f game-leaderboard > /dev/null 2>&1

# Pull the latest image
docker pull ghcr.io/utorque/split-ze-gazon-backend:main

# Run the container
docker run -d \
  -p 51201:8000 \
  --name game-leaderboard \
  ghcr.io/utorque/split-ze-gazon-backend:main

# Check if container started successfully
if [ $? -eq 0 ]; then
  echo "Container started successfully! API available at http://localhost:51201"
  echo "Waiting for the service to start..."
  sleep 10
  docker logs game-leaderboard
  echo "Container status:"
  docker ps | grep game-leaderboard
else
  echo "Failed to start container!"
  exit 1
fi
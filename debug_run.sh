#!/bin/bash

# Stop and remove the container if it exists (even if it's not running)
docker rm -f game-leaderboard > /dev/null 2>&1

# Pull the latest image
docker pull ghcr.io/utorque/split-ze-gazon-backend:main

# Run the container
docker run \
  -p 51201:8000 \
  --name game-leaderboard \
  ghcr.io/utorque/split-ze-gazon-backend:main
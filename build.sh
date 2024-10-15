#!/bin/bash

# check profile
if [ -z "$1" ]; then
  echo "Error: No profile provided. Please provide a profile of either duckdb or postgres."
  echo "Usage: bash build.sh PROFILE"
  exit 1
fi

PROFILE=$1

docker compose -f docker/compose.yaml --profile $PROFILE up --build -d
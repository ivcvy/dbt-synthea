#!/bin/bash

# check profile
if [ -z "$1" ] || { [ "$1" != "duckdb" ] && [ "$1" != "postgres" ]; }; then
  echo "Error: Invalid profile provided. Please provide a profile of either duckdb or postgres."
  echo "Usage: bash build.sh PROFILE"
  exit 1
fi

PROFILE=$1

docker compose -f compose.yaml --profile $PROFILE up --build -d
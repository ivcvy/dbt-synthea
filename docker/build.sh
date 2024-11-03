#!/bin/bash

# check profile
if [ -z "$1" ] || { [ "$1" != "duckdb" ] && [ "$1" != "postgres" ]; }; then
  echo "Error: Invalid profile provided. Please provide a profile of either duckdb or postgres."
  echo "Usage: bash build.sh PROFILE"
  exit 1
fi

PROFILE=$1

# save profile and project port in .env
if [ -f .env ]; then
  echo "PROFILE=$PROFILE" > .env
else
  echo "PROFILE=$PROFILE" >> .env
fi

docker network create dbt-synthea-$PROFILE 2> /dev/null
docker compose -f compose.yaml --profile $PROFILE up --build -d

PORT=$(docker port dbt-synthea-$PROFILE 8080 | grep -o '[0-9]*$')

echo "PORT=$PORT" >> .env
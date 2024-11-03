#!/bin/bash

# check profile
if [ -z "$1" ] || { [ "$1" != "duckdb" ] && [ "$1" != "postgres" ]; }; then
  echo "Error: Invalid profile provided. Please provide a profile of either duckdb or postgres."
  echo "Usage: bash build.sh PROFILE"
  exit 1
fi

PROFILE=$1

# find profile and port number in .env
if [ -f .env ] && grep -q "PROFILE=$PROFILE" .env; then
  PORT=$(awk -v profile="PROFILE=$PROFILE" '$0 == profile {getline; print}' .env | grep -o '[0-9]*$')
else
  echo "Error: Profile '$PROFILE' not found in .env."
  exit 1
fi

# echo the host port number
echo "Host port for serving DAG: $PORT"

# Get the full path to the parent directory
PARENT_DIR=$(cd .. && pwd)

if [ "$PROFILE" == "duckdb" ]; then
  docker run -it -p $PORT:8080 --name dbt-synthea-$PROFILE-dbt --mount type=bind,src=$PARENT_DIR,target=/app dbt-synthea-$PROFILE-${PROFILE} /bin/bash
elif [ "$PROFILE" == "postgres" ]; then
  docker run -it -p $PORT:8080 --name dbt-synthea-$PROFILE-dbt \
    --mount type=bind,src=$PARENT_DIR,target=/app \
    --network dbt-synthea-$PROFILE \
    dbt-synthea-$PROFILE-$PROFILE /bin/bash
fi
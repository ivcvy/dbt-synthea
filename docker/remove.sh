#!/bin/bash

# check profile
if [ -z "$1" ] || { [ "$1" != "duckdb" ] && [ "$1" != "postgres" ]; }; then
  echo "Error: Invalid profile provided. Please provide a profile of either duckdb or postgres."
  echo "Usage: bash build.sh PROFILE"
  exit 1
fi

PROFILE=$1

# get id
CONTAINER_ID=$(docker ps -a | grep dbt-synthea-$PROFILE | awk '{print $1}')
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID
docker rmi dbt-synthea-$PROFILE

if [ "$PROFILE" = "postgres" ]; then
  docker rmi postgres:latest
  docker volume rm dbt-synthea_postgres-data
fi
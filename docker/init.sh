#!/bin/bash

# check profile
if [ -z "$1" ] || { [ "$1" != "duckdb" ] && [ "$1" != "postgres" ]; }; then
  echo "Error: Invalid profile provided. Please provide a profile of either duckdb or postgres."
  echo "Usage: bash build.sh PROFILE"
  exit 1
fi

PROFILE=$1

# environment
python -m venv /dbt-env
if [ "$PROFILE" = "duckdb" ]; then
    /dbt-env/bin/pip install --no-cache-dir -r /app/requirements/duckdb.txt
elif [ "$PROFILE" = "postgres" ]; then
    /dbt-env/bin/pip install --no-cache-dir -r /app/requirements/postgres.txt
fi

source ../../dbt-env/bin/activate

# dbt
mkdir -p /root/.dbt
if [ "$PROFILE" = "duckdb" ]; then
    cat <<EOF > /root/.dbt/profiles.yml
synthea_omop_etl:
  outputs:
    dev:
      type: duckdb
      path: synthea_omop_etl.duckdb
      schema: dbt_synthea_dev
  target: dev
EOF
elif [ "$PROFILE" = "postgres" ]; then
  cat <<EOF > /root/.dbt/profiles.yml
synthea_omop_etl:
  outputs:
    dev:
      dbname: postgres
      host: db
      user: postgres
      password: postgres
      port: 5432
      schema: dbt_synthea_dev
      threads: 4
      type: postgres
  target: dev
EOF
fi

# pre-commit
cp ../.pre-commit-config.yaml ../../
git init
pre-commit install

# test
dbt debug
dbt deps
dbt seed
dbt build

# find profile and port number in .env
if [ -f .env ] && grep -q "PROFILE=$PROFILE" .env; then
  PORT=$(awk -v profile="PROFILE=$PROFILE" '$0 == profile {getline; print}' .env | grep -o '[0-9]*$')
else
  echo "Error: Profile '$PROFILE' not found in .env."
  exit 1
fi

dbt docs generate
dbt docs serve --host 0.0.0.0 --port $PORT
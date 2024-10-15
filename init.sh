#!/bin/bash

# check profile
if [ -z "$1" ]; then
  echo "Error: No profile provided. Please provide a profile of either duckdb or postgres."
  echo "Usage: bash build.sh PROFILE"
  exit 1
fi

PROFILE=$1

# environment
python -m venv /dbt-env
if [ "$PROFILE" = "duckdb" ]; then
    /dbt-env/bin/pip install --no-cache-dir -r /app/requirements/duckdb.txt
fi
source ../dbt-env/bin/activate

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
fi

# pre-commit
mv .pre-commit-config.yaml ..
git init
pre-commit install

# test
dbt debug
dbt deps
dbt seed
dbt seed --select states omop
dbt build
pre-commit run --all-files
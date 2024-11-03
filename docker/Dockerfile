FROM python:3.10-slim-bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends git postgresql-client libpq-dev build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
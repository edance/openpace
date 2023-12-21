#!/bin/bash
# Docker entrypoint script.

cd $(dirname $0)/..
export APP_DIR=$(pwd)
export ASSETS_DIR=${APP_DIR}/assets
export PYTHON_DIR=${APP_DIR}/priv/python

# Install new dependencies
mix deps.get

# Install python libraries - used for load FIT files
cd ${PYTHON_DIR}
pip3 install -r requirements.txt
cd ${APP_DIR}

# Wait until Postgres is ready
while ! pg_isready -q -h $POSTGRES_HOST -p 5432 -U $POSTGRES_USER
do
    echo "$(date) - waiting for database to start."
    sleep 2
done

# Create and migrate database
mix ecto.create
mix ecto.migrate

# Install node_modules
cd ${ASSETS_DIR}
bun install
cd ${APP_DIR}

echo "Starting Phoenix server..."
exec mix phx.server

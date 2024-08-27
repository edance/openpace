#!/bin/bash

# Function to kill all background processes
cleanup() {
    echo "Cleaning up..."
    kill $(jobs -p)
    exit
}

# Set up trap to catch SIGINT (Ctrl+C)
trap cleanup SIGINT

# Using fly.io proxy to the database
fly proxy 65432:5432 -a purple-feather-6656 &

# Run the jar file of the metabase dashboard
# Requires the jar file to be in the ~/metabase directory
cd ~/metabase
export MB_JETTY_PORT=8000
java -jar metabase.jar &

# Open the browser to the dashboard
open http://localhost:8000

# Wait for all background processes to finish
wait

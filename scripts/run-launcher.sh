#!/bin/bash

# Either just run this script without arguments
# or with --ghuser and --ghtoken arguments to
# run both the Launcher backend and frontend.

# Run with "stop" as its only argument to stop
# and remove the docker containers

if [[ "$1" == "stop" ]]; then
    docker rm -f launcher-backend
    docker rm -f launcher-frontend
    exit
fi

# Get the docker scripts to run the backend and the frontend
[[ ! -f /tmp/run-launcher-backend.sh ]] && wget -O /tmp/run-launcher-backend.sh https://raw.githubusercontent.com/fabric8-launcher/launcher-backend/master/docker.sh
[[ ! -f /tmp/run-launcher-frontend.sh ]] && wget -O /tmp/run-launcher-frontend.sh https://raw.githubusercontent.com/fabric8-launcher/launcher-frontend/master/docker.sh

# Make sure the docker images are up-to-date
docker pull fabric8/launcher-backend
docker pull fabric8/launcher-frontend

# Run the backend and frontend
bash /tmp/run-launcher-backend.sh -td --run --net "$@"
bash /tmp/run-launcher-frontend.sh -td --run --net


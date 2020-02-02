#!/bin/bash
set -eE

DOCKER_TIMEOUT=30
DOCKER_PID=0


function start_docker() {
    local starttime
    local endtime

    echo "Starting docker."
    dockerd 2> /dev/null &
    DOCKER_PID=$!

    echo "Waiting for docker to initialize..."
    starttime="$(date +%s)"
    endtime="$(date +%s)"
    until docker info >/dev/null 2>&1; do
        if [ $((endtime - starttime)) -le $DOCKER_TIMEOUT ]; then
            sleep 1
            endtime=$(date +%s)
        else
            echo "Timeout while waiting for docker to come up"
            exit 1
        fi
    done
    echo "Docker was initialized"
}


function stop_docker() {
    local starttime
    local endtime

    echo "Stopping in container docker..."
    if [ "$DOCKER_PID" -gt 0 ] && kill -0 "$DOCKER_PID" 2> /dev/null; then
        starttime="$(date +%s)"
        endtime="$(date +%s)"

        # Now wait for it to die
        kill "$DOCKER_PID"
        while kill -0 "$DOCKER_PID" 2> /dev/null; do
            if [ $((endtime - starttime)) -le $DOCKER_TIMEOUT ]; then
                sleep 1
                endtime=$(date +%s)
            else
                echo "Timeout while waiting for container docker to die"
                exit 1
            fi
        done
    else
        echo "Your host might have been left with unreleased resources"
    fi
}


function install() {
    docker pull homeassistant/amd64-hassio-supervisor:dev
    docker pull homeassistant/amd64-hassio-cli:dev
}

function cleanup_hass_data() {
    rm -rf /workspaces/test_hassio/{apparmor,backup,config.json,dns,dns.json,homeassistant,homeassistant.json,ingress.json,share,ssl,tmp,updater.json}
    rm -rf /workspaces/test_hassio/addons/{core,data,git}
}

function cleanup_docker() {
    echo "Cleaning up stopped containers..."
    docker rm $(docker ps -a -q)
}

function run_supervisor() {
    docker run --rm --privileged \
        --name hassio_supervisor \
        --security-opt seccomp=unconfined \
        --security-opt apparmor:unconfined \
        -v /run/docker.sock:/run/docker.sock \
        -v /run/dbus:/run/dbus \
        -v "/workspaces/test_hassio":/data \
        -v /etc/machine-id:/etc/machine-id:ro \
        -e SUPERVISOR_SHARE="/workspaces/test_hassio" \
        -e SUPERVISOR_NAME=hassio_supervisor \
        -e SUPERVISOR_DEV=1 \
        -e HOMEASSISTANT_REPOSITORY="homeassistant/qemux86-64-homeassistant" \
        homeassistant/amd64-hassio-supervisor:dev
}

case "$1" in
    "--cleanup")
        echo "Cleaning up old environment"
        cleanup_docker
        cleanup_hass_data
        exit 0;;
    *)
        echo "Creating development Hass.io environment"
        start_docker
        trap "stop_docker" ERR
        install
        cleanup_docker
        run_supervisor
        stop_docker;; 
esac
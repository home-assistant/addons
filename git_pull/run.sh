#!/bin/bash

#### config ####

CONFIG_PATH=/data/options.json

DEPLOYMENT_KEY=$(jq --raw-output ".deployment_key[]" $CONFIG_PATH)
DEPLOYMENT_KEY_PROTOCOL=$(jq --raw-output ".deployment_key_protocol" $CONFIG_PATH)
REPOSITORY=$(jq --raw-output '.repository' $CONFIG_PATH)
AUTO_RESTART=$(jq --raw-output '.auto_restart' $CONFIG_PATH)
REPEAT_ACTIVE=$(jq --raw-output '.repeat.active' $CONFIG_PATH)
REPEAT_INTERVAL=$(jq --raw-output '.repeat.interval' $CONFIG_PATH)
################

#### functions ####
function add-ssh-key {
    echo "Start adding SSH key"
    mkdir -p ~/.ssh

    echo "Host *" > ~/.ssh/config
    echo "    StrictHostKeyChecking no" >> ~/.ssh/config

    echo "Setup deployment_key on id_${DEPLOYMENT_KEY_PROTOCOL}"
    while read -r line; do
        echo "$line" >> "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
    done <<< "$DEPLOYMENT_KEY"

    chmod 600 "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
}

function git-clone {
    # back to main folder
    cd ..

    # create backup
    BACKUP_LOCATION="./tmp/config-$(date +%Y-%m-%d_%H-%M-%S)"
    echo "Backup configuration to $BACKUP_LOCATION"
    
    mkdir "${BACKUP_LOCATION}" || { echo "[Error] Creation of backup directory failed"; exit 1; }
    cp -rf config/* "${BACKUP_LOCATION}" || { echo "[Error] Copy files to backup directory failed"; exit 1; }
    
    # remove config folder content
    rm -rf config/{,.[!.],..?}* || { echo "[Error] Clearing /config failed"; exit 1; }

    # git clone
    echo "Start git clone"
    git clone "$REPOSITORY" ./config || { echo "[Error] Git clone failed"; exit 1; }

    # try to copy non yml files back
    cp "${BACKUP_LOCATION}" "!(*.yaml)" /config 2>/dev/null

    # try to copy secrets file back
    cp "${BACKUP_LOCATION}/secrets.yaml" /config 2>/dev/null

    cd config
}

function check-ssh-key {
if [ -n DEPLOYMENT_KEY ]; then
    echo "Check SSH connection"
    IFS=':' read -ra GIT_URL_PARTS <<< "$REPOSITORY"
    ssh -T -o "BatchMode=yes" "${GIT_URL_PARTS[0]}"
    if [ $? -eq 0 ]; then
        echo "Valid SSH connection for ${GIT_URL_PARTS[0]}"
    else
        echo "No valid SSH connection for ${GIT_URL_PARTS[0]}"
        add-ssh-key
    fi
fi
}

function git-synchronize {
    inside_git_repo="$(git rev-parse --is-inside-git-dir 2>/dev/null)"
    if [ $? -eq 0 ]; then
        echo "git repository exists, start pulling"
        OLD_COMMIT=$(git rev-parse HEAD)
        git pull || { echo "[Error] Git pull failed"; exit 1; }
    else
        echo "git repostory doesn't exist"
        git-clone
    fi
}

function validate-config {
    echo "[Info] Check if something is changed"
    if [ "$AUTO_RESTART" == "true" ]; then
        # Compare commit ids & check config
        NEW_COMMIT=$(git rev-parse HEAD)
        if [ "$NEW_COMMIT" != "$OLD_COMMIT" ]; then
            echo "[Info] check Home-Assistant config"
            if api_ret="$(curl -s -X POST http://hassio/homeassistant/check)"; then
                result="$(echo "$api_ret" | jq --raw-output ".result")"

                # Config is valid
                if [ "$result" != "error" ]; then
                    echo "[Info] restart Home-Assistant"
                    curl -s -X POST http://hassio/homeassistant/restart 2&> /dev/null || true
                else
                    echo "[Error] invalid config!"
                fi
            fi
        else
            echo "[Info] Nothing has changed."
        fi
    fi
}

###################

#### Main program ####
cd /config
while true; do
    check-ssh-key
    git-synchronize
    validate-config
     # do we repeat?
    if [ -z "$REPEAT_ACTIVE" ]; then
        exit 0
    fi
    sleep "$REPEAT_INTERVAL"
done

###################

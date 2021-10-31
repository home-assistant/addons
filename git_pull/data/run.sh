#!/bin/bash

#### config ####

CONFIG_PATH=/data/options.json

DEPLOYMENT_KEY=$(jq --raw-output ".deployment_key[]" $CONFIG_PATH)
DEPLOYMENT_KEY_PROTOCOL=$(jq --raw-output ".deployment_key_protocol" $CONFIG_PATH)
DEPLOYMENT_USER=$(jq --raw-output ".deployment_user" $CONFIG_PATH)
DEPLOYMENT_PASSWORD=$(jq --raw-output ".deployment_password" $CONFIG_PATH)
GIT_BRANCH=$(jq --raw-output '.git_branch' $CONFIG_PATH)
GIT_COMMAND=$(jq --raw-output '.git_command' $CONFIG_PATH)
GIT_REMOTE=$(jq --raw-output '.git_remote' $CONFIG_PATH)
GIT_PRUNE=$(jq --raw-output '.git_prune' $CONFIG_PATH)
REPOSITORY=$(jq --raw-output '.repository' $CONFIG_PATH)
AUTO_RESTART=$(jq --raw-output '.auto_restart' $CONFIG_PATH)
RESTART_IGNORED_FILES=$(jq --raw-output '.restart_ignore | join(" ")' $CONFIG_PATH)
REPEAT_ACTIVE=$(jq --raw-output '.repeat.active' $CONFIG_PATH)
REPEAT_INTERVAL=$(jq --raw-output '.repeat.interval' $CONFIG_PATH)
GH_ACTIONS_ENABLE=$(jq --raw-output '.github_action_check' $CONFIG_PATH)
GH_USERNAME=$(jq --raw-output '.github_username' $CONFIG_PATH)
GH_REPO=$(jq --raw-output '.github_repository' $CONFIG_PATH)
GH_TOKEN=$(jq --raw-output '.github_repository' $CONFIG_PATH)
GH_ACTION_NAME=$(jq --raw-output '.github_action_name' $CONFIG_PATH)
################

#### functions ####
function add-ssh-key {
    echo "[Info] Start adding SSH key"
    mkdir -p ~/.ssh

    (
        echo "Host *"
        echo "    StrictHostKeyChecking no"
    ) > ~/.ssh/config

    echo "[Info] Setup deployment_key on id_${DEPLOYMENT_KEY_PROTOCOL}"
    rm -f "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
    while read -r line; do
        echo "$line" >> "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
    done <<< "$DEPLOYMENT_KEY"

    chmod 600 "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
}

function git-clone {
    # create backup
    BACKUP_LOCATION="/tmp/config-$(date +%Y-%m-%d_%H-%M-%S)"
    echo "[Info] Backup configuration to $BACKUP_LOCATION"

    mkdir "${BACKUP_LOCATION}" || { echo "[Error] Creation of backup directory failed"; exit 1; }
    cp -rf /config/* "${BACKUP_LOCATION}" || { echo "[Error] Copy files to backup directory failed"; exit 1; }

    # remove config folder content
    rm -rf /config/{,.[!.],..?}* || { echo "[Error] Clearing /config failed"; exit 1; }

    # git clone
    echo "[Info] Start git clone"
    git clone "$REPOSITORY" /config || { echo "[Error] Git clone failed"; exit 1; }

    # try to copy non yml files back
    cp "${BACKUP_LOCATION}" "!(*.yaml)" /config 2>/dev/null

    # try to copy secrets file back
    cp "${BACKUP_LOCATION}/secrets.yaml" /config 2>/dev/null
}

function check-ssh-key {
if [ -n "$DEPLOYMENT_KEY" ]; then
    echo "Check SSH connection"
    IFS=':' read -ra GIT_URL_PARTS <<< "$REPOSITORY"
    # shellcheck disable=SC2029
    DOMAIN="${GIT_URL_PARTS[0]}"
    if OUTPUT_CHECK=$(ssh -T -o "StrictHostKeyChecking=no" -o "BatchMode=yes" "$DOMAIN" 2>&1) || { [[ $DOMAIN = *"@github.com"* ]] && [[ $OUTPUT_CHECK = *"You've successfully authenticated"* ]]; }; then
        echo "[Info] Valid SSH connection for $DOMAIN"
    else
        echo "[Warn] No valid SSH connection for $DOMAIN"
        add-ssh-key
    fi
fi
}

function setup-user-password {
if [ -n "$DEPLOYMENT_USER" ]; then
    cd /config || return
    echo "[Info] setting up credential.helper for user: ${DEPLOYMENT_USER}"
    git config --system credential.helper 'store --file=/tmp/git-credentials'

    # Extract the hostname from repository
    h="$REPOSITORY"

    # Extract the protocol
    proto=${h%%://*}

    # Strip the protocol
    h="${h#*://}"

    # Strip username and password from URL
    h="${h#*:*@}"
    h="${h#*@}"

    # Strip the tail of the URL
    h=${h%%/*}

    # Format the input for git credential commands
    cred_data="\
protocol=${proto}
host=${h}
username=${DEPLOYMENT_USER}
password=${DEPLOYMENT_PASSWORD}
"

    # Use git commands to write the credentials to ~/.git-credentials
    echo "[Info] Saving git credentials to /tmp/git-credentials"
    # shellcheck disable=SC2259
    git credential fill | git credential approve <<< "$cred_data"
fi
}

function git-synchronize {
    # is /config a local git repo?
    if git rev-parse --is-inside-work-tree &>/dev/null
    then
        echo "[Info] Local git repository exists"

        # Is the local repo set to the correct origin?
        CURRENTGITREMOTEURL=$(git remote get-url --all "$GIT_REMOTE" | head -n 1)
        if [ "$CURRENTGITREMOTEURL" = "$REPOSITORY" ]
        then
            echo "[Info] Git origin is correctly set to $REPOSITORY"
            OLD_COMMIT=$(git rev-parse HEAD)

            # Always do a fetch to update repos
            echo "[Info] Start git fetch..."
            git fetch "$GIT_REMOTE" || { echo "[Error] Git fetch failed"; return 1; }

            # Prune if configured
            if [ "$GIT_PRUNE" == "true" ]
            then
              echo "[Info] Start git prune..."
              git prune || { echo "[Error] Git prune failed"; return 1; }
            fi

            # Do we switch branches?
            GIT_CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
            if [ -z "$GIT_BRANCH" ] || [ "$GIT_BRANCH" == "$GIT_CURRENT_BRANCH" ]; then
              echo "[Info] Staying on currently checked out branch: $GIT_CURRENT_BRANCH..."
            else
              echo "[Info] Switching branches - start git checkout of branch $GIT_BRANCH..."
              git checkout "$GIT_BRANCH" || { echo "[Error] Git checkout failed"; exit 1; }
              GIT_CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
            fi

            gh-actions || { echo "[Error] GitHub actions check failed"; return 1; }

            # Pull or reset depending on user preference
            case "$GIT_COMMAND" in
                pull)
                    echo "[Info] Start git pull..."
                    git pull || { echo "[Error] Git pull failed"; return 1; }
                    ;;
                reset)
                    echo "[Info] Start git reset..."
                    git reset --hard "$GIT_REMOTE"/"$GIT_CURRENT_BRANCH" || { echo "[Error] Git reset failed"; return 1; }
                    ;;
                *)
                    echo "[Error] Git command is not set correctly. Should be either 'reset' or 'pull'"
                    exit 1
                    ;;
            esac
        else
            echo "[Error] git origin does not match $REPOSITORY!"; exit 1;
        fi

    else
        echo "[Warn] Git repository doesn't exist"
        git-clone
    fi
}

function validate-config {
    echo "[Info] Checking if something has changed..."
    # Compare commit ids & check config
    NEW_COMMIT=$(git rev-parse HEAD)
    if [ "$NEW_COMMIT" != "$OLD_COMMIT" ]; then
        echo "[Info] Something has changed, checking Home-Assistant config..."
        if ha --no-progress core check; then
            if [ "$AUTO_RESTART" == "true" ]; then
                DO_RESTART="false"
                CHANGED_FILES=$(git diff "$OLD_COMMIT" "$NEW_COMMIT" --name-only)
                echo "Changed Files: $CHANGED_FILES"
                if [ -n "$RESTART_IGNORED_FILES" ]; then
                    for changed_file in $CHANGED_FILES; do
                        restart_required_file=""
                        for restart_ignored_file in $RESTART_IGNORED_FILES; do
                            if [ -d "$restart_ignored_file" ]; then
                                # file to be ignored is a whole dir
                                restart_required_file=$(echo "${changed_file}" | grep "^${restart_ignored_file}")
                            else
                                restart_required_file=$(echo "${changed_file}" | grep "^${restart_ignored_file}$")
                            fi
                            # break on first match
                            if [ -n "$restart_required_file" ]; then break; fi
                        done
                        if [ -z "$restart_required_file" ]; then
                            DO_RESTART="true"
                            echo "[Info] Detected restart-required file: $changed_file"
                        fi
                    done
                else
                    DO_RESTART="true"
                fi
                if [ "$DO_RESTART" == "true" ]; then
                    echo "[Info] Restart Home-Assistant"
                    ha --no-progress core restart 2&> /dev/null
                else
                    echo "[Info] No Restart Required, only ignored changes detected"
                fi
            else
                echo "[Info] Local configuration has changed. Restart required."
            fi
        else
            echo "[Error] Configuration updated but it does not pass the config check. Do not restart until this is fixed!"
        fi
    else
        echo "[Info] Nothing has changed."
    fi
}

function gh-actions {
    echo "[Info] Checking if GitHub actions check enabled..."
    if [ "$GH_ACTIONS_ENABLE" == "true" ]; then
        echo "[Info] GitHub actions check enabled. Checking if GitHub action passed..."

        GITHUB_API_RESPONSE=$(curl -u $GH_USERNAME:$GH_TOKEN -s \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$GH_USERNAME/$GH_REPO/actions/runs?branch="$GIT_BRANCH")

        if [[ $(jq -r '.message' <<< "$GITHUB_API_RESPONSE" ) == "Not Found" ]]; then
            echo "[Error] Not found GitHub repository. If you are using private repository add token to configuration."
            return 1
        fi

        if (( $(jq -r '.total_count'  <<< "$GITHUB_API_RESPONSE") == 0 )); then
            echo "[Error] not found any GitHub actions for branch $GIT_BRANCH"
            return 1;
        fi

        REMOTE_SHA=$(git rev-parse origin/${GIT_BRANCH})

        GITHUB_LAST_ACTION=$(jq -c '[ .workflow_runs[] | select( (.head_sha == "'"$REMOTE_SHA"'")) ]' <<< "$GITHUB_API_RESPONSE")

        if [[ "$GITHUB_LAST_ACTION" == "[]" ]]
        then
            echo "[Error] Not found GitHub action run on the last git commit on branch $GIT_BRANCH"
            return 1
        fi

        if [ ! -z "$GH_ACTION_NAME" ]
        then
            GITHUB_LAST_ACTION=$(jq -c '[ .[] | select( .name == "'"$GH_ACTION_NAME"'" ) ][0]' <<< "$GITHUB_LAST_ACTION")

            if [ "$GITHUB_LAST_ACTION" == "null" ]; then
                echo "[Error] Not found GitHub action named $GH_ACTION_NAME run on the last git commit on branch $GIT_BRANCH"
                return 1
            fi
        else
            GITHUB_LAST_ACTION=$(jq -c '[ .[] ][0]' <<< "$GITHUB_LAST_ACTION")
        fi

        HEAD_SHA=$(jq -r '.head_sha' <<< "$GITHUB_LAST_ACTION")
        STATUS=$(jq -r '.status' <<< "$GITHUB_LAST_ACTION")
        CONCLUSION=$(jq -r '.conclusion' <<< "$GITHUB_LAST_ACTION")

        if [ "$STATUS" == "completed" ]; then
            if [ "$CONCLUSION" == "success" ]; then
                echo "[Info] GitHub action check successfull. Ready to pull."
            else
                echo "[Error] GitHub action check not successfull. Do not pull."
                return 1
            fi
        else
            echo "[Error] GitHub action check not completed. Do not pull."
            return 1
        fi
    else
        echo "[Info] GitHub actions check disabled."
    fi
}

###################

#### Main program ####
cd /config || { echo "[Error] Failed to cd into /config"; exit 1; }

while true; do
    check-ssh-key
    setup-user-password
    if git-synchronize ; then
        validate-config
    fi
     # do we repeat?
    if [ ! "$REPEAT_ACTIVE" == "true" ]; then
        exit 0
    fi
    sleep "$REPEAT_INTERVAL"
done

###################

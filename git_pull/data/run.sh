#!/usr/bin/with-contenv bashio

#### config ####

CONFIG_PATH=/data/options.json
HOME=~

DEPLOYMENT_KEY=$(bashio::config 'deployment_key')
DEPLOYMENT_KEY_PROTOCOL=$(bashio::config 'deployment_key_protocol')
DEPLOYMENT_USER=$(bashio::config 'deployment_user')
DEPLOYMENT_PASSWORD=$(bashio::config 'deployment_password')
GIT_BRANCH=$(bashio::config 'git_branch')
GIT_COMMAND=$(bashio::config 'git_command')
GIT_REMOTE=$(bashio::config 'git_remote')
GIT_PRUNE=$(bashio::config 'git_prune')
REPOSITORY=$(bashio::config 'repository')
AUTO_RESTART=$(bashio::config 'auto_restart')
RESTART_IGNORED_FILES=$(bashio::config 'restart_ignore | join(" ")')
REPEAT_ACTIVE=$(bashio::config 'repeat.active')
REPEAT_INTERVAL=$(bashio::config 'repeat.interval')
################

#### functions ####
function add-ssh-key {
    bashio::log.info "[Info] Start adding SSH key"
    mkdir -p ~/.ssh

    (
        echo "Host *"
        echo "    StrictHostKeyChecking no"
    ) > ~/.ssh/config

    bashio::log.info "[Info] Setup deployment_key on id_${DEPLOYMENT_KEY_PROTOCOL}"
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
    bashio::log.info "[Info] Backup configuration to $BACKUP_LOCATION"

    mkdir "${BACKUP_LOCATION}" || bashio::exit.nok "[Error] Creation of backup directory failed"
    cp -rf /config/* "${BACKUP_LOCATION}" || bashio::exit.nok "[Error] Copy files to backup directory failed"

    # remove config folder content
    rm -rf /config/{,.[!.],..?}* || { bashio::exit.nok "[Error] Clearing /config failed"

    # git clone
    bashio::log.info "[Info] Start git clone"
    git clone "$REPOSITORY" /config || bashio::exit.nok "[Error] Git clone failed"

    # try to copy non yml files back
    cp "${BACKUP_LOCATION}" "!(*.yaml)" /config 2>/dev/null

    # try to copy secrets file back
    cp "${BACKUP_LOCATION}/secrets.yaml" /config 2>/dev/null
}

function check-ssh-key {
if [ -n "$DEPLOYMENT_KEY" ]; then
    bashio::log.info "Check SSH connection"
    IFS=':' read -ra GIT_URL_PARTS <<< "$REPOSITORY"
    # shellcheck disable=SC2029
    DOMAIN="${GIT_URL_PARTS[0]}"
    if OUTPUT_CHECK=$(ssh -T -o "StrictHostKeyChecking=no" -o "BatchMode=yes" "$DOMAIN" 2>&1) || { [[ $DOMAIN = *"@github.com"* ]] && [[ $OUTPUT_CHECK = *"You've successfully authenticated"* ]]; }; then
        bashio::log.info "[Info] Valid SSH connection for $DOMAIN"
    else
        bashio::log.warn "[Warn] No valid SSH connection for $DOMAIN"
        add-ssh-key
    fi
fi
}

function setup-user-password {
if [ -n "$DEPLOYMENT_USER" ]; then
    cd /config || return
    bashio::log.info "[Info] setting up credential.helper for user: ${DEPLOYMENT_USER}"
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
    bashio::log.info "[Info] Saving git credentials to /tmp/git-credentials"
    # shellcheck disable=SC2259
    git credential fill | git credential approve <<< "$cred_data"
fi
}

function git-synchronize {
    # is /config a local git repo?
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        bashio::log.warn "[Warn] Git repository doesn't exist"
        git-clone
        return
    fi

    bashio::log.info "[Info] Local git repository exists"
    # Is the local repo set to the correct origin?
    CURRENTGITREMOTEURL=$(git remote get-url --all "$GIT_REMOTE" | head -n 1)
    if [ "$CURRENTGITREMOTEURL" != "$REPOSITORY" ]; then
        bashio::exit.nok "[Error] git origin does not match $REPOSITORY!";
        return
    fi

    bashio::log.info "[Info] Git origin is correctly set to $REPOSITORY"
    OLD_COMMIT=$(git rev-parse HEAD)

    # Always do a fetch to update repos
    bashio::log.info "[Info] Start git fetch..."
    git fetch "$GIT_REMOTE" || bashio::exit.nok "[Error] Git fetch failed";

    # Prune if configured
    if [ "$GIT_PRUNE" == "true" ]
    then
        bashio::log.info "[Info] Start git prune..."
        git prune || bashio::exit.nok "[Error] Git prune failed";
    fi

    # Do we switch branches?
    GIT_CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
    if [ -z "$GIT_BRANCH" ] || [ "$GIT_BRANCH" == "$GIT_CURRENT_BRANCH" ]; then
        bashio::log.info "[Info] Staying on currently checked out branch: $GIT_CURRENT_BRANCH..."
    else
        bashio::log.info "[Info] Switching branches - start git checkout of branch $GIT_BRANCH..."
        git checkout "$GIT_BRANCH" || bashio::exit.nok "[Error] Git checkout failed"
        GIT_CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
    fi

    # Pull or reset depending on user preference
    case "$GIT_COMMAND" in
        pull)
            bashio::log.info "[Info] Start git pull..."
            git pull || bashio::exit.nok "[Error] Git pull failed";
            ;;
        reset)
            bashio::log.info "[Info] Start git reset..."
            git reset --hard "$GIT_REMOTE"/"$GIT_CURRENT_BRANCH" || bashio::exit.nok "[Error] Git reset failed";
            ;;
        *)
            bashio::exit.nok "[Error] Git command is not set correctly. Should be either 'reset' or 'pull'"
            ;;
    esac
}

function validate-config {
    bashio::log.info "[Info] Checking if something has changed..."
    # Compare commit ids & check config
    NEW_COMMIT=$(git rev-parse HEAD)
    if [ "$NEW_COMMIT" == "$OLD_COMMIT" ]; then
        bashio::log.info "[Info] Nothing has changed."
        return
    fi
    bashio::log.info "[Info] Something has changed, checking Home-Assistant config..."
    if ! bashio::core.check; then
        bashio::log.error "[Error] Configuration updated but it does not pass the config check. Do not restart until this is fixed!"
        return
    fi
    if [ "$AUTO_RESTART" != "true" ]; then
        bashio::log.info "[Info] Local configuration has changed. Restart required."
        return
    fi
    DO_RESTART="false"
    CHANGED_FILES=$(git diff "$OLD_COMMIT" "$NEW_COMMIT" --name-only)
    bashio::log.info "Changed Files: $CHANGED_FILES"
    if [ -n "$RESTART_IGNORED_FILES" ]; then
        for changed_file in $CHANGED_FILES; do
            bashio::log.info "[Info] Checking: $changed_file"
            restart_required_file=""
            for restart_ignored_file in $RESTART_IGNORED_FILES; do
                bashio::log.info "[Info] Checking: $changed_file for $restart_ignored_file"
                if [ -d "$restart_ignored_file" ]; then
                    # file to be ignored is a whole dir
                    set +e
                    restart_required_file=$(echo "${changed_file}" | grep "^${restart_ignored_file}")
                    set -e
                else
                    set +e
                    restart_required_file=$(echo "${changed_file}" | grep "^${restart_ignored_file}$")
                    set -e
                fi
                # break on first match
                if [ -n "$restart_required_file" ]; then break; fi
            done
            if [ -z "$restart_required_file" ]; then
                DO_RESTART="true"
                bashio::log.info "[Info] Detected restart-required file: $changed_file"
            else
                bashio::log.info "[Info] Detected ignored file: $changed_file"
            fi
        done
    else
        DO_RESTART="true"
    fi

    if [ "$DO_RESTART" == "true" ]; then
        bashio::log.info "[Info] Restart Home-Assistant"
        bashio::core.restart
    else
        bashio::log.info "[Info] No Restart Required, only ignored changes detected"
    fi
    bashio::log.info "Finished validation of config"
}

###################

#### Main program ####
cd /config || bashio::exit.nok "[Error] Failed to cd into /config";

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

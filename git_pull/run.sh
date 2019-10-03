#!/usr/bin/env bashio

#### config ####

DEPLOYMENT_KEY_PROTOCOL=$(bashio::config "deployment_key_protocol")
DEPLOYMENT_USER=$(bashio::config "deployment_user")
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
    bashio::log:info "Start adding SSH key"
    mkdir -p ~/.ssh

    (
        echo "Host *"
        echo "    StrictHostKeyChecking no"
    ) > ~/.ssh/config

    bashio::log:info "Setup deployment_key on id_${DEPLOYMENT_KEY_PROTOCOL}"
    while read -r line; do
        echo "$line" >> "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
    done <<< "$(bashio::config "deployment_key")"

    chmod 600 "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
}

function git-clone {
    # create backup
    BACKUP_LOCATION="/tmp/config-$(date +%Y-%m-%d_%H-%M-%S)"
    bashio::log:info "Backup configuration to $BACKUP_LOCATION"

    mkdir "${BACKUP_LOCATION}" || bashio:exit:nok "Creation of backup directory failed"
    cp -rf /config/* "${BACKUP_LOCATION}" || bashio:exit:nok "Copy files to backup directory failed"

    # remove config folder content
    rm -rf /config/{,.[!.],..?}* || bashio:exit:nok "Clearing /config failed"

    # git clone
    bashio::log:info "Start git clone"
    git clone "$REPOSITORY" /config || bashio:exit:nok "Git clone failed"

    # try to copy non yml files back
    cp "${BACKUP_LOCATION}" "!(*.yaml)" /config 2>/dev/null

    # try to copy secrets file back
    cp "${BACKUP_LOCATION}/secrets.yaml" /config 2>/dev/null
}

function check-ssh-key {
if bashio::config.has_value 'deployment_key'; then
    bashio::log:info "Check SSH connection"
    IFS=':' read -ra GIT_URL_PARTS <<< "$REPOSITORY"
    # shellcheck disable=SC2029
    DOMAIN="${GIT_URL_PARTS[0]}"
    if OUTPUT_CHECK=$(ssh -T -o "StrictHostKeyChecking=no" -o "BatchMode=yes" "$DOMAIN" 2>&1) || { [[ $DOMAIN = *"@github.com"* ]] && [[ $OUTPUT_CHECK = *"You've successfully authenticated"* ]]; }; then
        bashio::log:info "Valid SSH connection for $DOMAIN"
    else
        bashio::log:warn "No valid SSH connection for $DOMAIN"
        add-ssh-key
    fi
fi
}

function setup-user-password {
if bashio::config.has_value 'deployment_user'; then
    cd /config || return
    bashio::log:info "setting up credential.helper for user: ${DEPLOYMENT_USER}"
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
password=$(bashio::config "deployment_password")
"

    # Use git commands to write the credentials to ~/.git-credentials
    bashio::log:info "Saving git credentials to /tmp/git-credentials"
    git credential fill | git credential approve <<< "$cred_data"
fi
}

function git-synchronize {
    # is /config a local git repo?
    if git rev-parse --is-inside-work-tree &>/dev/null
    then
        bashio::log:info "Local git repository exists"

        # Is the local repo set to the correct origin?
        CURRENTGITREMOTEURL=$(git remote get-url --all "$GIT_REMOTE" | head -n 1)
        if [ "$CURRENTGITREMOTEURL" = "$REPOSITORY" ]
        then
            bashio::log:info "Git origin is correctly set to $REPOSITORY"
            OLD_COMMIT=$(git rev-parse HEAD)

            # Always do a fetch to update repos
            bashio::log:info "Start git fetch..."
            git fetch "$GIT_REMOTE" || bashio:exit:nok "Git fetch failed"

            # Prune if configured
            if [ "$GIT_PRUNE" == "true" ]
            then
              bashio::log:info "Start git prune..."
              git prune || bashio:exit:nok "Git prune failed"
            fi

            # Do we switch branches?
            GIT_CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
            if [ -z "$GIT_BRANCH" ] || [ "$GIT_BRANCH" == "$GIT_CURRENT_BRANCH" ]; then
              bashio::log:info "Staying on currently checked out branch: $GIT_CURRENT_BRANCH..."
            else
              bashio::log:info "Switching branches - start git checkout of branch $GIT_BRANCH..."
              git checkout "$GIT_BRANCH" || bashio:exit:nok "Git checkout failed"
              GIT_CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
            fi

            # Pull or reset depending on user preference
            case "$GIT_COMMAND" in
                pull)
                    bashio::log:info "Start git pull..."
                    git pull || bashio:exit:nok "Git pull failed"
                    ;;
                reset)
                    bashio::log:info "Start git reset..."
                    git reset --hard "$GIT_REMOTE"/"$GIT_CURRENT_BRANCH" || bashio:exit:nok "Git reset failed"
                    ;;
                *)
                    bashio::log:error "Git command is not set correctly. Should be either 'reset' or 'pull'"
                    exit 1
                    ;;
            esac
        else
            bashio::log:error "git origin does not match $REPOSITORY!"; exit 1;
        fi

    else
        bashio::log:warn "Git repostory doesn't exist"
        git-clone
    fi
}

function validate-config {
    bashio::log:info "Checking if something has changed..."
    # Compare commit ids & check config
    NEW_COMMIT=$(git rev-parse HEAD)
    if [ "$NEW_COMMIT" != "$OLD_COMMIT" ]; then
        bashio::log:info "Something has changed, checking Home-Assistant config..."
        if hassio --no-progress homeassistant check; then
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
                            bashio::log:info "Detected restart-required file: $changed_file"
                        fi
                    done
                else
                    DO_RESTART="true"
                fi
                if [ "$DO_RESTART" == "true" ]; then
                    bashio::log:info "Restart Home-Assistant"
                    hassio --no-progress homeassistant restart 2&> /dev/null
                else
                    bashio::log:info "No Restart Required, only ignored changes detected"
                fi
            else
                bashio::log:info "Local configuration has changed. Restart required."
            fi
        else
            bashio::log:error "Configuration updated but it does not pass the config check. Do not restart until this is fixed!"
        fi
    else
        bashio::log:info "Nothing has changed."
    fi
}

###################

#### Main program ####
cd /config || bashio:exit:nok "Failed to cd into /config"

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

#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup persistent user settings
# ==============================================================================
readonly DIRECTORIES=(addon_configs addons backup homeassistant media share ssl)

# Persist shell history by redirecting .bash_history to /data
if ! bashio::fs.file_exists /data/.bash_profile; then
    touch /data/.bash_history
fi
chmod 600 /data/.bash_history

# Make Home Assistant TOKEN available on the CLI
mkdir -p /etc/profile.d
bashio::var.json \
    supervisor_token "${SUPERVISOR_TOKEN}" \
    | tempio \
        -template /usr/share/tempio/homeassistant.profile \
        -out /etc/profile.d/homeassistant.sh


# Persist shell profile by redirecting .bash_profile to /data
if ! bashio::fs.file_exists /data/.bash_profile; then
    touch /data/.bash_profile
fi
chmod 600 /data/.bash_profile

# Links some common directories to the user's home folder for convenience
for dir in "${DIRECTORIES[@]}"; do
    ln -s "/${dir}" "${HOME}/${dir}" \
        || bashio::log.warning "Failed linking common directory: ${dir}"
done

# Some links to "old" locations, to match documentation,
# backwards compatibility and musle memory
ln -s "/homeassistant" "/config" \
    || bashio::log.warning "Failed linking common directory: /config"
ln -s "/homeassistant" "${HOME}/config" \
    || bashio::log.warning "Failed linking common directory: ${HOME}/config"

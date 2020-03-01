#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup persistent user settings
# ==============================================================================
DIRECTORIES=(addons backup config share ssl)

# Persist shell history by redirecting .bash_history to /data
touch /data/.bash_history
chmod 600 /data/.bash_history
ln -s -f /data/.bash_history /root/.bash_history

# Make Home Assistant TOKEN available on the CLI
echo "export SUPERVISOR_TOKEN=${SUPERVISOR_TOKEN}" >> /etc/profile.d/homeassistant.sh

# Remove old HASSIO_TOKEN from bash profile (if exists)
if bashio::fs.file_exists /data/.bash_profile; then
  sed -i "/export HASSIO_TOKEN=.*/d" /data/.bash_profile
fi

# Persist .bash_profile by redirecting .bash_profile to /data
touch /data/.bash_profile
chmod 600 /data/.bash_profile
ln -s -f /data/.bash_profile /root/.bash_profile

# Links some common directories to the user's home folder for convenience
for dir in "${DIRECTORIES[@]}"; do
    ln -s "/${dir}" "${HOME}/${dir}" \
        || bashio::log.warning "Failed linking common directory: ${dir}"
done

# Sets up the users .ssh folder to be persistent
if ! bashio::fs.directory_exists /data/.ssh; then
    mkdir -p /data/.ssh \
        || bashio::exit.nok 'Failed to create a persistent .ssh folder'

    chmod 700 /data/.ssh \
        || bashio::exit.nok \
            'Failed setting permissions on persistent .ssh folder'
fi
ln -s /data/.ssh /root/.ssh

#!/usr/bin/env bashio
set -e

MARIADB_DATA=/data/databases

# Init mariadb
if ! bashio::fs.directory_exists "${MARIADB_DATA}"; then
    bashio::log.info "Create a new mariadb initial system"
    mysql_install_db --user=root --datadir="$MARIADB_DATA" > /dev/null
else
    bashio::log.info "Using existing mariadb initial system"
fi

# Start mariadb
bashio::log.info "Starting MariaDB"
mysqld_safe --datadir="$MARIADB_DATA" --user=root --skip-log-bin < /dev/null &
MARIADB_PID=$!

# Wait until DB is running
while ! mysql -e "" 2> /dev/null; do
    sleep 1
done

bashio::log.info "Check data integrity and fix corruptions"
mysqlcheck --no-defaults --check-upgrade --auto-repair --databases mysql --skip-write-binlog > /dev/null || true
mysqlcheck --no-defaults --all-databases --fix-db-names --fix-table-names --skip-write-binlog > /dev/null || true
mysqlcheck --no-defaults --check-upgrade --all-databases --auto-repair --skip-write-binlog > /dev/null || true

# Init databases
bashio::log.info "Init custom database"
for line in $(bashio::config "databases"); do
    bashio::log.info "Create database $line"
    mysql -e "CREATE DATABASE $line;" 2> /dev/null || true
done

# Init logins
bashio::log.info "Init/Update users"
for login in $(bashio::config "logins|keys"); do
    USERNAME=$(bashio::config "logins[${login}].username")
    PASSWORD=$(bashio::config "logins[${login}].password")
    HOST=$(bashio::config "logins[${login}].host")

    if mysql -e "SET PASSWORD FOR '$USERNAME'@'$HOST' = PASSWORD('$PASSWORD');" 2> /dev/null; then
        bashio::log.info "Update user $USERNAME"
    else
        bashio::log.info "Create user $USERNAME"
        mysql -e "CREATE USER '$USERNAME'@'$HOST' IDENTIFIED BY '$PASSWORD';" 2> /dev/null || true
    fi
done

# Init rights
bashio::log.info "Init/Update rights"
for right in $(bashio::config "rights|keys"); do
    USERNAME=$(bashio::config "rights[${right}].username")
    HOST=$(bashio::config "rights[${right}].host")
    DATABASE=$(bashio::config "rights[${right}].database")
    GRANT=$(bashio::config "rights[${right}].grant")

    bashio::log.info "Alter rights for $USERNAME@$HOST - $DATABASE"
    mysql -e "GRANT $GRANT $DATABASE.* TO '$USERNAME'@'$HOST';" 2> /dev/null || true
done

# Register stop
function stop_mariadb() {
    mysqladmin shutdown
}
trap "stop_mariadb" SIGTERM SIGHUP

wait "$MARIADB_PID"

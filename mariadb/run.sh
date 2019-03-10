#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
MARIADB_DATA=/data/databases

DATABASES=$(jq --raw-output ".databases[]" $CONFIG_PATH)
LOGINS=$(jq --raw-output '.logins | length' $CONFIG_PATH)
RIGHTS=$(jq --raw-output '.rights | length' $CONFIG_PATH)

# Init mariadb
if [ ! -d "$MARIADB_DATA" ]; then
    echo "[INFO] Create a new mariadb initial system"
    mysql_install_db --user=root --datadir="$MARIADB_DATA" > /dev/null
else
    echo "[INFO] Use exists mariadb initial system"
    mysqlcheck --no-defaults --check-upgrade --auto-repair --databases mysql --skip-write-binlog > /dev/null || true
    mysqlcheck --no-defaults --all-databases --fix-db-names --fix-table-names --skip-write-binlog > /dev/null || true
    mysqlcheck --no-defaults --check-upgrade --all-databases --auto-repair --skip-write-binlog > /dev/null || true
fi

# Start mariadb
echo "[INFO] Start MariaDB"
mysqld_safe --datadir="$MARIADB_DATA" --user=root --skip-log-bin < /dev/null &
MARIADB_PID=$!

# Wait until DB is running
while ! mysql -e "" 2> /dev/null; do
    sleep 1
done

# Init databases
echo "[INFO] Init custom database"
for line in $DATABASES; do
    echo "[INFO] Create database $line"
    mysql -e "CREATE DATABASE $line;" 2> /dev/null || true
done

# Init logins
echo "[INFO] Init/Update users"
for (( i=0; i < "$LOGINS"; i++ )); do
    USERNAME=$(jq --raw-output ".logins[$i].username" $CONFIG_PATH)
    PASSWORD=$(jq --raw-output ".logins[$i].password" $CONFIG_PATH)
    HOST=$(jq --raw-output ".logins[$i].host" $CONFIG_PATH)

    if mysql -e "SET PASSWORD FOR '$USERNAME'@'$HOST' = PASSWORD('$PASSWORD');" 2> /dev/null; then
        echo "[INFO] Update user $USERNAME"
    else
        echo "[INFO] Create user $USERNAME"
        mysql -e "CREATE USER '$USERNAME'@'$HOST' IDENTIFIED BY '$PASSWORD';" 2> /dev/null || true
    fi
done

# Init rights
echo "[INFO] Init/Update rights"
for (( i=0; i < "$RIGHTS"; i++ )); do
    USERNAME=$(jq --raw-output ".rights[$i].username" $CONFIG_PATH)
    HOST=$(jq --raw-output ".rights[$i].host" $CONFIG_PATH)
    DATABASE=$(jq --raw-output ".rights[$i].database" $CONFIG_PATH)
    GRANT=$(jq --raw-output ".rights[$i].grant" $CONFIG_PATH)

    echo "[INFO] Alter rights for $USERNAME@$HOST - $DATABASE"
    mysql -e "GRANT $GRANT $DATABASE.* TO '$USERNAME'@'$HOST';" 2> /dev/null || true
done

# Register stop
function stop_mariadb() {
    mysqladmin shutdown
}
trap "stop_mariadb" SIGTERM SIGHUP

wait "$MARIADB_PID"

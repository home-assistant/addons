#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
MARIADB_DATA=/data/databases

DATABASES=$(jq --raw-output ".databases[]" $CONFIG_PATH)

# Init mariadb
if [ ! -d "$MARIADB_DATA" ]; then
    echo "[INFO] Create a new mariadb initial system"
    mysql_install_db --user=root --datadir="$MARIADB_DATA" > /dev/null
else
    echo "[INFO] Use exists mariadb initial system"
fi

# Start mariadb
echo "[INFO] Start MariaDB"
mysqld_safe --datadir="$MARIADB_DATA" --user=root < /dev/null &
MARIADB_PID=$!

# Wait until DB is running
while ! mysql -e 2> /dev/null; do
    sleep 1
done

# Init databases
for line in $DATABASES; do
    mysql -e "CREATE DATABASE $line;" 2> /dev/null || true
done

wait "$MARIADB_PID"

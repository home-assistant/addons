# Changelog

## 2.7.2

- Add option to configure MariaDB server parameters (see also [home-assistant/addons#3754](https://github.com/home-assistant/addons/issues/3754))

## 2.7.1

**Note:** Restart the add-on before upgrade if the current version is lower
than 2.7.0! This is to ensure a clean stop right before the update (see also
https://github.com/home-assistant/addons/issues/3566).

- Increase MariaDB add-on shutdown timeout to 300s

## 2.7.0

- Update to Alpine 3.19

## 2.6.1

- Use proper log redirection during backup

## 2.6.0

- Migrate add-on layout to S6 Overlay
- Update to MariaDB version 10.6.12

## 2.5.2

- Update to MariaDB version 10.6.10

## 2.5.1

- Remove deprecated `innodb-buffer-pool-instances`

## 2.5.0

- Update alpine to 3.16 and s6 to v3

## 2.4.0

- Add lock capabilities during snapshot

## 2.3.0

- Option to grant user specific privileges for a database

## 2.2.2

- Update options schema for passwords

## 2.2.1

- Don't delete the mariadb.sys user, it's needed in MariaDB >= 10.4.13

## 2.2.0

- Upgrade Alpine Linux to 3.12
- Increase innodb_buffer_pool_size to 128M

## 2.1.2

- Fix S6-Overlay shutdown timeout

## 2.1.0

- Migrate to S6-Overlay
- Use jemalloc for faster database memory management

## 2.0.0

- Pin add-on to Alpine Linux 3.11
- Redirect MariaDB error log to add-on logs
- Remove grant & host options
- Add support for the mysql service
- Use a more secure default on install
- Skip DNS name resolving
- Improve integrity checks and recovery
- Tune MariaDB for lower memory usage
- Close port 3306 by default
- Ensure a proper collation set is used
- Adds database upgrade process during startup
- Change default configuration username from "hass" to "homeassistant"

## 1.3.0

- Update from bash to bashio

## 1.2.0

- Change the way to migrate data

## 1.1.0

- Fix connection issue with 10.3.13

## 1.0.0

- Update MariaDB to 10.3.13

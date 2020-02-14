# Changelog

## 2.0

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

## 1.3

- Update from bash to bashio

## 1.2

- Change the way to migrate data

## 1.1

- Fix connection issue with 10.3.13

## 1.0

- Update MariaDB to 10.3.13

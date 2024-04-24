# Changelog

## 12.3.1

- Handle passwords with backslash correctly

## 12.3.0

- Upgrade Alpine Linux to 3.19

## 12.2.0

- Decrease Samba log level

## 12.1.0

- Use the new Home Assistant folder for the `config` share
- Add support for accessing public add-on configurations

## 12.0.0

- Temporary remove access to add-on config shares, until Supervisor 2023.11.2 has been rolled out stable
- Revert `config` share name change to avoid user facing change
- Adjust location of Home Assistant config to match latest dev/beta Supervisor
- Migrate add-on layout to S6 Overlay

## 11.0.0

- The `config` share has been renamed to `homeassistant` to match upstream changes.
- Add support for accessing public add-on configurations
- Update to Alpine 3.18
- Adds HEALTCHECK support

## 10.0.2

- Enable IPv6 ULA and IPv4 link-local addresses by default

## 10.0.1

- Update to Alpine 3.17

## 10.0.0

BREAKING CHANGE: Don't mangle filenames

By default, Samba mangles filenames with special characters to ensure
compatibility with really old versions of Windows which have a very limited
charset for filenames. The add-on no longer does this as modern operating
systems do not have these restrictions.

- Don't mangle filenames (fixes #2541)
- Upgrade Alpine Linux to 3.16

## 9.7.0

- Upgrade Alpine Linux to 3.15
- Sign add-on with Codenotary Community Attestation Service (CAS)

## 9.6.1

- Remove lo from interface list
- Exit with error if there are no supported interfaces to run Samba on

## 9.6.0

- Run on all supported interfaces

## 9.5.1

- Add `hassio_api` to add-on configuration

## 9.5.0

- Remove interface options in favor of network

## 9.4.0

- Upgrade Alpine Linux to 3.13
- Rewrite configuration generation code

## 9.3.1

- Update options schema for passwords

## 9.3.0

- Support new media folder
- Update Samba to 4.12.6
- Upgrade Alpine Linux to 3.12

## 9.2.0

- Pin base image version
- Rewrite add-on onto S6 Overlay
- Use default configuration location
- Add support for running in compatibility mode (SMB1/NT1)
- Add dummy files to reduce number of errors/warnings in log output

## 9.1.0

- Allow IPv6 link-local hosts by default, consistent with IPv4

## 9.0.0

- New option `veto_files` to limit writing of specified files to the share

## 8.3.0

- Fixes a bug in warning log message, causing start failure
- Minor code cleanups

## 8.2.0

- Update from bash to bashio

## 8.1.0

- Update Samba to version 4.8.8

## 8.0.0

- Fix access to /backup

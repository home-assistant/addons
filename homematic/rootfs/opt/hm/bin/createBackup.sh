#!/bin/bash
# shellcheck source=/dev/null
#
# simple backup script to create a CCU compatible .sbk type
# backup out of the core-homematic HomeAssistant add-on
#
# Copyright (c) 2022 Jens Maus <mail@jens-maus.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Usage:
# createBackup.sh <directory/file>
#

# Stop on error
set -e

# default backup destination directory
BACKUPDIR=/tmp

# let caller overwrite the backup path
if [[ -n "${1}" ]]; then
  BACKUPPATH="${1}"
else
  echo "ERROR: no backup path specified"
fi

# get running firmware version
. /VERSION 2>/dev/null

# check if specified path is a directory or file
if [[ -d "${BACKUPPATH}" ]]; then
  # a directory path was specified, lets construct the complete filepath
  BACKUPDIR="$(realpath "${BACKUPPATH}")"
  BACKUPFILE="$(hostname)-${VERSION}-$(date +%Y-%m-%d-%H%M).sbk"
else
  # a file was specified with a directory path
  BACKUPDIR="$(realpath "$(dirname "${BACKUPPATH}")")"
  BACKUPFILE="$(basename "${BACKUPPATH}")"
fi

# use the backupdir as base directory for creating
# a temporary directory to create the backup stuff in there.
TMPDIR=$(mktemp -d -p "${BACKUPDIR}")
if [[ -d "${TMPDIR}" ]]; then
  # make sure TMPDIR is removed under all circumstances
  # shellcheck disable=SC2064
  trap "rm -rf ${TMPDIR}" EXIT

  # make sure ReGaHSS saves its current settings
  echo 'load tclrega.so; rega system.Save()' | /opt/hm/bin/tclsh >/dev/null 2>&1

  # create a CCU conform copy of /usr/local
  mkdir -p "${TMPDIR}/usr/local"
  mkdir -p "${TMPDIR}/usr/local/etc/config"
  cp -a /opt/hm/etc/config/* "${TMPDIR}/usr/local/etc/config/"
  rm -f "${TMPDIR}/usr/local/etc/config/groups.gson" "${TMPDIR}/usr/local/etc/config/userprofiles"
  cp -a /data/* "${TMPDIR}/usr/local/etc/config/"

  # move crRFD files to data sub-dir to be compatible
  rm -rf "${TMPDIR}/usr/local/etc/config/crRFD"
  mkdir -p "${TMPDIR}/usr/local/etc/config/crRFD"
  cp -a /data/crRFD "${TMPDIR}/usr/local/etc/config/crRFD/data"

  # cleanup
  rm -f "${TMPDIR}/usr/local/etc/config/options.json"
  rm -f "${TMPDIR}/usr/local/etc/config/groups.json"
  rm -f "${TMPDIR}/usr/local/etc/config/HMServer.conf"
  rm -f "${TMPDIR}/usr/local/etc/config/hmip_user.conf"
  rm -f "${TMPDIR}/usr/local/etc/config/log4j.xml"
  rm -f "${TMPDIR}/usr/local/etc/config/rega.conf"
  rm -f "${TMPDIR}/usr/local/etc/config/rega_user.conf"

  # create a gzipped tar of /usr/local
  set +e # disable abort on error
  /bin/tar -C "${TMPDIR}" --owner=root --group=root --exclude=usr/local/tmp --exclude=usr/local/lost+found --exclude="${BACKUPDIR}" --exclude-tag=.nobackup --ignore-failed-read --warning=no-file-changed -czf "${TMPDIR}/usr_local.tar.gz" usr/local 2>/dev/null
  if [[ $? -eq 2 ]]; then
    exit 2
  fi
  set -e # re-enable abort on error

  # remove the temp usr dir again
  rm -rf "${TMPDIR:?}/usr"

  # sign the configuration with the current key
  /opt/hm/bin/crypttool -s -t 1 <"${TMPDIR}/usr_local.tar.gz" >"${TMPDIR}/signature"

  # store the current key index
  /opt/hm/bin/crypttool -g -t 1 >"${TMPDIR}/key_index"

  # store the firmware VERSION
  echo "VERSION=${VERSION}" >"${TMPDIR}/firmware_version"

  # create sha256 checksum of all files
  (cd "${TMPDIR}" && /usr/bin/sha256sum ./* >signature.sha256)

  # create sbk file
  /bin/tar -C "${TMPDIR}" --owner=root --group=root -cf "${BACKUPDIR}/${BACKUPFILE}" usr_local.tar.gz signature signature.sha256 key_index firmware_version 2>/dev/null

  exit 0
else
  exit 1
fi

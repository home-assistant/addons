#!/bin/bash
set -e

# Install modules
echo "[Info] Install TensorFlow modules into deps"
export PYTHONUSERBASE=/config/deps

# shellcheck disable=SC2086
if ! pip3 install --user --no-cache-dir --prefix= --no-dependencies ${PYPI}; then
    echo "[Error] Can't install PyPI packages!"
    exit 1
fi

echo "[Info] Install TensorFlow into deps"
if ! pip3 install --user --no-cache-dir --prefix= --no-dependencies /usr/src/tensorflow_pkg/tensorflow-$TENSORFLOW_VERSION-cp36-cp36m-linux_*.whl; then
    echo "[Error] Can't install TensorFlow package!"
fi


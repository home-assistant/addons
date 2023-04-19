#!/usr/bin/env bash
config_path=/data/options.json
port='10200'

voice="$(jq -r < "${config_path}" '.voice')"
speaker="$(jq -r < "${config_path}" '.speaker')"

local_data_dir="/app/data"
shared_data_dir="/share/wyoming/data/tts/piper"

# Check local data first
voice_onnx="${local_data_dir}/${voice}.onnx"
echo "Checking ${voice_onnx}"
if [[ ! -s "${voice_onnx}" ]]; then
    echo "Checking ${shared_data_dir}"

    voice_onnx="${shared_data_dir}/${voice}.onnx"
    if [[ ! -s "${voice_onnx}" ]]; then
        mkdir -p "${shared_data_dir}"
        url="https://github.com/rhasspy/piper/releases/download/v0.0.2/voice-${voice}.tar.gz";
        echo "Downloading ${voice} from ${url}"

        wget -O- "${url}" | \
            tar -C "${shared_data_dir}" -xzf -

        echo "Download successful (${voice})"
    fi
fi

cd /app
.venv/bin/python3 src/piper_server.py \
    "${voice_onnx}" \
    --uri "tcp://0.0.0.0:${port}" --speaker "${speaker}" --debug "$@"

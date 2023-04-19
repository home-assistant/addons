#!/usr/bin/env bash
config_path=/data/options.json
port='10300'

model="$(jq -r < "${config_path}" '.model')"
language="$(jq -r < "${config_path}" '.language')"

local_data_dir="/app/data"
shared_data_dir="/share/wyoming/data/asr/faster-whisper"

# Check local data first
model_dir="${local_data_dir}/${model}"
echo "Checking ${model_dir}"
if [[ ! -s "${model_dir}/model.bin" ]]; then
    model_dir="${shared_data_dir}/${model}"
    echo "Checking ${model_dir}"

    if [[ ! -s "${model_dir}/model.bin" ]]; then
        rm -rf "${model_dir}";
        mkdir -p "${shared_data_dir}"
        url="https://github.com/rhasspy/models/releases/download/v1.0/asr_faster-whisper-${model}.tar.gz";
        echo "Downloading ${model} from ${url}"

        # Model .tar.gz contains a directory with the name of them model
        wget -O- "${url}" | \
            tar -C "$(dirname "${model_dir}")" -xzf -

        echo "Download successful (${model})"
    fi
fi

extra_args=()

if [[ ! "${language}" == 'auto' ]]; then
    extra_args+=('--language' "${language}")
fi

extra_args+=("$@")

cd /app || exit 1
.venv/bin/python3 src/faster-whisper/bin/faster_whisper_server.py \
    "${model_dir}" \
    --uri "tcp://0.0.0.0:${port}" --debug "${extra_args[@]}"

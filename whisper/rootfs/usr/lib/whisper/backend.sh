# vim: ft=bash
# shellcheck shell=bash
# ==============================================================================
# Which speech-to-text backend the configured options select, and whether it is
# installed.
#
# Sourced by the "packs" service, which installs the optional backends, and by
# the Whisper service, which warns when the one it is about to use is missing.
# Both have to reach the same answer, so the answer lives here rather than in
# each of them.
# ==============================================================================

# Module the server looks for to decide a backend is available, or nothing at
# all when the backend is part of the image and always present.
#
# The names match what models.py checks for, so a backend that stops being
# importable here is exactly one the server will refuse to use.
whisper::pack_module() {
    case "${1}" in
        transformers) echo 'transformers' ;;
        funasr) echo 'funasr' ;;
        *) echo '' ;;
    esac
}

# Resolve the app's own options into the --model and --stt-library the server
# will be started with, in ${whisper_model} and ${whisper_stt_library}.
#
# These are the two rules the app adds on top of the server's own selection: a
# custom model takes its type from custom_model_type, and naming a model at all
# means Whisper unless a library was asked for explicitly.
#
# ${whisper_model} comes back empty when "custom" is selected without a
# custom_model. That is a configuration error, but not one this file decides
# what to do about -- the Whisper service refuses to start, while the packs
# service still installs for whatever library was named.
whisper::resolve_options() {
    whisper_model="$(bashio::config 'model')"
    whisper_stt_library="$(bashio::config 'stt_library')"

    if [ "${whisper_model}" = 'custom' ]; then
        # Override with custom model
        whisper_model="$(bashio::config 'custom_model')"
        if [ "${whisper_stt_library}" = 'auto' ]; then
            # Need to know what kind of custom model
            whisper_stt_library="$(bashio::config 'custom_model_type')"
        fi
    elif [ "${whisper_model}" != 'auto' ]; then
        if [ "${whisper_stt_library}" = 'auto' ]; then
            # Default to faster whisper if model is selected
            whisper_stt_library='faster-whisper'
        fi
    fi
}

# Echo the backend the server will actually select for the configured language.
# Call whisper::resolve_options first.
#
# This asks the server's own guess_stt_library() instead of reimplementing it,
# so the per-language defaults -- English to sherpa, Russian to onnx-asr,
# Chinese/Cantonese/Japanese/Korean to FunASR -- cannot drift from upstream.
# Every backend is reported as available because the question being asked is
# which one *would* be chosen, which is the one that has to be installed.
#
# Only the configured language is answered for. Home Assistant can request any
# language at runtime through a second pipeline, and a language whose backend
# was never installed falls back to faster-whisper.
whisper::resolve_backend() {
    python3 - "${whisper_model}" "${whisper_stt_library}" \
        "$(bashio::config 'language')" <<'PY'
import sys

from wyoming_faster_whisper.const import AUTO_LANGUAGE, AUTO_MODEL, SttLibrary
from wyoming_faster_whisper.models import guess_stt_library

model, stt_library, language = sys.argv[1:4]

# The server maps both "auto" values to None before selecting.
print(
    guess_stt_library(
        SttLibrary(stt_library),
        None if model == AUTO_MODEL else model,
        None if language == AUTO_LANGUAGE else language,
        has_transformers=True,
        has_sherpa=True,
        has_onnx_asr=True,
        has_funasr=True,
        has_qwen3_asr=True,
    ).value
)
PY
}

# True if a module the "packs" service installs is importable.
#
# find_spec rather than an import: importing a backend pulls in its native
# libraries, and torch aborts at import time on some CPUs.
whisper::have_module() {
    python3 -c \
        "import importlib.util, sys; sys.exit(importlib.util.find_spec('${1}') is None)"
}

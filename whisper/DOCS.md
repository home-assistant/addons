# Home Assistant App: Whisper

## Installation

Follow these steps to get the app installed on your system:

1. In Home Assistant, go to **Settings** > **Apps** > **Install app**.
2. Find the "Whisper" app and click it.
3. Click on the "INSTALL" button.

## How to use

After this app is installed and running, it will be automatically discovered
by the Wyoming integration in Home Assistant. To finish the setup,
click the following my button:

[![Open your Home Assistant instance and start setting up a new integration.](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start/?domain=wyoming)

Alternatively, you can install the Wyoming integration manually, see the
[Wyoming integration documentation](https://www.home-assistant.io/integrations/wyoming/)
for more information.

## Configuration

### Option: `language`

Default language for the app. In Home Assist 2023.8+, multiple languages can be used simultaneously by different [Assist pipelines](https://www.home-assistant.io/voice_control/voice_remote_local_assistant/).

If you select "auto", the model will run **much** slower but will auto-detect the spoken language.

[Performance of supported languages](https://github.com/openai/whisper#available-models-and-languages)

[List of two-letter language codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)

### Option: `model`

Whisper model that will be used for transcription. Choose `custom` to use the model name in `custom_model`, which may be a HuggingFace model ID like "Systran/faster-distil-whisper-small.en".

The default model is "auto", which selects `tiny-int8` for ARM devices like the Raspberry Pi 4 and `base-int8` otherwise.
Compressed models (`int8`) are slightly less accurate than their counterparts, but smaller and faster. [Distilled](https://github.com/huggingface/distil-whisper) models are not compressed, but are faster and smaller than their non-distilled counterparts.

Available models:

- `auto` (select based on CPU)
- `tiny-int8` (compressed)
- `tiny`
- `tiny.en` (English only)
- `base-int8` (compressed)
- `base`
- `base.en` (English only)
- `small-int8` (compressed)
- `distil-small.en` (distilled, English only)
- `small`
- `small.en` (English only)
- `medium-int8` (compressed)
- `distil-medium.en` (distilled, English only)
- `medium`
- `medium.en` (English only)
- `large`
- `large-v1`
- `distil-large-v2` (distilled, English only)
- `large-v2`
- `distil-large-v3` (distilled, English only)
- `large-v3`
- `turbo` (faster than `large-v3`)

### Option: `custom_model`

Path to a converted model directory, or a CTranslate2-converted Whisper model ID from the HuggingFace Hub like "Systran/faster-distil-whisper-small.en".

If `custom_model_type` is set to `transformers`, a HuggingFace transformers Whisper model ID from HuggingFace like "openai/whisper-tiny.en" must be used.

If `custom_model_type` is set to `qwen3-asr`, an ONNX export of Qwen3-ASR must be used, such as "rhasspy/qwen3-asr-0.6b-onnx-int4" (the split-decoder export; the default is the merged one).

To use a local custom Whisper model, first create a `models` subdirectory in the app's configuration directory if it does not already exist. Then copy your model directory into:
`/addon_configs/core_whisper/models/<your-model-dir>`.
Then, set the `custom_model` path to:
`/config/models/<your-model-dir>`. For a local model, the path must start with `/config/models/`, as this is how the add-on accesses your Home Assistant configuration directory through the container's mounted volume.

### Option: `custom_model_type`

Determines which speech-to-text backend to use for `custom_model` if `stt_library` is set to "auto".

### Option: `beam_size`

Number of candidates to consider simultaneously during transcription (see [beam search](https://en.wikipedia.org/wiki/Beam_search)).
The default value of `0` will automatically select `1` of ARM devices like the Raspberry Pi 4 and `5` otherwise.

Increasing the beam size will increase accuracy at the cost of performance.

### Option: `initial_prompt`

Description of audio that can help Whisper transcribe unusual words better.
See [this discussion](https://github.com/openai/whisper/discussions/963) for an example.

### Option: `bias_names`

Bias transcription toward the names in your Home Assistant. This is disabled by default.

When enabled, the add-on reads the names of your [conversation-exposed entities][expose] — plus their aliases and the names of your areas and floors — and adds them to the initial prompt. A command that says one of those names is then much more likely to come back spelled the way you named it: "What's the temperature of the incubi?" becomes "What's the temperature of the Ecobee?".

Only names are read, and only to help recognize them; the add-on never calls a service or handles an intent.

Notes:

- Your `initial_prompt` is kept at the front of the prompt, so the two work together.
- Whisper's prompt only holds a few dozen names. If you expose more than that, areas and floors that hold something exposed come first, then the entities in the domains people say out loud (lights, switches, fans, media players, climate, scenes, todo lists), then everything else.
- Names are refreshed in the background while you are still speaking, so this does not add latency. If Home Assistant is slow or unreachable, the previous names are used and transcription still succeeds.
- Only backends that accept a prompt use the names: `faster-whisper`, `transformers`, and `qwen3-asr`. The `sherpa`, `onnx-asr`, and `funasr` backends ignore it.
- Do not use this with a `distil-*` model. Distil-Whisper was distilled without previous-text conditioning, so a prompt never helps it, and `distil-small.en` is actively damaged by a long one: from roughly 52 prompt tokens on, output that was correct unprompted comes back truncated ("Start a timer for 25 minutes" → "Start a timer.") or looping. The app warns at startup if you do this.

[expose]: https://www.home-assistant.io/voice_control/voice_remote_expose_devices/

### Option: `stt_library`

Speech-to-text backend library to use:

- `auto` - select the best backend based on language/hardware
- `faster-whisper` - force [faster whisper][faster-whisper] backend
- `sherpa` - force [sherpa onnx][sherpa-onnx] backend (parakeet, or a Kroko streaming model with `sherpa_streaming`)
- `transformers` - force [HuggingFace transformers][transformers] backend
- `onnx-asr` - force [onnx asr][onnx-asr] backend (GigaAM by default)
- `funasr` - force [funasr][] backend (SenseVoice by default)
- `qwen3-asr` - force [Qwen3-ASR][qwen3-asr] backend

**Note**: When `custom_model` is set, then `custom_model_type` will override `stt_library` when set to "auto".

**Note**: `transformers` and `funasr` are downloaded the first time your configuration selects one — see [Optional backends](#optional-backends) below.

**Note**: `auto` never selects `qwen3-asr`; it must be chosen explicitly. The default model is 785 MB, needs around 1.6 GB of RAM, and is slower than the per-language defaults above. What it buys you is much stronger biasing: `initial_prompt` and `bias_names` are fed to the model as a context prompt rather than as a Whisper-style prefix, which is the best option here for getting unusual entity names spelled correctly.

### Option: `whisper_task`

Task to perform with the model:

- `transcribe` - transcribe audio in the spoken language (default)
- `translate` - translate the spoken audio into English

### Option: `sherpa_streaming`

Use streaming model with `sherpa` backend.

This overrides the default parakeet model with a streaming Kroko zipformer, which returns results with lower latency. Defaults exist for English, German, Spanish and French (`sherpa-onnx-streaming-zipformer-<lang>-kroko-2025-08-06`); any other language falls back to the English model, so set `model` to "custom" and name one in `custom_model` instead.

### Option: `vad_endpointing`

Seconds of silence that end a voice command. This is unset by default.

Normally the app transcribes when the client tells it the command is over, which
is what Home Assistant does with its own voice activity detection. Set this to a
number of seconds instead — `0.7` is a reasonable starting point — and the app
detects the end of the command itself and sends the transcript immediately.

While this is set, the app advertises that it does not require external voice
activity detection, so Home Assistant leaves endpointing to it.

Notes:

- Speech has to be detected before the silence timer starts, pauses reset it
  when speech resumes, and a command always gets at least one second. Audio that
  arrives after the endpoint is ignored until the client finishes sending.
- Too low a value cuts people off mid-sentence; too high adds a delay to every
  command. Tune it rather than leaving it at the first number you try.
- This is independent of `vad_clip`, which trims silence off the audio before
  transcription. They can be used together.

### Option: `vad_clip`

Use voice activity detection (VAD) to clip silence from audio before transcription. This is disabled by default.

This is mainly a latency win for silence-heavy audio with length-proportional batch backends like `sherpa` and `funasr`; streaming backends are unaffected.

### Option: `hf_token`

A [Hugging Face access token][hf-token], used when downloading models. This is
unset by default.

You only need this for a model that is gated or private — one whose Hugging Face
page asks you to accept a licence or request access before the files can be
downloaded. Everything the app selects on its own is public, so leave this empty
unless you have pointed `custom_model` at a repository that needs it.

The token is set as `HF_TOKEN` for the app, and a read-only token is enough.

[hf-token]: https://huggingface.co/docs/hub/security-tokens

### Option: `local_files_only`

Only use models that have already been downloaded, and never check online for
updates.

Leave this off the first time you use a model so it can download. Once your
models are downloaded, turn it on to keep the add-on fully offline.

A model you already have is loaded from disk without contacting Hugging Face
either way, so this is no longer needed just to start without internet access.
What it adds is the guarantee: with it on, a model that is not cached is an
error rather than a surprise download.

If you turn this on before a model has been downloaded, transcription will fail
until you disable it again (or switch to a model you already have).

### Option: `debug_logging`

Print DEBUG level messages to the app's log. This is disabled by default.

Turn it on when you are working out why transcription is slow or wrong. It adds,
among other things:

- which backend and model were selected, and for which language
- how long each request took
- the initial prompt that was sent to the model
- what `/data` holds, including the size of each downloaded model

**Before sharing a debug log, read through it.** It is more revealing than the
normal one:

- With `bias_names` turned on, the prompt is logged, so the log contains the
  names of your exposed entities, areas and floors.
- The app's startup arguments are logged in full, and with `bias_names` turned
  on those include the Home Assistant token the app was given. Remove it before
  posting the log anywhere.

Your `hf_token` is not affected — it is passed through the environment rather
than the command line, so it is not logged.

## Optional backends

The `transformers` and `funasr` backends both need PyTorch, which together with
their own dependencies is around 1.5 GB. Neither is part of the app, because
most configurations never select one. When yours does, the app downloads what it
needs the first time it starts and keeps it in a cache on `/data`, so later
restarts take nothing from the network.

You do not turn this on: the app works out which backend your settings select
and installs for that one. Nothing is downloaded for the default configuration,
or for any language that uses faster-whisper, sherpa, onnx-asr or qwen3-asr.

What this means in practice:

- **The first start after selecting one of these backends is slow**, and needs
  internet access. It is logged while it happens.
- **If the download fails**, the app still starts and transcribes — it falls
  back to faster-whisper and logs a warning naming the backend it could not
  install. Restarting retries.
- **Only your configured `language` is accounted for.** If a second Assist
  pipeline asks for a language that would use a backend which was never
  installed — Chinese, Cantonese, Japanese or Korean on a `language` set to
  something else — that request falls back to faster-whisper. Set `stt_library`
  explicitly to force the backend you want for every language.
- **The cache is excluded from backups** and is rebuilt on demand. It is
  discarded automatically when an app update changes the Python or
  wyoming-faster-whisper series, so it cannot grow without bound.

## Backups

Whisper model files can be large, so they are automatically excluded from backups and re-downloaded on restore for remote models.
After restoring a backup with a local custom Whisper model, manually copy your model directory again.

The download caches (`hub`, `xet`, `modelscope`) are excluded too. They are
rebuilt on demand, and the Xet chunk cache in particular can run to several GB.

## Recommendations

A few starting points by language and priority. With `stt_library` = "auto" the
add-on selects a backend/model based on your `language` and hardware:

- **English** (`en`) → the parakeet model via the sherpa backend.
  `sherpa_streaming` swaps it for a faster streaming variant.
- **Chinese, Cantonese, Japanese, Korean** (`zh`, `yue`, `ja`, `ko`) → the
  SenseVoice model via the funasr backend. It is non-autoregressive and notably
  faster than Whisper while handling these languages well (locale codes like
  `zh-CN`/`zh-TW`/`zh-HK` are mapped automatically).
- **Russian** (`ru`) → the GigaAM model via the onnx-asr backend.
- **Everything else** → faster-whisper.

If entity names are what you keep having to repeat, `stt_library` = "qwen3-asr"
together with `bias_names` = true biases harder than any of the above, at the
cost of a larger model, more RAM, and more time per request.

Two tips for non-English use:

- Set `language` to your explicit language code. Leaving it as "auto" works but is
  **much** slower, since the model has to detect the language on every request.
- To get English text out of non-English speech, set `whisper_task` = "translate".
  This applies to the Whisper backends (not parakeet/sherpa, SenseVoice, or GigaAM).

- English
    - Balanced
        - `language` = "en"
        - `model` = "auto"
        - `stt_library` = "auto"
        - `sherpa_streaming` = false
    - Fast
        - `language` = "en"
        - `model` = "auto"
        - `stt_library` = "auto"
        - `sherpa_streaming` = true
    - Accurate
        - `language` = "en"
        - `model` = "custom"
        - `stt_library` = "onnx-asr"
        - `custom_model` = "istupakov/canary-1b-v2-onnx"
- Chinese / Cantonese / Japanese / Korean
    - Balanced (recommended)
        - `language` = "zh", "yue", "ja", or "ko"
        - `model` = "auto"
        - `stt_library` = "auto"
          (selects the SenseVoice model via funasr — fast and accurate for
          these languages)
- Non-English (other languages)
    - Balanced
        - `language` = your language code (e.g. "de", "fr")
        - `model` = "auto"
        - `stt_library` = "auto"
    - Fast
        - `language` = your language code
        - `model` = "base-int8" (or "small-int8" if your CPU allows)
        - `stt_library` = "faster-whisper"
    - Accurate
        - `language` = your language code
        - `model` = "custom"
        - `stt_library` = "onnx-asr"
        - `custom_model` = "istupakov/canary-1b-v2-onnx"
          (~25 European languages; needs a capable CPU, not a Raspberry Pi)

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[discord]: https://www.home-assistant.io/join-chat
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
[transformers]: https://huggingface.co/docs/transformers
[faster-whisper]: https://github.com/SYSTRAN/faster-whisper
[sherpa-onnx]: https://github.com/k2-fsa/sherpa-onnx
[onnx-asr]: https://github.com/istupakov/onnx-asr
[funasr]: https://github.com/modelscope/FunASR
[qwen3-asr]: https://huggingface.co/Qwen/Qwen3-ASR-0.6B

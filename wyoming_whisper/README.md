# Wyoming Whisper

Home Assistant add-on that uses [faster-whisper](https://github.com/guillaumekln/faster-whisper/) for speech to text.
Intended for use with the [wyoming](https://www.home-assistant.io/integrations/wyoming/) integration.

## Language

Make sure to select the appropriate language in the configuration. If you select "auto", the model will run **much** slower but will auto-detect the spoken language.

[List of two-letter language codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)


## Models

The default model is `tiny-int8`, a compressed version of the smallest Whisper model.
Compressed models (`int8`) are slightly less accurate than their counterparts, but smaller and faster.

Available models are sorted from least to most accurate.

* `tiny-int8` (43 MB)
* `tiny` (152 MB)
* `base-int8` (80 MB)
* `base` (291 MB)
* `small-int8` (255 MB)
* `small` (968 MB)
* `medium-int8` (786 MB)
* `medium` (3.1 GB)

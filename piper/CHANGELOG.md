# Changelog

## 1.6.0

- Add support for streaming audio on sentence boundaries

## 1.5.4

- Add voices for Dutch: ronnie, pim
- Add voice for English: sam
- Add voice for Persian/English: reza_ibrahim
- Add voice for Persian: ganji
- Add voices for Portuguese (Brazilian): cadu, jeff

## 1.5.2

- Add missing voices supported by Piper (gwryw_gogleddol, bryce, john, norman and paola)

## 1.5.1

- Add voice for English: cori

## 1.5.0

- Add voices for Persian: amir, gyro
- Add voice for Slovenian: artur
- Add voice for Turkish: fettah
- Add voices for French: tom, mls
- Add voice for Dutch: mls
- Add voice for German: mls

## 1.4.0

- Add voices for Arabic (kareem), Hungarian (imre), English (libritts_r), and more
- Fix error when voice contains UTF-8 character (quote url)
- Fix missing "dataset" key error
- Fix unnecessary downloads due to /share

## 1.3.2

- Add voices for Hungarian, Turkish, Portuguese, Slovak, and Czech
- Look for custom voices in `/share/piper`
- Add `upgrade_voices` and `debug_logging` options
- Upgrade to Debian bookworm

## 1.2.0

- Upgrade to Piper 1.2
- Add over 30 new voices
- Change voice format to `<language>_<REGION>-<name>-<quality>`
- Voices are downloaded from https://huggingface.co/rhasspy/piper-voices
- Add `max_piper_procs` option

## 0.1.3

- Fix multi-line input
- Verify voice hashes on download
- Add 4 Icelandic voices
    - `is-bui-medium`
    - `is-salka-medium`
    - `is-steinn-medium`
    - `is-ugla-medium`
- Add 1 Russian voice
    - `ru-irinia-medium`

## 0.1.2

- Update list of available voices

## 0.1.1

- Enable Wyoming protocol discovery

## 0.1.0

- Initial release

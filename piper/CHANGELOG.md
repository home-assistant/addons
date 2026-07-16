# Changelog

## 2.3.1

- Upgrade to `wyoming-piper` 2.3.1
- Add `sentence_silence` option to add silence after every sentence
- Add 3 new Ukrainian voices (`uk_UA-mykyta-high`, `uk_UA-oleksa-high`, `uk_UA-tetiana-high`)
- Add 3 new Telugu voices (`te_IN-maya-medium`, `te_IN-padmavathi-medium`, `te_IN-venkatesh-medium`)
- Add 2 new Greek voices (`el_GR-joy-medium`, `el_GR-rapunzelina-medium`)
- Add 2 new Basque voices (`eu_ES-antton-medium`, `eu_ES-maider-medium`)
- Add 1 new Bulgarian voice (`bg_BG-dimitar-medium`)
- Add 1 new English (US) voice (`en_US-mike-medium`)
- Add 1 new Spanish (Mexico) voice (`es_MX-ald-x_low`)
- Add 1 new Hindi voice (`hi_IN-rohan-medium`)
- Add 1 new Indonesian voice (`id_ID-news_tts-medium`)
- Add 1 new Kurdish voice (`ku_TR-berfin_renas-medium`)
- Add 1 new Dutch voice (`nl_NL-alex-medium`)
- Add 1 new Norwegian voice (`no_NO-nvcc-medium`)
- Add 1 new Polish voice (`pl_PL-bass-high`)
- Add 1 new Albanian voice (`sq_AL-edon-medium`)
- Add 1 new Swedish voice (`sv_SE-alma-medium`)
- Add 1 new Urdu voice (`ur_PK-fasih-medium`)

## 2.2.2

- Upgrade to `wyoming-piper` 2.2.2 (wheel fix)

## 2.2.1

- Upgrade to `wyoming-piper` 2.2.1
- Add support for new Chinese voices

## 2.1.1

- Upgrade to `wyoming-piper` 2.1.1
- Streaming is enabled by default (remove `streaming` option)
- Remove `max_piper_procs` option (no longer applicable)
- Drop support for `armv7`
- Fix zeroconf discovery

## 1.6.4

- Add missing voice for Argentinian Spanish (daniela)

## 1.6.3

- Bump wyoming to 1.7.2 to fix event data error

## 1.6.2

- Split sentences on numbered lists and remove asterisks surrounding words
- Remove asterisks at the start of a line (markdown list)
- Add new voices for Malayalam (arjun, meera)
- Add new voice for Nepali (chitwan)
- Add new voices for Hindi (pratham, priyamvada)
- Add new voice for Argentinian Spanish (daniela)

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

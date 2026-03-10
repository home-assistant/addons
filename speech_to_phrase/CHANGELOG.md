# Changelog

## 1.4.2

- Enhance Spanish speech recognition phrases
- Allow plural usage when asking about cover and lock states
- Fix formatting in Docker run command example
- Enhance German speech recognition phrases

## 1.4.1

- More robust parsing of `ask_question` answers from Home Assistant
- Remove intent probability normalization
- Revert to Kneser-Ney smoothing instead of Witten-Bell
- Re-add German timer sentences

## 1.4.0

- Load answers from `assist_satellite.ask_question` in automations and scripts
- Initial support for Catalan, Czech, Greek, Basque, Romanian, Portuguese, Russian, Polish, Hindi, Persian, Finnish, Mongolian, Slovenian, Swahili, and Turkish
- Rebalance sentence probabilities to reduce number confusion
- Timer minutes step by 5 instead of 10 after 20

## 1.3.0

- Add Coqui STT
- Support range fractions in custom sentences (https://github.com/OHF-Voice/speech-to-phrase/issues/5)
- Do full re-train at startup (https://github.com/OHF-Voice/speech-to-phrase/issues/11)
- Remove websocket command message limit (https://github.com/OHF-Voice/speech-to-phrase/issues/6)
- Bump `unicode-rbnf` to 2.3.0 (https://github.com/OHF-Voice/speech-to-phrase/issues/15)

## 1.2.0

- Split words on dashes `-` and underscores `_`
- Remove template syntax from names (`[]<>{}()`)

## 1.1.0

- Add custom sentences

## 1.0.0

- Initial release

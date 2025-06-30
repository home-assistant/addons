# Changelog

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

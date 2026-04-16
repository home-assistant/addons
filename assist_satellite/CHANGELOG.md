# Changelog

## 2.0.0 

### Migrate from wyoming satellite to [linux voice assistant](https://github.com/OHF-Voice/linux-voice-assistant)

- App renamed from "Assist Microphone" to "Assist Satellite"
- Replaced Wyoming satellite protocol with the ESPHome satellite protocol
  (linux-voice-assistant)
- Home Assistant now discovers the satellite via the ESPHome integration
  using built-in mDNS/zeroconf — no separate discovery step required
- Wake word detection now runs locally on-device using microWakeWord and
  openWakeWord models
- Added dual assistants with each wake word.
- Added support for selecting wake word model, audio devices, refractory
  period, and thinking sound via add-on configuration
- Added support for start/continue conversation.
- Added stop word for annoucements and timers
- Timer now stops automatically when the determined time (default: 15 mins) passes
  without manually stopping, instead of using the old number of repeats.
- Preferences (active wake word, volume) are persisted across restarts in
  `/share/assist_satellite/preferences.json`
- Custom wake word models downloaded from Home Assistant are stored in
  `/share/assist_satellite/local`
- Satellite name, mute switch, and thinking sound toggle are now exposed as
  entities in Home Assistant on the ESPHome device page
- Added new media player entity in Home Assistant on the ESPHome device
  with volume control (for both satellite and media player)

## 1.3.0

- Update to wyoming-satellite 1.3.0 to get support for timers
- Added configuration options for setting timer sound, repetitions and delay

## 1.2.0

- Update to wyoming-satellite 1.2.0

## 1.0.0

- Initial release


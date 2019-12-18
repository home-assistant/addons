# Hass.io Core Add-on: HomeMatic

HomeMatic central based on OCCU.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

This add-on allows you to control your HomeMatic devices so they can be
integrated into Home Assistant. It is based on the
[HomeMatic Open Central Control Unit (OCCU) SDK][occu].

Note: Requires a [HM-MOD-RPI-PCB][hm-mod-rpi-pcb] or [HmIP-RFUSB][hmip-rufsb]
to interface with your devices.

## Features

- Your Raspberry Pi is your HomeMatic control center!
- WebUI (experimental)
- Firmware updates

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "HomeMatic CCU" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. Properly configure the add-on config (see below).
2. Start the add-on.
3. Check the add-on log output to see if it started successfully.
4. Add homematic to your Home Assistant configuration (also see below).
5. Restart Home Assistant.

## Configuration

Add-on configuration:

```json
{
  "rf_enable": true,
  "rf": [
    {
      "type": "CCU2",
      "device": "/dev/ttyAMA0"
    }
  ],
  "wired_enable": false,
  "wired": [
    {
      "serial": "xy",
      "key": "abc",
      "ip": "192.168.0.0"
    }
  ],
  "hmip_enable": false,
  "hmip": [
    {
      "type": "HMIP_CCU2",
      "device": "/dev/ttyUSB0"
    }
  ]
}
```

### Option: `rf_enable` (required)

Enable or disable BidCoS-RF.

### Option: `rf`

List of RF devices.

#### Option: `rf.type` (required)

Device type for RFD service. Check your device manual.

#### Option: `rf.device` (required)

Device on the host.

### Option: `wired_enable` (required)

Enable or disable BidCoS-Wired.

### Option: `wired`

List of wired devices.

#### Option: `wired.serial` (required)

Serial number of the device.

#### Option: `wired.key` (required)

Encryption key for the device.

#### Option: `wired.ip` (required)

IP address of LAN gateway.

### Option: `hmip_enable` (required)

Enable or disable hmip.

### Option: `hmip`

List of HMIP devices.

#### Option: `hmip.type` (required)

Device type for HMIP service. Check your device manual.

#### Option: `hmip.device` (required)

Device on the host.

## Home Assistant configuration

Add the following to your Home Assistant configuration to enable
the integration:

```yaml
homematic:
  interfaces:
    rf:
      host: core-homematic
      port: 2001
    wired:
      host: core-homematic
      port: 2000
    hmip:
      host: core-homematic
      port: 2010
```

## Raspberry Pi3

If you use the HM-MOD-RPI-PCB on a Raspberry Pi 3, you need to add
the following to the `config.txt` file on the boot partition:

```text
dtoverlay=pi3-miniuart-bt
```

## HmIP-RFUSB

HassOS versions 1.11 and later support the HmIP-RFUSB by default and don't need any
configuration. If you installed Hassio on another distribution of Linux, you need to
follow the installation guide for the UART USB to setup the UART USB interface on
your computer.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[aarch64-shield]: https://img.shields.io/badge/aarch64-no-red.svg
[amd64-shield]: https://img.shields.io/badge/amd64-no-red.svg
[armhf-shield]: https://img.shields.io/badge/armhf-no-red.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
[screenshot]: https://github.com/home-assistant/hassio-addons/raw/master/configurator/images/screenshot.png
[occu]: https://github.com/jens-maus/occu/
[hm-mod-rpi-pcb]: https://www.elv.ch/homematic-funkmodul-fuer-raspberry-pi-bausatz.html
[hmip-rufsb]: https://www.elv.ch/elv-homematic-ip-rf-usb-stick-hmip-rfusb-fuer-alternative-steuerungsplattformen-arr-bausatz.html

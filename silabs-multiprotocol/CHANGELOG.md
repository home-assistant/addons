# Changelog

## 0.8.0

- Initial AMD64/x86-64 support (zigbeed via QEMU)
- Increase multicast table size to 16 (as expected by ZHA by default)

## 0.7.2

- Fix OTBR enable flag (allow to disable the OTBR)
- Fix zigbeed and cpcd finish scripts
- Start banner after initialization scripts

## 0.7.1

- Bump universal SiLabs flasher to 0.0.7
- Use baudrate 115200 by default
- Add Docker health check to monitor zigbeed

## 0.7.0

- Support firmware flashing for Home Assistant SkyConnect/Yellow
- Allow quick reconnects by ZHA (required during config flow)

## 0.6.2

- Use Silicon Labs Gecko SDK 4.1.3

## 0.6.1

- Use Silicon Labs Gecko SDK 4.1.2

## 0.6.0

- Implement native TCP/IP support for zigbeed (requires bellows 0.34.0 or newer)
- Bind only to add-ons local address

## 0.5.1

- Use Silicon Labs Gecko SDK 4.1.1
- Readd aarch64 support

## 0.5.0

- Use Silicon Labs Gecko SDK 4.1.0
- Build zigbeed from source (as binaries are no longer provided)
- Bump OTBR to Silicon Labs forked version of Gecko SDK v4.1.0
  (based on OTBR POSIX version 3a98779dc9 (2022-06-02 09:34:58 -0700))
- Use s6-overlay v3 style services
- Drop aarch64 support (all CPC communication blocks on aarch64 since 4.1.0)

## 0.4.1

- Support network device (CPC daemon via TCP/IP socket)

## 0.4.0

- Use Silicon Labs Gecko SDK 4.0.2
- Enable native aarch64 support
- Support baudrate and hardware flow control

## 0.3.1

- Fix permissions to make otbr-agent start correctly
- Add OpenThread Border Router web frontend via ingress

## 0.3.0

- Initial OpenThread support

## 0.2.0

- Use Silicon Labs Gecko SDK 4.0.1
- Fix port description

## 0.1.0

- initial version

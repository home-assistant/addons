# Changelog

## 2.4.5

- Set default transmit power on startup
- Enable DNS when NAT64 is enabled
- Bump universal SiLabs flasher to 0.0.17

## 2.4.4

- Fix Thread network interface (wpan0) route metric
  This fixes devices becoming unreachable when operating the OTBR with other TBRs
- Bump to OTBR POSIX version 02421b0ea6 (2024-01-19 15:58:03 -0800)

## 2.4.3

- Enable TREL support on infrastructure link
- Enable Channel Monitor support (disabled by default)
- Bump to OTBR POSIX version 657e775cd9 (2024-01-05 17:10:13 -0800)

## 2.4.2

- Update firmare for Home Assistant SkyConnect and Yellow to the latest version
  built from Gecko SDK v4.4.0.0.
- Bump universal SiLabs flasher to 0.0.16

## 2.4.1

- Fix NAT64 enable script

## 2.4.0

- Enable TREL
- Enable NAT64 (disabled by default)
- Bump to OTBR POSIX version 27ed99f375 (2023-12-13 10:11:52 -0800)
- Bump universal SiLabs flasher to 0.0.15
- Shutdown add-on on otbr-agent crash (use Supervisor Watchdog functionality
  for automatic restarts)

## 2.3.2

- Bump to OTBR POSIX version 9e50efa8de (2023-08-23 21:28:30 -0700)
  This updates mDNSResponder to 1790.80.10

## 2.3.1

- Update firmare for Home Assistant SkyConnect and Yellow to the latest version
  built from Gecko SDK v4.3.1.0.

## 2.3.0

- Bump to OTBR POSIX version 8d12b242db (2023-07-13 20:00:34 +0200)
  This update includes the new REST API to reset the OTBR
- Bump universal SiLabs flasher to 0.0.13
- Use add-on hostname to connect to OTBR REST API

## 2.2.0

- Update firmare for Home Assistant SkyConnect and Yellow to the latest version
  built from Gecko SDK v4.3.0.0.

## 2.1.0

- Add REST API patches to fix a bugs and support deleting datasets

## 2.0.0

- Bump to OTBR POSIX version f46f68956b (2023-05-23 09:28:30 -0700)
  This update includes the new REST API part of upstream OTBR

## 1.2.0

- Fix firmware flashing on Home Assistant Yellow
- Bump universal SiLabs flasher to 0.0.12
- Bump to OTBR POSIX version cbeaf817c5 (2023-03-29 11:06:31 -0700)
- Don't start Web interface unnecessarily

## 1.1.0

- Automatically flash firmware for Home Assistant SkyConnect and Yellow
- Update serial port defaults to match latest firmware builds
- Drop armv7 support

## 1.0.0

- Bump to OTBR POSIX version d83fee189a (2023-02-28 08:48:56 -0800)
- Remove Web UI via ingress (expose ports to use the Web UI, see documentation)
- Change vendor name to "Home Assistant" and product name to Silicon Labs
  Multiprotocol" (used in OTBR mDNS/DNS-SD announcments)
- Set default baudrate 115200 correctly
- Let the OTBR REST API listen on local interface only by default
- Fix REST API to correctly set the Connection HTTP header
- Fix REST API to return an HTTP compliant status line
- Add OTBR discovery support

## 0.3.0

- Bump to OTBR POSIX version 079bbce34a (2022-12-22 19:00:41 -0800)
- Add REST API with full active and pending dataset as well as state support
- Avoid start error in case multiple primary interfaces are returned
- Add fine grained OTBR log level control
- Fix service stop (finish) scripts

## 0.2.6

- Accept IPv6 forwarding explicitly (required for HAOS 9.x)
- Add egress firewall rules for forwarding if firewall is enabled

## 0.2.5

- Bump to OTBR POSIX version 110eb2507c (2022-11-24 14:36:14 -0800)

## 0.2.4

- Bump to OTBR POSIX version 0e15296792 (2022-11-07 12:33:00 +0100)

## 0.2.3

- Fix Firewall shutdown

## 0.2.2

- Bump to OTBR POSIX version 9fea68cfbe (2022-06-03 11:53:19 -0700)
- Use s6-overlay v3 style services

## 0.2.1

- Fix missing common script

## 0.2.0

- Support OpenThread Border Router firewall to avoid unnecessary traffic in the
  OpenThread network.

## 0.1.4

- Enable OpenThread diagnostic mode

## 0.1.3

- Fix startup without hardware flow control

## 0.1.2

- Bump OTBR to ot-br-posix git f8399eb08/openthread git 7dfde1f12

## 0.1.1

- Add baudrate and hardware flow control configurations

## 0.1.0

- initial version

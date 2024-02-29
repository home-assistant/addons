# Changelog

## 5.3.0

- Bump Python Matter Server to [5.7.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.7.0)
- Add Matter SDK log options

## 5.2.0

- Bump Python Matter Server to [5.6.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.6.0)

## 5.1.2

- Bump Python Matter Server to [5.5.3](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.5.3)

## 5.1.1

- Bump Python Matter Server to [5.5.2](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.5.2)

## 5.1.0

- Bump Python Matter Server to [5.5.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.5.1)
- Bind Python WebSocket on internal interface only by default

## 5.0.4

- Correctly bump Python Matter Server to [5.2.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.2.1)

## 5.0.3

- Bump Python Matter Server to [5.2.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.2.1)
- Pass primary interface to Python Matter server

## 5.0.2

- Bump Python Matter Server to [5.1.4](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.1.4)

## 5.0.1

- Bump Python Matter Server to [5.0.3](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.0.3)
- Fix matter-server finish script to report exit code
- Attach gdb debugger in beta mode to print stack traces on crash

## 5.0.0

- Bump Python Matter Server to [5.0.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/5.0.1)
- Bump minimum required Home Assistant core version to 2023.12 due to breaking changes in the schema

## 4.10.2

- Bump Python Matter Server to [4.0.2](https://github.com/home-assistant-libs/python-matter-server/releases/tag/4.0.2)

## 4.10.1

- Bump Python Matter Server to [4.0.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/4.0.1)

## 4.10.0

- Add beta flag to the add-on which installs Python Matter Server pre-releases at startup.

## 4.9.0

- Bump Python Matter Server to [3.7.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.7.0)

## 4.8.3

- Bump Python Matter Server to [3.6.4](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.6.4)

## 4.8.2

- Bump Python Matter Server to [3.6.3](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.6.3)

## 4.8.1

- Bump Python Matter Server to [3.6.2](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.6.2)

## 4.8.0

- Bump Python Matter Server to [3.6.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.6.1)

## 4.7.0

- Use the Python Matter Server container as base
- Bump Python Matter Server to [3.5.2](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.5.2)

## 4.6.1

- Bump Python Matter Server to [3.5.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.5.1)
  - Various small bug/stability fixes

## 4.6.0

- Bump Python Matter Server to [3.5.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.5.0)
  - Uses libnl based address selection to avoid using deprecated/temporary IP addresses
  - libnl avoids "Endpoint pool full" errors as well
- Add dependency to support libnl based IP address selection

## 4.5.1

- Bump Python Matter Server to [3.4.2](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.4.2)

## 4.5.0

- Bump Python Matter Server to [3.4.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.4.1)
- Bump to Python 3.11

## 4.4.0

- Bump Python Matter Server to [3.4.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.4.0)
  - This updates Matter to 1.1
- Update S6 Overlay to v3.1.5.0

## 4.3.1

- Bump Python Matter Server to [3.3.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.3.1)

## 4.3.0

- Bump Matter Server to [3.3.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.3.0)

## 4.2.0

- Bump Matter Server to [3.2.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.2.0)
- Significantly reduced add-on size

## 4.1.0

- Bump Matter Server to [3.1.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.1.0)

## 4.0.0

- Bump Matter Server to [3.0.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/3.0.0)

## 3.1.0

- Use Python 3.10

## 3.0.4

- Bump Matter Server to [2.1.1](https://github.com/home-assistant-libs/python-matter-server/releases/tag/2.1.1)
- Drop unnecessary Python dependencies from image

## 3.0.3

- Bump Matter Server to [2.1.0](https://github.com/home-assistant-libs/python-matter-server/releases/tag/2.1.0)

## 3.0.2

- Bump Matter Server to [2.0.2](https://github.com/home-assistant-libs/python-matter-server/releases/tag/2.0.2)

## 3.0.1

- Bump Matter Server fabric ID after changing vendor ID

## 3.0.0

- Bump Matter Server to 2.0.1
- Use Nabu Casa Vendor ID by default

### Breaking

- All commissioned devices need to be recommissioned.

## 2.1.0

- Bump Matter Server to 1.1.0

## 2.0.0

- Require Home Assistant Core 2023.1.0b1 to install the add-on. The chip SDK was bumped in [Matter Server 1.0.8](https://github.com/home-assistant-libs/python-matter-server/releases/tag/1.0.8).

## 1.2.0

- Bump Matter Server to 1.0.8
- Bump pre-built Matter SDK wheels to 2022.12.0
- Make sure production PAA certificates work too

## 1.1.2

- Get most recent certificates from master branch

## 1.1.1

- Fix startup when Matter Server WebSocket port is not exposed

## 1.1.0

- Allow to set Matter Server logging level
- Set storage path correctly
- Fix support for custom port

## 1.0.7

- Bump Matter Server to 1.0.7

## 1.0.6

- Bump Matter Server to 1.0.6

## 1.0.5

- Bump Matter Server to 1.0.5

## 1.0.4

- Bump Matter Server to 1.0.4

## 1.0.1

- Bump Matter Server to 1.0.1
- Use pre-built Matter SDK (CHIP) wheels

## 0.4.0

- Add add-on discovery

## 0.3.0

- Bump to CHIP version 989ad8e (2022-09-16 16:52 -0500) (start of the v1 branch!)
- Bump Matter Server to 0.3.0

## 0.2.2

- Bump to CHIP version 5b603f3874 (2022-07-05 21:21:19 -0700)
- Bump Matter Server to 0.2.3
- Avoid cloning not required git repositories during build speedup build process

## 0.2.1

- Bump Matter Server to 0.2.2

## 0.2.0

- Bump to CHIP version 5d8599d195 (2022-06-09 12:57:45 -0400)
- Bump Matter Server to 0.2.1

## 0.1.2

- Bump Matter Server to first official release 0.1.0

## 0.1.1

- Fix Matter Server start location so it can find device certificates
- Bump Matter Server to git version ac5545b (2022-06-11 00:04:34 +0200)

## 0.1.0

- initial version
- CHIP version 55ab764bea (2022-06-06 23:10:48 -0400)

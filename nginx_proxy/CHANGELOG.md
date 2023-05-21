# Changelog

## 3.5.0

- Update Alpine to 3.18 (nginx 1.24.x)

## 3.4.2

- Decrease crond log level

## 3.4.1

- Avoid logging to system console

## 3.4.0

- Add X-Forwarded-Host to fix origin issues affecting VSCode and other addons

## 3.3.0

- Check certificate renewal daily and reload nginx if necessary
- Migrate add-on layout to S6 Overlay

## 3.2.0

- Update Alpine to 3.16 (nginx 1.22.x)

## 3.1.5

- Fixed container environment

## 3.1.4

- Fixed init config

## 3.1.3

- Reject SSL on unknown domains instead of responding with an invalid certificate

## 3.1.2

- Fix TLSv1.3 support

## 3.1.1

- Hide server version banner

## 3.1.0

- Allow use of ports other than 8123 in Home Assistant Core

## 3.0.2

- Update Alpine to 3.14
- Use images from ghcr

## 3.0.1

- Fix the use of subfolders with certificate files

## 3.0

- Update Alpine to 3.11
- Use mozilla Recommended SSL settings

## 2.6

- Remove ipv6 listener because we run only inside virtual network on a ipv4 range

## 2.5

- Migrate to Bashio

## 2.4

- Added Cloudflare mechanism for creating auto-generated ipv4/ipv6 list for real visitor ip

## 2.3

- Fix issue with nginx warning for ssl directive

## 2.2

- Fix issue with `homeassistant` connection
- Update nginx to version 1.16.1

## 2.1

- Update nginx to version 1.14.2

## 2.0

- Update nginx to version 1.14.0

## 1.2

- Modify `server_names_hash_bucket_size` to add support for longer domain names

## 1.1

- Update run.sh info messages
- Make HSTS configurable and optional

## 1.0

- Add customization mechanism using included config snippets from /share
- Optimize logo.png
- Update base image

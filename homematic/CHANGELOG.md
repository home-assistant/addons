# Changelog

## 11.2.2

- Revert restart nginx service on error

## 11.2.1

- Restart nginx service on error

## 11.2.0

- Update OCCU to 3.55.10

## 11.1.0

- Migrate OCCU back to EQ3
- Use Home helper again
- Update hardware configuration for Supervisor 2021.02.5

## 11.0.6

- Persist groups

## 11.0.5

- Skip HmIP firmware update for udev path
- Persist certificate

## 11.0.4

- Fix template for hmip

## 11.0.3

- Fix Ingress path

## 11.0.2

- Fix issue with library
- Take container down on ReGaHss error

## 11.0.1

- Small cleanup with s6-overlay

## 11.0.0

- Migrate to s6-overlay & tempio
- Update OCCU to 3.55.5-1

## 10.3.0

- Flush ReGaHss config on shutdown
- Add ReGaHss reset option

## 10.2.0

- Update Bashio to fix the wait function
- Extend the log output

## 10.1.0

- Fix issue with SSL

## 10.0.0

- Add Ingress support
- Disable external ports per default
- Fix wrong version number
- Speedup start without sleeps

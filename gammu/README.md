# Home Assistant Add-on: Gammu SMS Gateway

![Supports aarch64](https://img.shields.io/badge/aarch64-yes-green.svg)  
![Supports amd64](https://img.shields.io/badge/amd64-yes-green.svg)  
![Supports armhf](https://img.shields.io/badge/armhf-yes-green.svg)  
![Supports armv7](https://img.shields.io/badge/armv7-yes-green.svg)  
![Supports i386](https://img.shields.io/badge/i386-yes-green.svg)

## 📦 Features

- Send SMS using HTTP POST requests
- Polls GSM modem for inbound messages
- Webhook forwarding (default: `/api/webhook/sms`) for automation
- REST endpoints for modem diagnostics
- Powered by [py-smsgateway-async](https://pypi.org/project/py-smsgateway-async/)

## 🧰 Description

This add-on integrates a USB GSM modem into Home Assistant using Gammu and [py-smsgateway-async](https://pypi.org/project/py-smsgateway-async/), an asynchronous Python microservice that provides a REST API and webhook delivery for SMS communication.

## ⚙️ Configuration

Example config:

```yaml
device: "/dev/ttyUSB0"
baudspeed: "at115200"
poll_interval: 10
webhook_url: ""
webhook_token: ""
```

| Option          | Required | Description                                               |
|-----------------|----------|-----------------------------------------------------------|
| `device`        | ✅       | Serial path to your GSM modem (e.g. `/dev/ttyUSB0`)       |
| `baudspeed`     | ✅       | Connection string for Gammu (e.g. `at115200`)             |
| `poll_interval` | ❌       | Frequency (in seconds) to check modem for new messages    |
| `webhook_url`   | ❌       | URL to post incoming SMS to (defaults to Home Assistant)  |
| `webhook_token` | ❌       | Optional bearer token used in outbound webhook requests   |

## 🔁 Webhook Behavior

When an SMS is received, it will be forwarded as a POST request to the configured `webhook_url` (or to Home Assistant's default webhook if not set):

```json
{
  "phone": "+15559876543",
  "date": "2025-06-22T19:42:00",
  "message": "Hello from Gammu!"
}
```

## 🧪 API Endpoints

By default, the add-on exposes the following API on port `3050` inside the container:

| Method | Endpoint        | Description             |
|--------|-----------------|-------------------------|
| POST   | `/api/sms/send` | Send a new SMS message  |
| GET    | `/api/sms/info` | Query modem diagnostics |

You can use these endpoints locally from Home Assistant, or externally via port mapping or reverse proxy.

## 🛠 Troubleshooting

- Run `dmesg | grep tty` to determine which device your modem is on.
- Check add-on logs for errors related to connection, polling, or delivery.
- If using webhook forwarding, ensure that Home Assistant's webhook handler (`/api/webhook/sms`) is properly configured with an automation.

## 📄 License

MIT License

## 🙋 Support

- [GitHub Issues](https://github.com/YOUR-USERNAME/homeassistant-addons/issues)
- [Home Assistant Forum](https://community.home-assistant.io)
- [py-smsgateway-async on PyPI](https://pypi.org/project/py-smsgateway-async/)

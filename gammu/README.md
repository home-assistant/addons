# 📲 Home Assistant Add-on: Gammu SMS Gateway

A lightweight Home Assistant add-on that enables GSM modem-based SMS communication using [Gammu](https://wammu.eu/gammu/). Useful for receiving alerts, sending automations via SMS, or integrating with non-internet-connected systems.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

---

## 🚀 Features

- 📤 Send SMS using REST API
- 📥 Receive and decode incoming SMS messages
- 🔁 Periodically polls the modem for new messages
- 📶 Report device IMEI, signal strength, firmware, and operator info
- 🌐 Optional webhook forwarding of inbound messages
- 🐳 Fully containerized Home Assistant add-on

---

## 🧰 Installation

1. Navigate to **Settings → Add-ons → Add-on Store** in Home Assistant.
2. Click on **“Repositories”** and add this GitHub repo:
   ```
   https://github.com/YOUR-USERNAME/homeassistant-addons
   ```
3. Find and install **“Gammu SMS Gateway”** from the newly added repo.
4. Plug in your USB GSM modem (e.g., `/dev/ttyUSB0`).
5. Start the add-on and monitor the logs for success.

---

## ⚙️ Configuration

Example `configuration.yaml` for the add-on:

```yaml
device: "/dev/ttyUSB0"
baudspeed: "at115200"
```

| Key         | Required | Example       | Description                          |
|-------------|----------|---------------|--------------------------------------|
| `device`    | ✅       | `/dev/ttyUSB0`| Path to your GSM modem serial port   |
| `baudspeed` | ✅       | `at115200`    | Baudrate/connection string for modem |

---

## 🌐 API Access

Once the add-on is running, it exposes a REST API on port `3050` inside the container.

### `POST /api/sms/send`

Sends an SMS using the connected modem.

```json
{
  "number": "+15551234567",
  "text": "Hello from Home Assistant!"
}
```

### `GET /api/sms/info`

Retrieves modem and network details.

---

## 🔁 Incoming Webhooks

If `WEBHOOK_URL` is configured, incoming SMS messages will be forwarded like this:

```json
{
  "phone": "+15559876543",
  "date": "2025-06-22 11:30:00",


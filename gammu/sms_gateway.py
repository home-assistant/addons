#!/usr/bin/env python3
"""
SMS Gateway to interact with a GSM modem as a Home Assistant add‐on.

This code runs in a Docker container without direct access to Home Assistant’s
core. It reads configuration from environment variables and uses the Home 
Assistant webhook to forward incoming SMS messages.

Environment variables:
  • HASS_URL – Full URL to Home Assistant (default: "http://homeassistant:8123")
  • HASS_TOKEN – (Optional) long‑lived access token for Home Assistant API.
  • GSM_DEVICE – Path to your GSM modem device (default: "/dev/ttyUSB0")
  • GSM_CONNECTION – Connection string (default: "at115200")
  • POLL_INTERVAL – (Optional) Polling interval in seconds (default: 10)

Incoming messages with SMS_STATE "UnRead" are forwarded via an HTTP POST to:
      HASS_URL/api/webhook/sms

Additionally, the script exposes the following REST endpoints on port 3000:
  • POST /api/sms/send – Send an SMS message.
       JSON payload must include "number" and "text".
  • POST /api/sms/receive – Manually trigger a poll for incoming SMS messages.
  • GET  /api/sms/info – Retrieve modem properties (manufacturer, model, firmware, etc.).
"""

import asyncio
import logging
import os
import aiohttp
from aiohttp import web

import gammu
from gammu.asyncworker import GammuAsyncWorker

# Configure logging
logging.basicConfig(level=logging.DEBUG)
_LOGGER = logging.getLogger("sms_gateway")

# Constants and configuration
SMS_STATE_UNREAD = "UnRead"
# Home Assistant webhook configuration (outgoing)
HASS_URL = os.getenv("HASS_URL", "http://homeassistant:8123")
HASS_TOKEN = os.getenv("HASS_TOKEN")  # Optional
WEBHOOK_ID = "sms"  # Home Assistant’s expected webhook id for SMS
# GSM modem configuration from environment or defaults.
GSM_CONFIG = {
    "Device": os.getenv("GSM_DEVICE", "/dev/ttyUSB0"),
    "Connection": os.getenv("GSM_CONNECTION", "at115200"),
}
# Poll interval (in seconds)
POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", "10"))


class Gateway:
    """SMS gateway to interact with a GSM modem."""

    def __init__(self, config):
        _LOGGER.debug("Initializing Gateway using connection mode: %s", config["Connection"])
        self._worker = GammuAsyncWorker(self.sms_pull)
        self._worker.configure(config)
        self._first_pull = True

    async def init_async(self):
        """Initialize the SMS gateway asynchronously."""
        await self._worker.init_async()
        _LOGGER.debug("Gateway initialized")

    def sms_pull(self, state_machine):
        """Poll the modem and process incoming messages."""
        state_machine.ReadDevice()
        _LOGGER.debug("Polling modem for SMS...")
        self.sms_read_messages(state_machine, self._first_pull)
        self._first_pull = False

    def sms_read_messages(self, state_machine, force=False):
        """Process all received SMS messages from the modem."""
        entries = self.get_and_delete_all_sms(state_machine, force)
        _LOGGER.debug("Found SMS entries: %s", entries)
        for entry in entries:
            decoded_entry = gammu.DecodeSMS(entry)
            message = entry[0]
            _LOGGER.debug("Processing SMS: %s, decoded: %s", message, decoded_entry)
            if message["State"] == SMS_STATE_UNREAD:
                if decoded_entry is None:
                    text = message.get("Text", "")
                else:
                    text = ""
                    for inner_entry in decoded_entry["Entries"]:
                        if inner_entry["Buffer"] is not None:
                            text += inner_entry["Buffer"]
                event_data = {
                    "phone": message["Number"],
                    "date": str(message["DateTime"]),
                    "message": text,
                }
                _LOGGER.debug("Forwarding event data: %s", event_data)
                # Forward each SMS message via the Home Assistant webhook.
                asyncio.create_task(self._notify_incoming_webhook(event_data))

    def get_and_delete_all_sms(self, state_machine, force=False):
        """Read and delete all SMS messages from the modem."""
        memory = state_machine.GetSMSStatus()
        remaining = memory["SIMUsed"] + memory["PhoneUsed"]
        start_remaining = remaining
        entries = []
        start = True
        all_parts = -1
        _LOGGER.debug("Starting SMS read; remaining messages: %i", start_remaining)
        try:
            while remaining > 0:
                if start:
                    entry = state_machine.GetNextSMS(Folder=0, Start=True)
                    all_parts = entry[0]["UDH"]["AllParts"]
                    part_number = entry[0]["UDH"]["PartNumber"]
                    part_is_missing = all_parts > start_remaining
                    _LOGGER.debug("All parts: %i, Part number: %i, Remaining: %i, Part missing: %s",
                                  all_parts, part_number, remaining, part_is_missing)
                    start = False
                else:
                    entry = state_machine.GetNextSMS(Folder=0, Location=entry[0]["Location"])
                if part_is_missing and not force:
                    _LOGGER.debug("Not all parts arrived; aborting read")
                    break
                remaining -= 1
                entries.append(entry)
                _LOGGER.debug("Deleting SMS at location: %s", entry[0]["Location"])
                try:
                    state_machine.DeleteSMS(Folder=0, Location=entry[0]["Location"])
                except gammu.ERR_MEMORY_NOT_AVAILABLE:
                    _LOGGER.error("Error deleting SMS, memory not available")
        except gammu.ERR_EMPTY:
            _LOGGER.warning("No SMS messages found")
        return gammu.LinkSMS(entries)

    async def _notify_incoming_webhook(self, message):
        """Forward the incoming SMS message to Home Assistant via its webhook."""
        webhook_url = f"{HASS_URL}/api/webhook/{WEBHOOK_ID}"
        headers = {"Content-Type": "application/json"}
        if HASS_TOKEN:
            headers["Authorization"] = f"Bearer {HASS_TOKEN}"
        try:
            async with aiohttp.ClientSession() as session:
                async with session.post(webhook_url, json=message, headers=headers) as resp:
                    if resp.status != 200:
                        _LOGGER.warning("Webhook POST returned HTTP %s", resp.status)
        except Exception as e:
            _LOGGER.error("Failed to notify incoming SMS webhook: %s", e)

    async def send_sms_async(self, message):
        """Send an SMS message via the asynchronous worker."""
        return await self._worker.send_sms_async(message)

    async def get_imei_async(self):
        """Get the IMEI of the device."""
        return await self._worker.get_imei_async()

    async def get_signal_quality_async(self):
        """Get the current signal level of the modem."""
        return await self._worker.get_signal_quality_async()

    async def get_network_info_async(self):
        """Get the current network info of the modem."""
        network_info = await self._worker.get_network_info_async()
        if not network_info["NetworkName"]:
            network_info["NetworkName"] = gammu.GSMNetworks.get(network_info["NetworkCode"])
        return network_info

    async def get_manufacturer_async(self):
        """Retrieve the manufacturer of the modem."""
        return await self._worker.get_manufacturer_async()

    async def get_model_async(self):
        """Retrieve the model of the modem."""
        model = await self._worker.get_model_async()
        if not model or not model[0]:
            return None
        display = model[0]
        if model[1]:
            display = f"{display} ({model[1]})"
        return display

    async def get_firmware_async(self):
        """Retrieve the firmware information of the modem."""
        firmware = await self._worker.get_firmware_async()
        if not firmware or not firmware[0]:
            return None
        display = firmware[0]
        if firmware[1]:
            display = f"{display} ({firmware[1]})"
        return display

    async def terminate_async(self):
        """Terminate modem connection."""
        return await self._worker.terminate_async()


# ---------------- REST API using aiohttp ----------------

# Create the global Gateway instance.
gateway = Gateway(GSM_CONFIG)

async def send_sms(request):
    """
    POST /api/sms/send
    Expected JSON payload:
      {
        "number": "+1234567890",
        "text": "Hello from the gateway!"
      }
    """
    try:
        payload = await request.json()
        sms_data = {
            "Text": payload["text"],
            "Number": payload["number"],
            "SMSC": {"Location": 1},
        }
        await gateway.send_sms_async(sms_data)
        return web.json_response({"status": "SMS sent"})
    except Exception as e:
        _LOGGER.error("Failed to send SMS: %s", e)
        return web.json_response({"error": str(e)}, status=500)

async def trigger_receive(request):
    """
    POST /api/sms/receive
    Manually trigger a poll for incoming SMS messages.
    """
    try:
        gateway.sms_pull(gateway._worker.state_machine)
        return web.json_response({"status": "Polled for SMS messages"})
    except Exception as e:
        _LOGGER.error("Failed to poll SMS messages: %s", e)
        return web.json_response({"error": str(e)}, status=500)

async def get_info(request):
    """
    GET /api/sms/info
    Retrieve modem properties (manufacturer, model, firmware, etc.)
    """
    try:
        manufacturer = await gateway.get_manufacturer_async()
        model = await gateway.get_model_async()
        firmware = await gateway.get_firmware_async()
        imei = await gateway.get_imei_async()
        signal_quality = await gateway.get_signal_quality_async()
        network_info = await gateway.get_network_info_async()
        return web.json_response(
            {
                "manufacturer": manufacturer,
                "model": model,
                "firmware": firmware,
                "imei": imei,
                "signal_quality": signal_quality,
                "network_info": network_info,
            }
        )
    except Exception as e:
        _LOGGER.error("Failed to get modem info: %s", e)
        return web.json_response({"error": str(e)}, status=500)

def create_app():
    app = web.Application()
    app.add_routes([
        web.post("/api/sms/send", send_sms),
        web.post("/api/sms/receive", trigger_receive),
        web.get("/api/sms/info", get_info),
    ])
    return app

async def polling_loop():
    """Continuously poll the GSM modem every POLL_INTERVAL seconds."""
    while True:
        try:
            gateway.sms_pull(gateway._worker.state_machine)
        except Exception as e:
            _LOGGER.error("Error while polling: %s", e)
        await asyncio.sleep(POLL_INTERVAL)

async def init_gateway():
    """Initialize the gateway asynchronously."""
    try:
        await gateway.init_async()
        _LOGGER.info("Gateway is ready")
    except Exception as e:
        _LOGGER.error("Gateway initialization error: %s", e)

# ---------------- Main Entry Point ----------------

if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    # First, initialize the gateway.
    loop.run_until_complete(init_gateway())
    # Start the background polling loop.
    asyncio.ensure_future(polling_loop())
    # Create and run the aiohttp web server.
    app = create_app()
    _LOGGER.info("Starting REST API server on port 3000")
    web.run_app(app, port=3000)

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
  • POLL_INTERVAL – (Optional) Polling interval in seconds (default: "10")
  
Endpoints:
  • POST /api/sms/send    – Send an SMS message.
  • POST /api/sms/receive – Manually trigger a pull for incoming SMS (optional override).
  • GET  /api/sms/info    – Retrieve real‑time modem properties (manufacturer, model, firmware, etc.)
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
    """SMS gateway to interact with a GSM modem via Gammu."""

    def __init__(self, config):
        _LOGGER.debug("Initializing Gateway with connection: %s", config["Connection"])
        # The GammuAsyncWorker will automatically call self.sms_pull for polling.
        self._worker = GammuAsyncWorker(self.sms_pull)
        self._worker.configure(config)
        self._first_pull = True

    async def init_async(self):
        """Initialize the modem connection asynchronously."""
        await self._worker.init_async()
        _LOGGER.debug("Gateway initialized")

    def sms_pull(self, state_machine):
        """Called by the async worker to poll the modem and process messages."""
        state_machine.ReadDevice()
        _LOGGER.debug("Polling modem for SMS...")
        self.sms_read_messages(state_machine, self._first_pull)
        self._first_pull = False

    def sms_read_messages(self, state_machine, force=False):
        """Decode and process all received SMS messages from the modem."""
        entries = self.get_and_delete_all_sms(state_machine, force)
        _LOGGER.debug("Found SMS entries: %s", entries)
        for entry in entries:
            decoded_entry = gammu.DecodeSMS(entry)
            message = entry[0]
            _LOGGER.debug("Processing SMS: %s, decoded: %s", message, decoded_entry)
            if message["State"] == SMS_STATE_UNREAD:
                text = ""
                if decoded_entry is None:
                    text = message.get("Text", "")
                else:
                    for inner_entry in decoded_entry["Entries"]:
                        if inner_entry["Buffer"]:
                            text += inner_entry["Buffer"]
                event_data = {
                    "phone": message["Number"],
                    "date": str(message["DateTime"]),
                    "message": text,
                }
                _LOGGER.debug("Forwarding event data: %s", event_data)
                # Forward the SMS message to Home Assistant via its webhook.
                asyncio.create_task(self._notify_incoming_webhook(event_data))

    def get_and_delete_all_sms(self, state_machine, force=False):
        """Read and delete all SMS messages from the modem."""
        memory = state_machine.GetSMSStatus()
        remaining = memory["SIMUsed"] + memory["PhoneUsed"]
        entries = []
        start = True
        try:
            while remaining > 0:
                if start:
                    entry = state_machine.GetNextSMS(Folder=0, Start=True)
                    # Use UDH parts if available; default to assuming one part.
                    _ = entry[0].get("UDH", {}).get("AllParts", 1)
                    start = False
                else:
                    entry = state_machine.GetNextSMS(Folder=0, Location=entry[0]["Location"])
                remaining -= 1
                entries.append(entry)
                try:
                    state_machine.DeleteSMS(Folder=0, Location=entry[0]["Location"])
                except gammu.ERR_MEMORY_NOT_AVAILABLE:
                    _LOGGER.error("Failed to delete SMS at location %s", entry[0]["Location"])
        except gammu.ERR_EMPTY:
            _LOGGER.warning("No SMS messages found.")
        return gammu.LinkSMS(entries)

    async def _notify_incoming_webhook(self, message):
        """Forward an incoming SMS to Home Assistant via the webhook."""
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
        """Send an SMS message using the async worker."""
        return await self._worker.send_sms_async(message)

    async def get_imei_async(self):
        """Retrieve the modem's IMEI."""
        return await self._worker.get_imei_async()

    async def get_signal_quality_async(self):
        """Retrieve the modem's signal quality."""
        return await self._worker.get_signal_quality_async()

    async def get_network_info_async(self):
        """Retrieve the network info from the modem."""
        network_info = await self._worker.get_network_info_async()
        if not network_info["NetworkName"]:
            network_info["NetworkName"] = gammu.GSMNetworks.get(network_info["NetworkCode"])
        return network_info

    async def get_manufacturer_async(self):
        """Retrieve the modem's manufacturer."""
        return await self._worker.get_manufacturer_async()

    async def get_model_async(self):
        """Retrieve the modem's model."""
        model = await self._worker.get_model_async()
        if not model or not model[0]:
            return None
        display = model[0]
        if model[1]:
            display = f"{display} ({model[1]})"
        return display

    async def get_firmware_async(self):
        """Retrieve the modem's firmware."""
        firmware = await self._worker.get_firmware_async()
        if not firmware or not firmware[0]:
            return None
        display = firmware[0]
        if firmware[1]:
            display = f"{display} ({firmware[1]})"
        return display

    async def terminate_async(self):
        """Terminate the modem connection."""
        return await self._worker.terminate_async()


# ---------------------------------------------------------------------
# REST API Endpoints that retrieve the Gateway from the app context.
# ---------------------------------------------------------------------

async def send_sms(request):
    """
    POST /api/sms/send
    Expected JSON payload:
      {
        "number": "+1234567890",
        "text": "Hello from the gateway!"
      }
    """
    _LOGGER.info("send_sms")
    gateway = request.app["gateway"]
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

async def get_info(request):
    """
    GET /api/sms/info
    Retrieve real‑time modem properties (manufacturer, model, firmware, IMEI,
    signal quality, network info, etc.)
    """
    _LOGGER.info("get_info")
    gateway = request.app["gateway"]
    try:
        manufacturer = await gateway.get_manufacturer_async()
        model = await gateway.get_model_async()
        firmware = await gateway.get_firmware_async()
        imei = await gateway.get_imei_async()
        signal_quality = await gateway.get_signal_quality_async()
        network_info = await gateway.get_network_info_async()
        return web.json_response({
            "manufacturer": manufacturer,
            "model": model,
            "firmware": firmware,
            "imei": imei,
            "signal_quality": signal_quality,
            "network_info": network_info,
        })
    except Exception as e:
        _LOGGER.error("Failed to get modem info: %s", e)
        return web.json_response({"error": str(e)}, status=500)


def create_app():
    """Create the aiohttp web application and register routes."""
    app = web.Application()
    app.add_routes([
        web.post("/api/sms/send", send_sms),
        web.get("/api/sms/info", get_info),
    ])
    return app


async def init_app():
    """
    Initialize the application by creating the Gateway instance,
    initializing the modem connection, and storing the instance in the app context.
    """
    app = create_app()
    gateway = Gateway(GSM_CONFIG)
    app["gateway"] = gateway
    try:
        await gateway.init_async()
    except Exception as e:
        _LOGGER.error("Failed to initialize gateway: %s", e)
    _LOGGER.info("Gateway is ready")
    return app


if __name__ == "__main__":
    _LOGGER.info("Starting REST API server on port 3000")
    web.run_app(init_app(), port=3000)
    #loop = asyncio.get_event_loop()
    #app = loop.run_until_complete(init_app())
    #_LOGGER.info("Starting REST API server on port 3000")
    #web.run_app(app, port=3000)

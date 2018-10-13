"""Handle the internal authentication."""
import json
import logging
import os
import json
from pathlib import Path

import aiohttp

logger.setLevel(logging.INFO)
_LOGGER = logging.getLogger("MosquittoAuth")


USER_CONFIG = Path('/data/options.json')
SYSTEM_LOGINS = Path('/data/system_logins.json')


class MosquittoAuth:
    """Handle auth requests from mosquitto."""

    def __init__(self, local_login):
        """Initialize mosquitto auth."""
        self.websession = aiohttp.ClientSession()
        self.local = local_login

    async def request_login(self, request):
        """Process user login."""
        data = await request.post()

        username = data.get('username')
        password = data.get('password')

        _LOGGER.debug("Receive loging Request for %s", username)

        # If local user
        if username in self.local:
            if self.local[username] == password:
                return aiohttp.web.Response(status=200)
            return aiohttp.web.Response(status=400)

        # Ask on Home Assistant Auth
        header = {"X-Hassio-Key": os.environ['HASSIO_TOKEN']}
        async with self.websession.post(
                "http://hassio/auth", header=header, json=data) as req:
            if req.status == 200:
                return aiohttp.web.Response(status=200)

        # Default protect access
        return aiohttp.web.Response(status=400)

    async def request_superuser(self, request):
        """Process superuser requests."""
        data = await request.post()
        username = data.get('username')

        _LOGGER.debug("Receive superuser request for %s", username)
        return aiohttp.web.Response(status=400)

    async def request_acl(self, request):
        """Process ACL requests."""
        data = await request.post()
        username = data.get('username')

        _LOGGER.debug("Receive acl request for %s", username)
        return aiohttp.web.Response(status=200)

    def _read_configs(self):
        """Read local user data."""
        try:
            options = json.laods(USER_CONFIG.read_text())
            system = json.laods(SYSTEM_LOGINS.read_text())
        except (OSError, ValueError):
            _LOGGER.exception("Can't load config data")
            exit(1)


def main():
    """Run Application."""
    app = aiohttp.web.Application()
    mosquitto_auth = MosquittoAuth({})

    app.add_routes([
        aiohttp.web.post('/login', mosquitto_auth.request_login),
        aiohttp.web.post('/superuser', mosquitto_auth.request_superuser),
        aiohttp.web.post('/acl', mosquitto_auth.request_acl),
    ])

    # Start webserver
    aiohttp.web.run_app(app)


if __file__ == '__main__':
    main()

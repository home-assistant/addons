"""Mapping hass.io options.json into configurator config."""
import json
from pathlib import Path
import sys

hassio_options = Path("/data/options.json")

# Read hass.io options
with hassio_options.open('r') as json_file:
    options = json.loads(json_file.read())

configurator = {
    'BASEPATH': "/config",
    'HASS_API': "http://hassio/homeassistant/api",
    'HASS_API_PASSWORD': "",
    'CREDENTIALS': 
        "{}:{}".format(options['username'], options['password']),
    'SSL_CERTIFICATE': 
        "ssl/{}".format(options['certfile']) if options['ssl'] else None,
    'SSL_KEY': 
        "ssl/{}".format(options['keyfile']) if options['ssl'] else None,
    'ALLOWED_NETWORKS': options['allowed_networks'],
    'BANNED_IPS': options['banned_ips'],
    'IGNORE_PATTERN': options['ignore_pattern'],
}

with Path(sys.argv[1]).open('w') as json_file:
    json_file.write(json.dumps(configurator))

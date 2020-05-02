# Generate templates for issues
import os

__location__ = os.path.realpath(os.path.join(
    os.getcwd(), os.path.dirname(__file__)))

# List of all the addons on this repository
ADDONS = [
    ("ada", "Hey Ada!"),
    ("almond", "Almond"),
    ("cec_scan", "CEC Scanner"),
    ("check_config", "Check Home Assistant configuration"),
    ("configurator", "File editor"),
    ("deconz", "deCONZ"),
    ("dhcp_server", "DHCP server"),
    ("dnsmasq", "Dnsmasq"),
    ("duckdns", "Duck DNS"),
    ("git_pull", "Git pull"),
    ("google_assistant", "Google Assistant SDK"),
    ("homematic", "HomeMatic"),
    ("letsencrypt", "Let's Encrypt"),
    ("mariadb", "MariaDB"),
    ("mosquitto", "Mosquitto broker"),
    ("nginx_proxy", "NGINX Home Assistant SSL proxy"),
    ("rpc_shutdown", "RPC Shutdown"),
    ("samba", "Samba share"),
    ("snips", "Snips"),
    ("ssh", "SSH server"),
    ("tellstick", "TellStick"),
]

BUG_TEMPLATE = """---
name: Report a bug with {addon_title} addon
about: Report an issue about the {addon_title} addon
title: ''
labels: 'bug, add-on: {addon}'
assignees: ''

---

**Describe the bug**
<!-- A clear and concise description of what the bug is. -->

**To Reproduce**
<!-- Steps to reproduce the behavior: -->

**Expected behavior**
<!-- A clear and concise description of what you expected to happen. -->

**Screenshots or error stack trace**
<!-- If applicable, add screenshots to help explain your problem. -->

**Additional context**
<!-- Add any other context about the problem here. -->
"""

for addon in ADDONS:
    filename = 'bug_report_{title}.md'.format(title=addon[0])
    f = open(os.path.join(__location__, filename), "w")
    f.write(BUG_TEMPLATE.format(addon_title=addon[1], addon=addon[0]))
    f.close()

# Home Assistant Add-on: Terminal & SSH

## Installation

Follow these steps to get the add-on installed on your system:

1. This add-on is only visible to "Advanced Mode" users. To enable advanced mode, go to **Profile** -> and turn on **Advanced Mode**.
2. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
3. Find the "Terminal & SSH" add-on and click it.
4. Click on the "INSTALL" button.

## How to use

This add-on adds two main features to your Home Assistant installation:

- a web terminal that you can use from your browser, and
- enable connecting to your system using an SSH client.

Regardless of how you connect (using the web terminal or using an SSH client), you end up in this add-on's container. The Home Assistant configuration
directory is located on the path `/config`.

This add-on comes bundled with [The Home Assistant CLI](https://www.home-assistant.io/hassio/commandline/). Try it out using:

```bash
ha help
```

### The Web Terminal

You can access the web terminal by clicking the "Open Web UI" button on this add-on's Info tab. If you set the "Show in sidebar" setting (found on the same Info tab) to "on", a shortcut is added to the sidebar allowing you to access the web terminal quickly.

### SSH Server Connection

To connect using an SSH client, such as PuTTY, you need to supply additional configuration for this add-on. To enable SSH connectivity, you need to:

- Provide authentication credentials - a password or SSH key(s)
- Specify which TCP port to bind to, on the Home Assistant host

You can then connect to the port specified, using the username `root`. Please note that enabling the SSH Server potentially makes your Home Assistant system less secure, as it might enable anyone on the internet to try to access your system. The security of your system also depends on your network set up, router settings, use of firewalls, etc. As a general recommendation, you should not activate this part of the add-on unless you understand the ramifications.

If you enable connecting to the SSH Server using an SSH client, you are strongly recommended to use private/public keys to log in. As long as you keep the private part of your key safe, this makes your system much harder to break into. Using passwords is, therefore, generally considered a less secure mechanism. To generate private/public SSH keys, follow the [instructions for Windows][keygen-windows] and [these for other platforms][keygen].

Enabling login via password will disable key-based login. You can not run both variants at the same time.

## Configuration

Add-on configuration:

```yaml
authorized_keys:
  - "ssh-rsa AKDJD3839...== my-key"
password: ''
server:
  tcp_forwarding: false
```

### Option: `authorized_keys`

Your **public keys** that you wish to accept for login. You can authorize multiple keys by adding multiple public keys to the list.

If you get errors when adding your key, it is likely that the public key you're trying to add, contains characters that intervene with YAML syntax. Try enclosing your key in double quotes to avoid this issue.

### Option: `password`

Set a password for login. **We do NOT recommend this variant**.

### Option group  `server`

Some SSH server options.

#### Option `tcp_forwarding`

Specifies whether TCP forwarding is permitted or not.

**Note**: _Enabling this option lowers the security of your SSH server! Nevertheless, this warning is debatable._

## Network

This section is only relevant if you want to connect to Home Assistant using an SSH client, such as PuTTY. To enable SSH access via the network, you need to specify which port to use on the Home Assistant host. The number you enter will be used to map that port from the host into the running "Terminal & SSH" add-on. The standard port used for the SSH protocol is `22`.

## Known issues and limitations

- This add-on will not enable you to install packages or do anything as root.
  This is not working with Home Assistant.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/hassio-addons/issues
[keygen-windows]: https://www.digitalocean.com/community/tutorials/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps
[keygen]: https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
[reddit]: https://reddit.com/r/homeassistant

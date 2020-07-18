# Home Assistant Add-on: SSH server

## Installation

Follow these steps to get the add-on installed on your system:

1. This addon is only visible to "Advanced Mode" users. To enable advanced mode, go to **Profile** -> and turn on **Advanced Mode**.
2. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
3. Find the "SSH server" add-on and click it.
4. Click on the "INSTALL" button.

## How to use

To use the web terminal, just start the add-on and click on "Open Web UI" in the
add-on page.

To login via SSH remotely you need to expose the SSH service port and enable an
authentication mechanism.

To expose a port, you can choose any port you like your SSH service to be
accessible on. If you are using Home Assistant Operating System or do not run a
SSH service on your host operating system, just use the default SSH port 22.

For remote access you need to enable an authentication mechanism. You can use
public key authentication (recommended) or password authentication.
To use public key authentication, you have to generate a public/private key pair.
Follow the [instructions for Windows][keygen-windows]
and [these for other platforms][keygen] to generate them.
To use password authentication configure a password in the configuration
section.

You can not run both variants at the same time. Enabling login via keys, will
disable password login. Especially when exposing the port to the public
internet, public key authentication is highly recommended.

1. Add a ssh key to  `authorized_keys` or set a `password` in the add-on configuration.
2. Start the add-on.
3. Connect to your device using your preferred SSH client and use `root` as
   the username.

After logging in, you will find yourself in this add-on’s container. You can use
`df` to get a list of available Home Assistant folders. E.g. the Home Assistant
configuration directory is mounted on the path `/config`.

To use the Home Assistant CLI use the `ha` command. To get a list of available
Home Assistant CLI commands use:

```bash
ha help
```

## Configuration

Add-on configuration:

```yaml
authorized_keys:
  - ssh-rsa AKDJD3839...== my-key
password: ''
```

### Option: `authorized_keys`

Your **public keys** for the authorized key file. You can authorize multiple
keys by adding multiple public keys to the list.

### Option: `password`

Set a password for login. **We do NOT recommend this variant**.

### Option group  `server`

Some SSH server options.

#### Option `tcp_forwarding`

Specifies whether TCP forwarding is permitted or not.

**Note**: _Enabling this option lowers the security of your SSH server! Nevertheless, this warning is debatable._

## Network
To enable ssh access via the network, you need to enter the port number ‘22’ or the port you want to use. This will map that port from the hassio host into the running “Terminal & SSH” container.

## Known issues and limitations

- This add-on does not give you access to the underlying operating system.
  This means you won't be able to install packages or do anything as root on the
  host operating system.

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

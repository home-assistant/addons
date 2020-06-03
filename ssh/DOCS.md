# Home Assistant Add-on: SSH server

## Installation

Follow these steps to get the add-on installed on your system:

1. This addon is only visible to "Advanced Mode" users. To enable advanced mode, go to **Profile** -> and turn on **Advanced Mode**.
2. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
3. Find the "SSH server" add-on and click it.
4. Click on the "INSTALL" button.

## How to use

You need enable the port for external access. You can just enter 22 as value or any other
value like you want. This recommend to add login credentials.

To use this add-on, you must have a private/public key to log in.
To generate them, follow the [instructions for Windows][keygen-windows]
and [these for other platforms][keygen]. It is possible to set a password for
login since version 2.0 but for high security use private/public keys.

You can not run both variants at the same time. Enabling login via keys, will
disable password login.

1. Add a ssh key to  `authorized_keys` or set a `password` in the add-on configuration.
2. Start the add-on.
3. Connect to your device using your preferred SSH client and use `root` as
   the username.

After logging in, you will find yourself in this add-on’s container.
The Home Assistant configuration directory is mounted on the path `/config`.

Try it out using:

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

# Home Assistant Add-on: SSH server

## Installation

Follow these steps to get the add-on installed on your system:

1. This addon is only visible to "Advanced Mode" users. To enable advanced mode, go to **Profile** -> and turn on **Advanced Mode**.
2. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
3. Find the "Terminal & SSH" add-on and click it.
4. Click on the "INSTALL" button.


## How to use

Once installed (following the steps above) you need to
* enable external access by selecting which TCP port to open up (see Network section), and
* supply login credentials,
* start the add-on.

You can then connect to the port specified, and using the username `root`
you will end up in this add-on's container. The Home Assistant configuration 
directory is mounted on the path `/config`.

This add-on comes bundled with [The Home Assistant CLI](https://www.home-assistant.io/hassio/commandline/). Try it out using:

```bash
ha help
```

### General Note on Security

You are strongly recommended to use private/public keys to log in. 
To generate them, follow the [instructions for Windows][keygen-windows]
and [these for other platforms][keygen]. It is possible to set a password for
login since version 2.0 but for high security use private/public keys.

Enabling login via password, will disable password login. You can not run both variants at the same time.


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

Your **public keys** for the authorized key file. You can authorize multiple
keys by adding multiple public keys to the list. If you're on Linux, you can
likely issue the command `ssh-add -L` to get a list of your public keys that 
are available to you.

If you get errors when adding your key, try enclosing it in double quotes to avoid .

### Option: `password`

Set a password for login. **We do NOT recommend this variant**.

### Option group  `server`

Some SSH server options.

#### Option `tcp_forwarding`

Specifies whether TCP forwarding is permitted or not.

**Note**: _Enabling this option lowers the security of your SSH server! Nevertheless, this warning is debatable._


## Network

To enable ssh access via the network, you need to specify which external port to use. 
The number you enter, will be used to map that port from the hassio host into the 
running "Terminal & SSH" container.

The standard port for the SSH protocol is `22`.


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

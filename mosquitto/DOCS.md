# Home Assistant Add-on: Mosquitto broker

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "Mosquitto broker" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

The add-on has a couple of options available. To get the add-on running:

1. Start the add-on.
2. Have some patience and wait a couple of minutes.
3. Check the add-on log output to see the result.

Create a new user for MQTT via the **Configuration** -> **Users (manage users)**.
Notes:

1. This name cannot be `homeassistant` or `addon`, those are reserved usernames.
2. If you do not see the option to create a new user, ensure that **Advanced Mode** is enabled in your profile.

To use the Mosquitto as a broker, go to the integration page and install the configuration with one click:

1. Navigate in your Home Assistant frontend to **Configuration** -> **Integrations**.
2. MQTT should appear as a discovered integration at the top of the page
3. Select it and check the box to enable MQTT discovery if desired, and hit submit.

If you have old MQTT settings available, remove this old integration and restart Home Assistant to see the new one.

## Configuration

Add-on configuration:

```yaml
logins: []
anonymous: false
customize:
  active: false
  folder: mosquitto
certfile: fullchain.pem
keyfile: privkey.pem
require_certificate: false
```

### Option: `logins` (optional)

A list of local users that will be created with username and password. You don’t need to do this because you can use Home Assistant users too, without any configuration. If a local user is specifically desired:

```yaml
logins:
  - username: user
    password: passwd
```

### Option: `anonymous`

Allow anonymous connections. If logins are set, the anonymous user can only read data.

Default value: `false`

#### Option: `customize.active`

If set to `true` additional configuration files will be read, see the next option.

Default value: `false`

#### Option: `customize.folder`

The folder to read the additional configuration files (`*.conf`) from.

### Option: `cafile` (optional)

A file containing a root certificate. Place this file in the Home Assistant `ssl` folder.

### Option: `certfile`

A file containing a certificate, including its chain. Place this file in the Home Assistant `ssl` folder.

### Option: `keyfile`

A file containing the private key. Place this file in the Home Assistant `ssl` folder.

### Option: `require_certificate`

If set to `true` encryption will be enabled using the cert- and keyfile options.

## Home Assistant user management

This add-on is attached to the Home Assistant user system, so MQTT clients can make use of these credentials. Local users may also still be set independently within the configuration options for the add-on. For the internal Home Assistant ecosystem, we register `homeassistant` and `addons`, so these may not be used as user names.

## Disable listening on insecure (1883) ports

Remove the ports from the add-on page network card (set them as blank) to disable them.

### Access Control Lists (ACLs)

It is possible to restrict access to topics based upon the user logged in to Mosquitto. In this scenario, it is recommended to create individual users for each of your clients and create an appropriate ACL.

See the following links for more information:

- [Mosquitto topic restrictions](http://www.steves-internet-guide.com/topic-restriction-mosquitto-configuration/)
- [Mosquitto.conf man page](https://mosquitto.org/man/mosquitto-conf-5.html)

Add the following configuration to enable **unrestricted** access to all topics.

1. Enable the customize flag

    ```yaml
      customize:
        active: true
        folder: mosquitto
    ```

2. Create `/share/mosquitto/acl.conf` with the contents:

    ```text
    acl_file /share/mosquitto/accesscontrollist
    ```

3. Create `/share/mosquitto/accesscontrollist` with the contents:

    ```text
    user [YOUR_MQTT_USER]
    topic readwrite #
    ```
    For anonymous mode ( `"anonymous": true` ), you have to remove the `user [YOUR_MQTT_USER]` line like so:

    ```text
    topic readwrite #
    ```

The `/share` folder can be accessed via SMB, or on the host filesystem under `/usr/share/hassio/share`.

## Known issues and limitations

- Since version 4.1 of the add-on, an explicit ACL definition is now required if you plan to use legacy logins and `"anonymous": true` [see these instructions](#access-control-lists-acls).

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
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
[mosquitto]: https://mosquitto.org/

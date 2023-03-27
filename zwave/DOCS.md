# Home Assistant Add-on: OpenZWave

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "OpenZWave" add-on and click it.
3. Click on the "INSTALL" button.
4. This add-on currently requires to have the Mosquitto add-on installed.
   Please make sure to install and set up that add-on before continuing.

## How to use

The add-on needs to know where your Z-Wave stick can be found, and therefore,
you'll need to configure the add-on to point to the right device.

If you're using Home Assistant you may find the correct value for this on the
`Supervisor -> System -> Host system -> Hardware` page. It is recommended
to use a "by-id" path to the device if one exists, as it is not subject to
change if other devices are added to the system.

1. Replace `null` in the `device` option in the add-on configuration and specify
   the device name in quotes: e.g., something like
   `"/dev/serial/by-id/usb-0658_0200-if00"`,
   `"/dev/ttyUSB0"`, `"/dev/ttyAMA0"`, or `"/dev/ttyACM0"`.
2. Set your 16-byte network key in the form `0x01, 0x02...` used in order to
   connect securely to compatible devices. It is recommended that a network key
   is configured as security enabled devices may not function correctly if they
   are not added securely.
3. Click on "SAVE" to save the add-on configuration.
4. Start the add-on.
5. Add the OpenZWave integration to Home Assistant, see documentation:
   <https://www.home-assistant.io/integrations/ozw>

After installing and starting this add-on, access the ozw-admin interface using
the "OPEN WEBUI" button.

## Configuration

Add-on configuration:

```yaml
device: /dev/ttyUSB0
network_key: 0x2e, 0xcc, 0xab, 0x1c, 0xa3, 0x7f, 0x0e, 0xb5, 0x70, 0x71, 0x2d, 0x98, 0x25, 0x43, 0xee, 0x0c
instance: 1
```

### Option `device`

The Z-Wave controller device.

If you're using Home Assistant you may find the correct value for this on the
`Supervisor -> System -> Host system -> Hardware` page. It is recommended
to use a "by-id" path to the device if one exists, as it is not subject to
change if other devices are added to the system.

In most cases this looks like one of the following:

- `"/dev/serial/by-id/usb-0658_0200-if00"`
- `"/dev/ttyUSB0"`
- `"/dev/ttyAMA0"`
- `"/dev/ttyACM0"`

### Option `network_key`

Security Z-Wave devices require a network key before being added to the network.
You must set the `network_key` configuration option to use a network key before
adding these devices.

To generate a network key, you can use the following script in, e.g., the SSH
add-on:

```bash
cat /dev/urandom | tr -dc '0-9A-F' | fold -w 32 | head -n 1 | sed -e 's/\(..\)/0x\1, /g' -e 's/, $//'
```

You can also use sites like this one to generate the required data,
just remember to put `0x` before each pair of characters:

<https://www.random.org/cgi-bin/randbyte?nbytes=16&format=h>

Ensure you keep a backup of this key. If you have to rebuild your system and
don't have a backup of this key, you won't be able to reconnect to any security
devices. This may mean you have to do a factory reset on those devices, and your
controller, before rebuilding your Z-Wave network.

### Option `instance` (optional)

Z-Wave instance number as reported to MQTT. This corresponds with the
`instance_id` attribute of `ozw` services in Home Assistant.

The instance ID defaults to `1`, which is generally fine to keep and use.
Only change this in case you are using multiple instances on the same MQTT
server.

## Accessing the ozw-admin application

The add-on allows you to access the underlying ozw-admin application running
in this add-on. This allows you to view, configure and control your Z-Wave
network and its devices.

### Accessing the ozw-admin application via Ingress

You can access the built-in ozw-admin application directly via Home Assistant
Ingress. Click on the "OPEN WEBUI" button to access it.

If it does not auto connect to your Z-Wave network automatically:
Click on the "Open" button in the menu bar of the application and click on
the start button in the **"Remote OZWDaemon"** section.

If you need to access the application more often, it can be added to the
Home Assistant sidebar by toggling the "Show in sidebar" switch on the
add-on page.

### Accessing the ozw-admin application via VNC

You can access the built-in ozw-admin application via a VNC viewer.

Please note, you can access the same interface using the "OPEN WEBUI" button,
described above.

To enable it:

- Set a port number for VNC in the "Network" configuration section of the
  add-on and hit "SAVE". Advised is to use port 5900, but any other port above
  5900 works as well.
- Restart the add-on.

To access it, you need a [VNC Viewer][vnc-viewer] application. If you are using
macOS, you are in luck, since VNC is built-in. Open the spotlight search and
enter the VNC service URL.

The VNC service URL looks like [vnc://homeassistant.local:5900](vnc-service-url).
Adjust port and possibly hostname if you've changed it in Home Assistant host system
settings.

### Connecting remotely using a local ozw-admin application

Alternatively, the ozw-admin application can be downloaded and installed on a
remote machine, like your desktop computer. To connect your remote machine:

- Set a port number for the ozw-admin in the "Network" configuration section of
  the add-on and hit "SAVE". Advised is to use port 1983, as this is the default.
- Restart the add-on.

To access your Z-Wave network with the ozw-admin, you need to first download the ozw-admin application. The latest
version can be found here:

<http://bamboo.my-ho.st/bamboo/browse/OZW-OZW/latestSuccessful/artifact>

After you've installed and started the ozw-admin application, click "Open"
and set the remote host and port in the "Remote OZWDaemon" section.
For example, host: `homeassistant.local`, with port `1983` in the second field.

Next, click on "Start" to connect.

## Known issues and limitations

- Your hardware needs to be compatible with OpenZWave library

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[vnc-service-url]: vnc://homeassistant.local:5900
[vnc-viewer]: https://bintray.com/tigervnc/stable/tigervnc/

# Home Assistant Add-on: Z-Wave JS

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "Z-Wave JS" add-on and click it.
3. Click on the "INSTALL" button.

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
2. Set your 16-byte (32 character hex) network key in the form `2232666D1...`
   used in order to connect securely to compatible devices. It is recommended
   that a network key is configured as some security enabled devices (locks, etc)
   may not function correctly if they are not added securely.
     * As a note, it is not recommended to securely connect *all* devices unless
       necessary as it triples the amount of messages sent on the mesh.
3. Click on "SAVE" to save the add-on configuration.
4. Start the add-on.
5. Add the Z-Wave JS integration to Home Assistant, see documentation:
   <https://www.home-assistant.io/integrations/zwave_js>


## Configuration

Add-on configuration:

```yaml
device: /dev/ttyUSB0
network_key: 2232666D100F795E5BB17F0A1BB7A146
```

### Option `device`

The device address of your Z-Wave controller.

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

If you don't add a network key, it will autogenerate one for you.

To generate a network key manually, you can use the following script in, e.g.,
the SSH add-on:

```bash
hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random
```

You can also use sites like this one to generate the required data:

<https://www.random.org/cgi-bin/randbyte?nbytes=16&format=h>

Ensure you keep a backup of this key. If you have to rebuild your system and
don't have a backup of this key, you won't be able to reconnect to any securely
included devices. This may mean you have to do a factory reset on those devices
and your controller, before rebuilding your Z-Wave network.

### Option `emulate_hardware` (optional)

If you don't have a USB stick, you can use a fake stick for testing purposes.
It will not be able to control any real devices.

## Known issues and limitations

- Your hardware needs to be compatible with the Z-Wave JS library

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

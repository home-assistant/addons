# Home Assistant Add-on: deCONZ

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "deCONZ" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

### Using a RaspBee

If you are using RaspBee, you may need to edit the `config.txt` file in the root
of your SD card in order for your RaspBee to be recognized and assigned a device name.

Add following to your `config.txt`:

```txt
enable_uart=1
dtoverlay=pi3-miniuart-bt
```

### Configure the add-on

The add-on needs to know where your ConBee/RaspBee can be found, and therefore,
you'll need to configure the add-on to point to the right device.

If you're using Home Assistant you may find the correct value for this on the
**Settings** -> **System** -> **Hardware** -> **All hardware** page. It is recommended
to use a "by-id" path to the device if one exists, as it is not subject to
change if other devices are added to the system.

1. Replace `null` in the `device` option in the add-on configuration and specify
   the device name in quotes: e.g. something like <br>
   `"/dev/serial/by-id/usb-dresden_elektronik_ingenieurtechnik_GmbH_ConBee_II_XXXXXXXX-if00"`,
   `"/dev/ttyUSB0"`, `"/dev/ttyAMA0"`, or `"/dev/ttyACM0"`.
2. Click on "SAVE" to save the add-on configuration.
3. Toggle the "Show in sidebar" to add it to your Home Assistant side bar.
4. Start the add-on.

After installing and launching this add-on, you can select **deCONZ** under web UI to access
the deCONZ GUI via VNC, or select **Phoscon** to configure the settings in the Phoscon App.

## Configuring the Home Assistant deCONZ integration

By default, Home Assistant has the `discovery` integration enabled, which
automatically discovers this add-on.

Navigate to **Settings** -> **Devices & Services** -> **Integrations** page after starting this
add-on to configure the deCONZ integration.

In case you don't have `discovery` enabled on your Home Assistant instance,
follow these instructions to configure the deCONZ integration:

<https://www.home-assistant.io/integrations/deconz/>

## Migrating to this add-on

To migrate deCONZ to Home Assistant and this add-on, back up your configuration via
the Phoscon App and restore it after installation/reinstallation.

**_You must perform these steps or your Light, Group names and other data will be lost!_**

However, your Zigbee devices will still be paired to your ConBee or RaspBee hardware.

## Accessing the deCONZ application and viewing the mesh via VNC

The add-on allows you to access the underlying deCONZ application running on
a remote desktop via VNC. It allows you to view the Zigbee mesh (which can
be really helpful when debugging network issues), but also gives you access
to tons of advanced features.

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

## Upgrading RaspBee and ConBee firmware

This add-on allows you to upgrade your firmware straight from the Phoscon App with ease.

In the Phoscon App, go to **Settings** -> **Gateway**, then select the upgrade button.

However, some USB sticks (like the Aeotec Z-Wave sticks), can interfere with
the upgrade process, causing the firmware upgrade to fail silently. If you end
up with the same firmware version as before you started the upgrade, consider
unplugging the other sticks and try again.

If that is still not working, try [upgrading the firmware manually][manual-upgrade].

## Using the deCONZ/Phoscon API with another add-on

Some add-ons are capable of consuming the deCONZ API directly. Node-RED is
one of those applications, that is available as an add-on, that can
consume the deCONZ API using the `node-red-contrib-deconz` node.

**WARNING:** Do not use these settings to set up an integration in Home Assistant.

To allow these add-ons to connect to deCONZ, use the following settings:

- **Host**: `core-deconz`
- **(API) Port**: `40850`
- **WebSocket Port**: `8081`

_Note: The above settings are likely to change in a future update of this add-on._

## Advanced debug output control

Hidden controls are added to the add-on to allow control over the debug
output of deCONZ. The following options are hidden, but can be added to
the add-on configuration:

- `dbg_info`
- `dbg_aps`
- `dbg_otau`
- `dbg_zcl`
- `dbg_zdp`

These options require a number that represents the log level.

Example add-on config with `dbg_aps` enabled on log level 1:

```yaml
device: /dev/ttyUSB0
dbg_aps: 1

```

## Configuration

Add-on configuration:

```yaml
device: /dev/ttyAMA0
```

### Option: `device` (required)

The device address of your ConBee/RaspBee.

If you're using Home Assistant you may find the correct value for this on the
**Settings** -> **System** -> **Hardware** -> **All hardware** page. It is recommended
to use a "by-id" path to the device if one exists, as it is not subject to
change if other devices are added to the system.

In most cases this looks like one of the following:

- `"/dev/serial/by-id/usb-dresden_elektronik_ingenieurtechnik_GmbH_ConBee_II_XXXXXXXX-if00"` <br> 
   (and similar for RaspBee and the original ConBee, replace `XXXXXXXX` with the value you see in your above mentioned hardware page)
- `"/dev/ttyUSB0"`
- `"/dev/ttyAMA0"`
- `"/dev/ttyACM0"`

## Troubleshooting

### My gateway shows up in Home Assistant with ID 0000000000000000

This is an older bug that has been solved in the add-on. The add-on
was too quick on sending the gateway ID in the past, before deCONZ had
one assigned.

This might cause issues in Home Assistant, like having no devices.
It also might cause an issue when the add-on has internal changes and next
fails to communicate new settings to Home Assistant.

This can be solved by the following steps:

1. Backup your deCONZ/Phoscon data, by going into the Phoscon App, from the menu choose:
  **Settings** -> **Gateway** -> **Backup options**, then create
  a new backup and download it onto your computer.
2. Uninstall the add-on.
3. In Home Assistant, remove the current integration you have for deCONZ.
4. Restart Home Assistant.
5. Install the deCONZ add-on again, and configure it again according to the [instructions](#configure-the-add-on).
6. Restore the backup you created at the first step at the same location in the Phoscon App as before.
7. Restart the add-on and next, restart Home Assistant once more.
8. Follow the instructions on [setting up the deCONZ integration](#configuring-the-home-assistant-deconz-integration).

### My integration shows no devices after upgrading to 4.x

_Please, be sure you don't have the issue with gateway ID 0000000000000000._

It can happen that you have accidentally used an older discovery or a manual
set up of the integration in the past. Because of this, the add-on is unable
to inform Home Assistant of changed internal settings, which happened in 4.x.

The solution for this is to do the following steps to take care of that issue
for once and for all, so in the future, you won't end up having this issue.

1. In Home Assistant, remove the current integration you have for deCONZ.
2. Restart Home Assistant.
3. Follow the instructions on [setting up the deCONZ integration](#configuring-the-home-assistant-deconz-integration).

This will ensure you have a working integration and add-on for the future.

## Known issues and limitations

- Use at least 2.5A power supply for your Raspberry Pi!
  This avoids strange behavior when using this add-on.
- The add-on has no UPnP support.
- If for some reason the deCONZ frontend does not give you an initial setup
  for your ConBee or RaspBee and keeps asking for a password, then most likely
  `delight` is the default password you can use to get in.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]
- The [deCONZ discord server](https://discord.gg/QFhTxqN).

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[manual-upgrade]: https://github.com/dresden-elektronik/deconz-rest-plugin/wiki/Update-deCONZ-manually
[reddit]: https://reddit.com/r/homeassistant
[vnc-viewer]: https://tigervnc.org
[vnc-service-url]: vnc://homeassistant.local:5900

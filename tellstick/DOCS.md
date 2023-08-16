# Home Assistant Add-on: TellStick

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "TellStick" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

### Starting the add-on

After installation you are presented with a default and example configuration,
to alter this you must follow both the JSON format and also be aligned with
the [valid parameters for Tellstick configuration file (tellstick.conf)][conf].

1. Adjust the add-on configuration to match your devices. See the add-on
   configuration options below for more details.
2. Save the add-on configuration by clicking the "SAVE" button.
3. Start the add-on.

### Home Assistant integration

You will need to add internal communication details to the `configuration.yaml`
file to enable the integration with the add-on.

```yaml
# Example configuration.yaml entry
tellstick:
    host: core-tellstick
    port: [50800, 50801]
```

To add lights, sensors and switches to Home Assistant, you need to follow the
guidelines for each type individually that is described for Home Assistant.

For more information, check the Home Assistant documentation:

<https://www.home-assistant.io/components/tellstick/>

## Configuration

After installation you are presented with a default and example configuration,
to alter this you must follow both the JSON format and also be aligned with
the [valid parameters for Tellstick configuration file (tellstick.conf)][conf].

Example add-on configuration:

```yaml
devices:
  - id: 1
    name: Example device
    protocol: everflourish
    model: selflearning-switch
    house: A
    unit: '1'
  - id: 2
    name: Example device two
    protocol: everflourish
    model: selflearning-switch
    house: A
    unit: '2'
```

Please note: After any changes have been made to the configuration,
you need to restart the add-on for the changes to take effect.

### Option: `devices` (required)

Add one or more devices entries to the add-on configuration for each
device you'd like to add. Please note the comma separator between each
device (see example above).

#### Option: `devices.id` (required)

A unique number / identifier that must be unique for each device.

#### Option: `devices.name` (required)

A name for your device, making it easier to identify it.

#### Option: `devices.protocol` (required)

This is the protocol the device uses. For a full list of supported protocols
(and thus valid values for this configuration option), check the
TellStick [protocol list][protocol-list].

#### Option: `devices.model` (optional)

The model parameter is only used by some protocols where there exists different
types of devices using the same protocol. This can be dimmers versus non-dimmers,
codeswitch versus self-learning, etc.

#### Option: `devices.house` (optional)

Depending on protocol the values here can vary a lot to identify
or group per house or type.

#### Option: `devices.unit` (optional)

Unit identifier, in most cases a value between 1 to 16 and often used in
combination with the house.

#### Option: `devices.fade` (optional)

Fade is either `true` or `false` and tells a dimmer if it should fade smooth
or instant between values (only for IKEA protocol as it seems).

#### Option: `devices.code` (optional)

A number series based on ones and zeroes often used for dip-switch based devices.

## Service calls

If you wish to teach a self-learning device in your TellStick configuration:

Go to Home Assistant service call in Developer tools and select:

- Service: `hassio.addon_stdin`
- Enter service Data:
  `{"addon":"core_tellstick","input":{"function":"learn","device":"1"}}`

Replace `1` with the corresponding ID of the device in your TellStick configuration.

You can also use this to list devices or sensors and read the output in the
add-on log: `{"addon":"core_tellstick","input":{"function":"list-sensors"}}`

### Supported service commands

- `"function":"list"`
  List currently configured devices with name and device id and all discovered sensors.
  
- `"function":"list-sensors"`
  
- `"function":"list-devices"`
  Alternative devices/sensors listing: Shows devices and/or sensors using key=value
  format (with tabs as separators, one device/sensor per line, no header lines.)

- `"function":"on","device":"x"`
  Turns on device. ’x’ could either be an integer of the device-id,
  or the name of the device.

- `"function":"off","device":"x"`
  Turns off device. ’x’ could either be an integer of the device-id,
  or the name of the device.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[conf]: http://developer.telldus.com/wiki/TellStick_conf
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[protocol-list]: http://developer.telldus.com/wiki/TellStick_conf
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository

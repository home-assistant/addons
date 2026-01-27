# Home Assistant App: Z-Wave JS

## Installation

Follow these steps to get the app installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** > **Apps** > **App Store**.
2. Find the "Z-Wave JS" app and click it.
3. Click on the "INSTALL" button.

## How to use

The app needs to know where your Z-Wave stick can be found, and therefore,
you'll need to configure the app to point to the right device.

If you're using Home Assistant you may find the correct value for this by going to
`Settings -> System -> Hardware` and then clicking the three dots menu and selecting
`All Hardware`. It is recommended to use a "by-id" path to the device if one exists,
as it is not subject to change if other devices are added to the system.

1. Replace `null` in the `device` option in the app configuration and specify
   the device name in quotes: e.g., something like
   `"/dev/serial/by-id/usb-0658_0200-if00"`,
   `"/dev/ttyUSB0"`, `"/dev/ttyAMA0"`, or `"/dev/ttyACM0"`.
2. Set your 16-byte (32 character hex) security keys in the form `2232666D1...`
   in order to connect securely to compatible devices. It is recommended
   that all four network keys are configured as some security enabled devices (locks, etc)
   may not function correctly if they are not added securely.
   - As a note, it is not recommended to securely connect _all_ devices unless they support S2 security
     as the S0 security triples the amount of messages sent on the mesh.
3. Click on "SAVE" to save the app configuration.
4. Start the app.
5. Add the Z-Wave JS integration to Home Assistant, see documentation:
   <https://www.home-assistant.io/integrations/zwave_js>

## Configuration

App configuration:

```yaml
device: /dev/ttyUSB0
s0_legacy_key: 2232666D100F795E5BB17F0A1BB7A146
s2_access_control_key: A97D2A51A6D4022998BEFC7B5DAE8EA1
s2_authenticated_key: 309D4AAEF63EFD85967D76ECA014D1DF
s2_unauthenticated_key: CF338FE0CB99549F7C0EA96308E5A403
lr_s2_access_control_key: E2CEA6B5986C818EEC0D0065D81E2BD5
lr_s2_authenticated_key: 863027C59CFC522A9A3C41976AE54254
```

### Option `device`

The Z-Wave controller device.

If you're using Home Assistant you may find the correct value for this by going to
`Settings -> System -> Hardware` and then clicking the three dots menu and
selecting `All Hardware`. It is recommended to use a "by-id" path to the device
if one exists, as it is not subject to change if other devices are added to
the system.

In most cases this looks like one of the following:

- `"/dev/serial/by-id/usb-0658_0200-if00"`
- `"/dev/ttyUSB0"`
- `"/dev/ttyAMA0"`
- `"/dev/ttyACM0"`

### Security Keys

There are six different security keys required to take full advantage of the
different inclusion methods that Z-Wave JS supports: `s0_legacy_key`,
`s2_access_control_key`, `s2_authenticated_key`, `s2_unauthenticated_key`, `lr_s2_access_control_key`, and `lr_s2_authenticated_key`.

If you are coming from a previous version of `zwave-js`, you likely have a key
stored in the `network_key` configuration option. When the addon is first
started, the key will be migrated from `network_key` to `s0_legacy_key` which
will ensure that your S0 secured devices will continue to function.

If any of these keys are missing on startup, the addon will autogenerate one for
you. To generate a network key manually, you can use the following script in,
e.g., the SSH app:

```bash
hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random
```

You can also use sites like this one to generate the required data:

<https://www.random.org/cgi-bin/randbyte?nbytes=16&format=h>

Ensure you keep a backup of these keys. If you have to rebuild your system and
don't have a backup of these keys, you won't be able to communicate to any
securely included devices. This may mean you have to do a factory reset on
those devices and your controller, before rebuilding your Z-Wave network.

> NOTE: Sharing keys between multiple security classes is a security risk, so
> if you choose to configure these keys on your own, be sure to make them
> unique!

#### Option `s0_legacy_key`

S0 Security Z-Wave devices require a network key before being added to the network.
This configuration option is required, but if it is unset the addon will generate
a new one automatically on startup.

#### Option `s2_access_control_key`

The `s2_access_control_key` must be provided in order to include devices with the
S2 Access Control security class. This security class is needed by devices such
as door locks and garage door openers. This configuration option is required,
but if it is unset the addon will generate a new one automatically on startup.

#### Option `s2_authenticated_key`

The `s2_authenticated_key` must be provided in order to include devices with
the S2 Authenticated security class. Devices such as security systems, sensors,
lighting, etc. can request this security class. This configuration option is
required, but if it is unset the addon will generate a new one automatically
on startup.

### Option `s2_unauthenticated_key`

The `s2_unauthenticated_key` must be provided in order to include devices with
the S2 Unauthenticated security class. This is similar to S2 Authenticated, but
without verification that the correct device was included. This configuration
option is required, but if it is unset the addon will generate a new one
automatically on startup.

#### Option `lr_s2_access_control_key`

The `lr_s2_access_control_key` must be provided in order to include devices using
Z-Wave Long Range. This configuration option is required, but if it is unset
the addon will generate a new one automatically on startup.

#### Option `lr_s2_authenticated_key`

The `lr_s2_authenticated_key` must be provided in order to include devices using
Z-Wave Long Range. This configuration option is required, but if it is unset
the addon will generate a new one automatically on startup.

### Option `log_level` (optional)

This option sets the log level of Z-Wave JS. Valid options are:

- silly
- debug
- verbose
- http
- info
- warn
- error

If no `log_level` is specified, the log level will be set to the level set in
the Supervisor.

### Option `log_to_file` (optional)

When this option is enabled, logs will be written to the `/addon_configs/core_zwave_js`
folder with the `.log` file extension.

### Option `log_max_files` (optional)

When `log_to_file` is true, Z-Wave JS will create a log file for each
day. This option allows you to control the maximum number of files that
Z-Wave JS will keep.

### Option `rf_region` (optional)

This setting tells the app what radio frequency region the controller should use.
Valid options are:

- Automatic
- Australia/New Zealand
- China
- Europe
- Europe (Long Range)
- Hong Kong
- India
- Israel
- Japan
- Korea
- Russia
- USA
- USA (Long Range)

The default is Automatic which will try to set the correct region based on the country set in Home Assistant.

### Option `soft_reset` (optional)

This setting tells the app how to handle soft-resets for 500 series controllers:
1. Automatic - the app will decide whether soft-reset should be enabled or disabled for 500 series controllers. This is the default option and should work for most people.
2. Enabled - Soft-reset will be explicitly enabled for 500 series controllers.
3. Disabled - Soft-reset will be explicitly disabled for 500 series controllers.

### Option `emulate_hardware` (optional)

If you don't have a USB stick, you can use a fake stick for testing purposes.
It will not be able to control any real devices.

### Option `disable_controller_recovery` (optional):

This setting will disable Z-Wave JS's automatic recovery process when the
controller appears to be unresponsive and will instead let the controller
recover on its own if it's capable of doing so. While the controller is
unresponsive, commands will start to fail and nodes may randomly get
marked as dead. If a controller is not able to recover on its own, you
will need to restart the app to attempt recovery. In most cases, users
will never need to use this feature, so only change this setting if you
know what you are doing and/or you are asked to.

### Option `disable_watchdog` (optional):

This setting will prevent Z-Wave JS from enabling the hardware watchdog
on supporting controllers. In most cases, users will never need to use this
feature, so only change this setting if you know what you are doing and/or
you are asked to.

### Option `safe_mode` (optional)

This setting puts your network in safe mode, which could significantly decrease
the performance of your network but may also help get the network up and running
so that you can troubleshoot issues, grab logs, etc. In most cases, users will
never need to use this feature, so only change this setting if you know what you
are doing and/or you are asked to.

### Option `network_key` (deprecated)

In previous versions of the addon, this was the only key that was needed. With
the introduction of S2 security inclusion in zwave-js, this option has been
deprecated in favor of `s0_legacy_key`. If still set, the `network_key` value will be
migrated to `s0_legacy_key` on first startup.

### Troubleshooting network issues

There are several features available in the app that can help you in troubleshooting network issues and/or providing data to either the Home Assistant or Z-Wave JS team to help in tracing an issue:

1. **Update the log level:** It is extremely helpful when opening a GitHub issue to set the `log_level` configuration option to `debug` and capture when the issue occurs.
2. **Log to file:** The `log_to_file` and `log_max_files` configuration options allow you to enable and configure that. Note that in order to access the log files, you will need to be able to access the filesystem of your HA instance, which you can do with the file editor, samba, or ssh apps among others.
3. **Access Z-Wave JS cache:** Z-Wave JS stores information it discovers about your network in cache files so that your devices don't have to be reinterviewed on every startup. In some cases, when opening a GitHub issue, you may be asked to provide the cache files. You can access them in `/addon_configs/core_zwave_js/cache`. Note that in order to access the cache, you will need to be able to access the filesystem of your HA instance, which you can do with the file editor, samba, or ssh apps among others.
4. **Change soft reset behavior:** By default, the addon will choose whether or not to soft reset the controller at startup automatically. In most cases that shouldn't be changed, but if asked to make a change when troubleshooting an issue, you can do so using the `soft_reset` configuration option.
5. **Disable controller recovery:** By default, if the network controller appears to be jammed, Z-Wave JS will automatically try to restore the controller to a healthy state. In most cases that shouldn't be changed, but if asked to make a change when troubleshooting an issue, you can do so using the `disable_controller_recovery` configuration option.
6. **Enable safe mode:** When Z-Wave JS is having trouble starting up, it can sometimes be hard to get useful logs to troubleshoot the issue. By setting `safe_mode` to true, Z-Wave JS may be able to start up in cases where it wouldn't with the `safe_mode` set to false. Note that enabling `safe_mode` will have a negative impact on the performance of your network and should be used sparingly.

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
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant

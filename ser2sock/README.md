## Hass.io Add-on: ser2sock

This add-on allows you to create a socket interface for your serial device for use in Home Assistant. This is extremely useful in combination with the [Alarm Decoder component](https://home-assistant.io/components/alarmdecoder/).

## Configuration

Default configuration:

```
{
  "serialDevice": "/dev/ttyAMA0",
  "baudRate": 115200,
  "port": 8100
}
```

### Option: `serialDevice`
The `serialDevice` option is the path to the serial device you want to create a socket for.

### Option: `baudRate`
The `baudRate` option is the baud rate in which your serial device operates on.

### Option: `port`
The `port` option is the port you would like the serial device to be listening at. Remember, if you change the port, be sure it is not already in use!

## Home Assistant Configuration
ser2sock comes up on `local-ser2sock`. When configuring a ser2sock device in Home Assistant, you will use that as your `host`.

## Known issues and limitations
* You may only create a socket interface for one serial device.
* If ser2sock has previously been running, Hass may stop communicating with the socket if ser2sock is updated or restarted. Restarting Hass resolves this problem.

## Technical Details
This add-on builds a local copy of [ser2sock](https://github.com/nutechsoftware/ser2sock).

## License
[MIT](LICENSE)

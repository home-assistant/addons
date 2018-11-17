## Configuring ResinOS / HassOS for RaspBee

If your RaspBee module is not detected and assigned a device name (/dev/ttyAMA0 by default), edit the config.txt file in the root of your SD card as follows, depending on the Raspberry Pi model you are using, then reboot the Pi.

### Raspberry Pi 3B and lower

Add the following lines to the end of config.txt:
```
enable_uart=1
dtoverlay=pi3-disable-bt

```
(Be sure to add a blank line at the end of the file, some users have reported that the parameter is not recognized without the blank line.)

### Raspberry Pi 3B+

Add the following line to the end of config.txt:
```
dtoverlay=pi3-miniuart-bt

```
(Be sure to add a blank line at the end of the file, some users have reported that the parameter is not recognized without the blank line.)
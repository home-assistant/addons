# Python Matter Server v8.x --> matter.js-based Matter Server 9.0+ Migration FAQ

## Why is there a new Matter Server?
The new Matter Server is a complete rewrite of the Python-based Matter Server. It is now built on the matter.js library, a JavaScript implementation of the Matter standard. The new Matter Server is more performant, more stable, and more feature-complete than the old one.

Version 9.0 of the Matter App is the first release for all Home Assistant users which uses the new Matter Server.

## Should I do a backup before installing the new version?
Yes. Make a backup before installing the new version. The new version migrates your current data automatically, but a backup lets you roll back if anything goes wrong. Tick the "Create backup" checkbox when you update the server.

Additionally, if you have enabled the watchdog feature in Home Assistant and have a higher number of Matter nodes, please disable the watchdog for the initial migration to prevent issues or mid-migration restarts.

## What happens on the first start of the new version?
The first start of the new version **automatically migrates your current data**. This requires no manual intervention but needs some time to complete. **Wait for the migration to finish** — the log shows its progress.

After the migration completes, the server discovers all your devices and performs a full interview to fetch the current data.
All later starts automatically try to connect to the devices on their last known addresses and perform only a partial interview to update changed data. This significantly speeds up every subsequent start.

## I already tested the matter.js Beta — what happens for me?
Your start may run a one-time cleanup, which can take a while:

- Coming from Beta server 0.7.x or 0.8.x: the first start removes the leftover migration fallback data.
- Coming from a Beta server older than 0.7: the first start runs the storage data migration, and the second start removes the migration fallback data — so expect both starts to take a while.

## What is the difference between the old Matter Server and the new one?
The main goal of this first new version is to be a complete drop-in replacement for the old Matter Server. The Home Assistant integration works with the new Matter Server without any changes.

In the details, there are some differences between the old and the new version:
* Some advanced configuration options have been removed, changed slightly, or added.
* The new server uses the last known addresses of your devices on startup to speed up connections, and it is also aware of each device's network type. This especially optimizes environments with many Thread devices, connecting to them while respecting the bandwidth limitations of the Thread network.
* The new server uses partial interviews when reconnecting to devices, fetching only the data that changed. This significantly improves performance on every server restart and device reconnection.
* The old server allowed commissioning of uncertified devices with "just" a test/development certificate by default. This makes adding DIY devices easy but also carries the risk of adding a malicious device to the network. The new server still supports this, but requires you to enable the special "Test-Net DCL" option first.
* The allowed certificates are usually downloaded when the server starts and are stored in the server's data directory. The new server already includes an initial set of certificates from the time of its release, so you can start it without an internet connection and still commission devices whose certificates were available at release time. The server updates the certificates in the background whenever it has an internet connection.
* The new server also checks for revoked certificates during commissioning and treats them as invalid.
* For OTA software updates, the old server started special temporary nodes in the Matter network, which often caused issues. In the new server the OTA update logic is fully integrated into the controller, which makes the process much more reliable.
* The new server needs roughly twice the RAM than the old one and also a bit more CPU, so make sure your Home Assistant host has enough free memory to run all services smoothly.

We also used the time to improve the Web UI/dashboard of the Matter Server.
Besides general consistency and usability improvements, we added network visualizations for your Thread and Wi-Fi networks. These use the connection details the devices report to visualize the network topology and give you insights into the quality of the connections. This is especially helpful for Thread networks, where the devices themselves decide which other device they use as a parent, and where you often have multiple hops between a device and the border router.
For Thread networks we also try to discover the border routers and show information about them in the network visualizations.

Note: you might also see "Unknown devices" or "External routers" in the network visualizations. This can mean different things depending on the network topology. They could be other Thread devices that do not belong to the Matter Server's fabric, or they could be stale data from the devices (for example, many sleepy battery devices do not update their network information regularly).

## Can I switch back to the old Matter Server?
No. The new Matter Server was tested as a "Beta" with the community for the last four months, and we did our best to make sure it works as expected. If you run into any issues, report them in this GitHub repository and we will try to fix them as soon as possible.

## Troubleshooting

### When I try to start the server I get the error "Fabric with index X is already present but not under the control of the Fabric Authority"
In this case it seems that there was some former migration try which somehow broke the storage. Please delete the server directory of your data directory.

Using the Advanced SSH Add-on/App with "Protection mode" disabled: ssh into Home Assistant, then

```bash
docker exec -it addon_core_matter_server bash
cd /data
ls -la
rm -rf server-2-134b
^D
^D
```

... under the assumption that the "ls -la" is showing a "server-2-134b" folder ... if the name is different just use that what's there but "server-*"

### After the start all/some of my devices are/stay offline

When devices are reported as offline after the initial start, this usually means that the devices are not announced via MDNS. This can happen in some cases and is usually solved with a restart (power-off/on) of the device. After we got the IP of the device at least once the new server will also try these IPs automatically. 

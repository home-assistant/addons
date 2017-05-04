# hassio-addons
### Docker addons for HassIO

All PRs need to be against the `build` branch!

[HassIO](https://github.com/home-assistant/hassio) | [HassIO-Build](https://github.com/home-assistant/hassio-build)

## Addon folder

```
addon_name:
  README.md
  Dockerfile
  config.json
  run.sh
```

All add-ons are based off Alpine Linux 3.5. To get the macine specific version, use `FROM %%BASE_IMAGE%%` inside your docker file. Your Docker file also needs to include this line:

```docker
ENV VERSION %%VERSION%%
```

As a user might run many add-ons, it is encouraged to try to stick to Bash scripts if you're doing simple things.

## Addon config

```json
{
  "name": "xy",
  "version": "1.2",
  "slug": "folder",
  "description": "long descripton",
  "startup": "before|after|once",
  "boot": "auto|manual",
  "ports": {
    "123/tcp": 123
  },
  "map": ["config", "ssl", "addons", "backup"],
  "options": {},
  "schema": {
    "bla": "str|int|float|bool|email|url",
    "list1": ["str|int|float|bool|email|url"],
    "list2": [
      { "ble": "str|int|float|bool|email|url" }
    ]
  },
  "image": "for custom addons",
}
```

If you want to set a value to requered and need to be set from user before it start the addon, set it to null.

## SSL

Default you can use `fullchain.pem` and `privkey.pem` from `/ssl` for you stuff. Your SSL addon should also create default this files.

## Addon need to known
`/data` is a volume with a persistant store. `/data/options.json` have the user config inside. You can use `jq` inside shell script to parse this data.

# Custom Addon repository
Add a `repository.json` to root of your git repository with:
```json
{
  "name": "Needed, Name of repository",
  "url": "url to website (optional)",
  "maintainer": "(optional) Pascal Vizeli <pvizeli@syshack.ch>"
}
```

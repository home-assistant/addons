# hassio-addons
Docker addons for HassIO

[HassIO](https://github.com/pvizeli/hassio)
[HassIO-Build](https://github.com/pvizeli/hassio-build)

## Addon folder

```
addon_name:
  README.md
  Dockerfile
  config.json
  run.sh
```

Use `FROM %%BASE_IMAGE%%` inside your docker file. We use alpine linux 3.5 for addons. It need also a this line:

```docker
ENV VERSION %%VERSION%%
```

You should use bash scripts for simple stuff inside docker to hold the image small.

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
    "list1": [
      "str|int|float|bool|email|url"
    ],
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
`/data` is a volume with a persistant store. `/data/options.json` have the user config inside. You can use `jq` inside shell script to parse this data. A other nice tool for write plugin is [Supervisor](http://supervisord.org/).

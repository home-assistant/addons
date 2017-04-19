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
  "map_config": "bool|false",
  "map_ssl": "bool|false",
  "map_hassio": "bool|false",
  "options": {},
  "schema": {
    "bla": "str|int|float|bool",
    "list1": [
      "str|int|float|bool"
    ],
    "list2": [
      { "ble": "str|int|float|bool" }
    ]
  },
  "image": "for custom addons",
}
```

## Addon need to known
`/data` is a volume with a persistant store. `/data/options.json` have the user config inside. You can use `jq` inside shell script to parse this data. A other nice tool for write plugin is [Supervisor](http://supervisord.org/).

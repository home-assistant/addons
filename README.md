# hassio-addons
Docker addons for HassIO

[HassIO](https://github.com/pvizeli/hassio)
[HassIO-Build](https://github.com/pvizeli/hassio-build)

## Addon folder

```
addon_name:
  Dockerfile
  config.json
```

Use `FROM %%BASE_IMAGE%%` inside your docker file. We use alpine linux 3.5 for addons.

## Addon config

```json
{
  "name": "xy",
  "verson": "1.2",
  "slug": "folder",
  "description": "long descripton",
  "startup": "before|after|once",
  "boot": "auto|manual",
  "ports": {'123/tcp', 123},
  "map_config": "bool",
  "map_ssl": "bool",
  "map_data": "bool",
  "options": {},
}
```

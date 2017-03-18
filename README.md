# hassio-addons
Docker addons for HassIO

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
  'name': 'xy',
  'verson': '1.2',
  'description': 'long descripton',
  'startup': 'before|after',
  'ports': [123, ],
  'map_config': bool,
  'map_ssl': bool,
}
```

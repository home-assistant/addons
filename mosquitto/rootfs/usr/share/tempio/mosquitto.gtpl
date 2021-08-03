protocol mqtt
user root
log_dest stdout
log_type error
log_type warning
log_type notice
log_type information
persistence true
persistence_location /data/

# Authentication plugin
auth_plugin /usr/share/mosquitto/auth-plug.so
auth_opt_backends sqlite,http
auth_opt_cache true
auth_opt_auth_cacheseconds 300
auth_opt_auth_cachejitter 30
auth_opt_acl_cacheseconds 300
auth_opt_acl_cachejitter 30
auth_opt_log_quiet true

# SQLITE backend for the authentication plugin
auth_opt_dbpath /etc/mosquitto/mosquitto.sqlite
auth_opt_sqliteuserquery SELECT pw FROM users WHERE username = ?

# HTTP backend for the authentication plugin
auth_opt_http_ip 127.0.0.1
auth_opt_http_port 80
auth_opt_http_getuser_uri /authentication
auth_opt_http_superuser_uri /superuser
auth_opt_http_aclcheck_uri /acl

{{ if .customize }}
include_dir /share/{{ .customize_folder }}
{{ end }}

listener 1883
protocol mqtt

listener 1884
protocol websockets

{{ if .ssl }}

# Follow SSL listener if a certificate exists
listener 8883
protocol mqtt
{{ if .cafile }}
cafile {{ .cafile }}
{{ else }}
cafile {{ .certfile }}
{{ end }}
certfile {{ .certfile }}
keyfile {{ .keyfile }}
require_certificate {{ .require_certificate }}

listener 8884
protocol websockets
{{ if .cafile }}
cafile {{ .cafile }}
{{ else }}
cafile {{ .certfile }}
{{ end }}
certfile {{ .certfile }}
keyfile {{ .keyfile }}
require_certificate {{ .require_certificate }}

{{ end }}

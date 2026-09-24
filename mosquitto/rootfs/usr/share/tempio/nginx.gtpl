# Run nginx in foreground.
daemon off;

# This is run inside Docker.
user root;

# Pid storage location.
pid /var/run/nginx.pid;

# Set number of worker processes.
worker_processes 1;

# Write error log to the add-on log.
error_log /proc/1/fd/1 error;

# Max num of simultaneous connections by a worker process.
events {
  worker_connections 64;
}

http {
  access_log              off;
  gzip                    off;
  keepalive_timeout       65;
  server_tokens           off;
  tcp_nodelay             on;
  tcp_nopush              on;
{{- if .acl_enforced }}

  # go-auth posts JSON ({"username":"..."}, keys sorted) as the request body.
  # Quotes inside JSON values are escaped, so an unescaped "username":"x"
  # pair can only be the real key. The body is only
  # available once nginx proxies the request, so the checks below forward it
  # as a header to the internal server on 127.0.0.1:81.
  map $http_x_mqtt_request $internal_user {
    '~(^|[{,])"username":"(homeassistant|addons)"[,}]'  1;
    default                                    0;
  }
{{- end }}

  server {
    listen 127.0.0.1:80 default_server;
    server_name _;

    keepalive_timeout 5;
    root /dev/null;

    location /authentication {
{{- if .acl_enforced }}
      # The internal users may only log in with their own credentials from
      # the password file, never through a Home Assistant account.
      proxy_set_header        X-Mqtt-Request $request_body;
      proxy_pass              http://127.0.0.1:81/authentication;
{{- else }}
      proxy_set_header        X-Supervisor-Token "{{ env "SUPERVISOR_TOKEN" }}";
      proxy_pass              http://supervisor/auth;
{{- end }}
    }

    location = /superuser {
{{- if .acl_enforced }}
      # Only the internal users are superusers, so no rule in the ACL file
      # can restrict them; the file-based backend decides for everyone else.
      proxy_set_header        X-Mqtt-Request $request_body;
      proxy_pass              http://127.0.0.1:81/superuser;
{{- else }}
      return 200;
{{- end }}
    }

    location = /acl {
      return {{ if .acl_enforced }}403{{ else }}200{{ end }};
    }
  }
{{- if .acl_enforced }}

  server {
    listen 127.0.0.1:81;
    server_name _;
    root /dev/null;

    location = /superuser {
      if ($internal_user) {
        return 200;
      }
      return 403;
    }

    location = /authentication {
      if ($internal_user) {
        return 403;
      }
      proxy_set_header        X-Mqtt-Request "";
      proxy_set_header        X-Supervisor-Token "{{ env "SUPERVISOR_TOKEN" }}";
      proxy_pass              http://supervisor/auth;
    }
  }
{{- end }}
}
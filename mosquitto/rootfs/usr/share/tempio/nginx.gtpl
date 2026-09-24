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

  server {
    listen 127.0.0.1:80 default_server;
    server_name _;

    keepalive_timeout 5;
    root /dev/null;

    location /authentication {
      proxy_set_header        X-Supervisor-Token "{{ env "SUPERVISOR_TOKEN" }}";
      proxy_pass              http://supervisor/auth;
    }

    # With an enforced ACL file nobody is a superuser and the file-based
    # backend alone decides; otherwise every authenticated user may use
    # every topic.
    location = /superuser {
      return {{ if .acl_enforced }}403{{ else }}200{{ end }};
    }

    location = /acl {
      return {{ if .acl_enforced }}403{{ else }}200{{ end }};
    }
  }
}
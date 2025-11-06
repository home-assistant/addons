{{/*
    Options saved in the addon UI are available in .options
    Some variables are available in .variables, these are added in nginx/run
*/}}
daemon off;
error_log stderr;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    map_hash_bucket_size 128;

    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    server_tokens off;

    server_names_hash_bucket_size 128;

    # intermediate configuration
    # https://ssl-config.mozilla.org/#server=nginx&version=1.28.0&config=intermediate&openssl=3.5.0
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ecdh_curve X25519:prime256v1:secp384r1;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
    ssl_prefer_server_ciphers off;

    {{- if .options.cloudflare }}
    include /data/cloudflare.conf;
    {{- end }}

    server {
        server_name _;
        listen {{ if .options.listen_ipv6 }}[::]:80 {{ end }}80 default_server;
        listen {{ if .options.listen_ipv6 }}[::]:443 {{ end }}443 ssl default_server;
        http2 on;
        ssl_reject_handshake on;
        return 444;
    }

    server {
        server_name {{ .options.domain }};

        # These shouldn't need to be changed
        listen {{ if .options.listen_ipv6 }}[::]:80 {{ end }}80;
        return 301 https://$host$request_uri;
    }

    server {
        server_name {{ .options.domain }};

        ssl_session_timeout 1d;
        ssl_session_cache shared:MozSSL:10m;
        ssl_session_tickets off;
        ssl_certificate /ssl/{{ .options.certfile }};
        ssl_certificate_key /ssl/{{ .options.keyfile }};

        # dhparams file
        ssl_dhparam /data/dhparams.pem;

        {{- if not .options.real_ip_from  }}
        listen {{ if .options.listen_ipv6 }}[::]:443 {{ end }}443 ssl;
        http2 on;
        {{- else }}
        listen {{ if .options.listen_ipv6 }}[::]:443 {{ end }}443 ssl proxy_protocol;
        http2 on;
        {{- range .options.real_ip_from }}
        set_real_ip_from {{.}};
        {{- end  }}
        real_ip_header proxy_protocol;
        {{- end }}

        {{- if .options.hsts }}
        add_header Strict-Transport-Security "{{ .options.hsts }}" always;
        {{- end }}

        proxy_buffering off;

        {{- if .options.customize.active }}
        include /share/{{ .options.customize.default }};
        {{- end }}

        location / {
            proxy_pass http://homeassistant.local.hass.io:{{ .variables.port }};
            proxy_set_header Origin $http_origin;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $http_host;
            proxy_redirect http:// https://;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header X-Forwarded-Host $http_host;
            {{- if not .options.real_ip_from }}
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            {{- else }}
            proxy_set_header X-Real-IP $proxy_protocol_addr;
            proxy_set_header X-Forwarded-For $proxy_protocol_addr;
            {{- end }}
        }
    }

    {{- if .options.customize.active }}
    include /share/{{ .options.customize.servers }};
    {{- end }}
}

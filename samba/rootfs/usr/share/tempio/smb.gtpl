[global]
   netbios name = {{ env "HOSTNAME" }}
   workgroup = {{ .workgroup }}
   server string = Samba Home Assistant
   local master = {{ .local_master | ternary "yes" "no" }}

   security = user
   ntlm auth = yes
   idmap config * : backend = tdb
   idmap config * : range = 1000000-2000000
   username map = /etc/samba/smbusers

   load printers = no
   disable spoolss = yes

   log level = 1

   bind interfaces only = yes
   interfaces = lo {{ .interfaces | join " " }}
   hosts allow = 127.0.0.1 {{ .allow_hosts | join " " }}

   {{ if .compatibility_mode }}
   client min protocol = NT1
   server min protocol = NT1
   {{ end }}

   mangled names = no
   dos charset = CP850
   unix charset = UTF-8
   
   {{ if .apple_compatibility_mode }}
   vfs objects = catia fruit streams_xattr
   {{ end }}

   {{ if not .netbios }}
   smb ports = 445
   {{ end }}

   server signing = {{ .server_signing }}

   kernel oplocks = yes

{{ if (has "config" .enabled_shares) }}
[config]
   browseable = yes
   writeable = yes
   path = /homeassistant

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if or (has "local_apps" .enabled_shares) (has "addons" .enabled_shares) }}
[local_apps]
   browseable = yes
   writeable = yes
   path = /local_apps

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if or (has "local_apps" .enabled_shares) (has "addons" .enabled_shares) }}
[addons]
   browseable = yes
   writeable = yes
   path = /local_apps
   preexec = /usr/bin/logger -s -t smbd -p local0.warning "%u connected to deprecated share %S from %m (%I), please switch to the local_apps share"

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if or (has "app_configs" .enabled_shares) (has "addon_configs" .enabled_shares) }}
[app_configs]
   browseable = yes
   writeable = yes
   path = /app_configs

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if or (has "app_configs" .enabled_shares) (has "addon_configs" .enabled_shares) }}
[addon_configs]
   browseable = yes
   writeable = yes
   path = /app_configs
   preexec = /usr/bin/logger -s -t smbd -p local0.warning "%u connected to deprecated share %S from %m (%I), please switch to the app_configs share"

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if (has "ssl" .enabled_shares) }}
[ssl]
   browseable = yes
   writeable = yes
   path = /ssl

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if (has "share" .enabled_shares) }}
[share]
   browseable = yes
   writeable = yes
   path = /share

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if (has "backup" .enabled_shares) }}
[backup]
   browseable = yes
   writeable = yes
   path = /backup

   valid users = {{ .username }}
   force user = root
   force group = root
   kernel oplocks = no
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if (has "media" .enabled_shares) }}
[media]
   browseable = yes
   writeable = yes
   path = /media

   valid users = {{ .username }}
   force user = root
   force group = root
   kernel oplocks = no
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

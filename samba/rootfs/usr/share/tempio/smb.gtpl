[global]
   netbios name = {{ env "HOSTNAME" }}
   workgroup = {{ .workgroup }}
   server string = Samba Home Assistant

   security = user
   ntlm auth = yes
   idmap config * : backend = tdb
   idmap config * : range = 1000000-2000000

   load printers = no
   disable spoolss = yes

   log level = 1

   bind interfaces only = yes
   interfaces = 127.0.0.1 {{ .interfaces | join " " }}
   hosts allow = 127.0.0.1 {{ .allow_hosts | join " " }}

   {{ if .compatibility_mode }}
   client min protocol = NT1
   server min protocol = NT1
   {{ end }}

   mangled names = no
   dos charset = CP850
   unix charset = UTF-8

   vfs objects = catia fruit streams_xattr

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

{{ if (has "addons" .enabled_shares) }}
[addons]
   browseable = yes
   writeable = yes
   path = /addons

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

{{ if (has "addon_configs" .enabled_shares) }}
[addon_configs]
   browseable = yes
   writeable = yes
   path = /addon_configs

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
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}
{{ end }}

[global]
   netbios name = {{ env "HOSTNAME" }}
   workgroup = {{ .workgroup }}
   server string = Samba Home Assistant

   security = user
   ntlm auth = yes

   load printers = no
   disable spoolss = yes

   log level = 2

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

[config]
   browseable = yes
   writeable = yes
   path = /config

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}

[addons]
   browseable = yes
   writeable = yes
   path = /addons

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}

[ssl]
   browseable = yes
   writeable = yes
   path = /ssl

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}

[share]
   browseable = yes
   writeable = yes
   path = /share

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}

[backup]
   browseable = yes
   writeable = yes
   path = /backup

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}

[media]
   browseable = yes
   writeable = yes
   path = /media

   valid users = {{ .username }}
   force user = root
   force group = root
   veto files = /{{ .veto_files | join "/" }}/
   delete veto files = {{ eq (len .veto_files) 0 | ternary "no" "yes" }}

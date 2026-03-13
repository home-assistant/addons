[global]
   netbios name = {{ env "HOSTNAME" }}
   dns hostname = {{ env "HOSTNAME" }}.local
   additional dns hostnames = {{ env "HOSTNAME" }}._smb._tcp.local
   workgroup = {{ .workgroup }}
   server string = Samba Home Assistant
   local master = {{ .local_master | ternary "yes" "no" }}
   preferred master = {{ .local_master | ternary "yes" "auto" }}
   server role = standalone
   {{ $smb_port := default 445 (index .ports "445/tcp") -}}
   {{ $nbt_port := default 139 (index .ports "139/tcp") -}}
   smb ports = {{ cat $smb_port (ternary $nbt_port nil .netbios) }}

   security = user
   idmap config * : backend = tdb
   idmap config * : range = 1000000-2000000

   load printers = no
   disable spoolss = yes
   {{ if .netbios -}}
   server services = smb nbt
   {{ else -}}
   disable netbios = yes
   server services = smb
   {{ end -}}
   dns proxy = no
   
   log level = 1

   bind interfaces only = yes
   interfaces = lo {{ .interfaces | join " " }}
   hosts allow = 127.0.0.1 {{ .allow_hosts | join " " }}

   {{ if .compatibility_mode -}}
   client min protocol = NT1
   server min protocol = NT1
   lanman auth = yes
   ntlm auth = yes
   {{ end -}}

   mangled names = no
   dos charset = CP850
   unix charset = UTF-8
   
   {{ if .apple_compatibility_mode -}}
   vfs objects = catia fruit streams_xattr
   {{ end -}}

   server signing = {{ .server_signing }}
   allow dns updates = disabled

{{ range $i, $share := .enabled_shares -}}
[{{ $share }}]
   path = /smbshare/{{ ternary "homeassistant" $share ( eq $share "config" ) }}
   include = /etc/samba/smb.conf.inc
{{ end -}}

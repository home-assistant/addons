# /etc/mdns.d/smb.service -- mDNS-SD advertisement of SMB service
type _smb._tcp
name {{ env "HOSTNAME" }}
{{ $smb_port := default (index .ports "139/tcp") (index .ports "445/tcp") | default 445 -}}
port {{ $smb_port }}
txt s=samba
txt v={{ .sambaversion }}

### Seems to be a bug in mdnsd when setting target or cname
# target ha.local
# cname smb.ha.local

txt adVF=0x82
txt adVN=Home Assistant
{{ range $i, $share := .enabled_shares -}}
txt dk{{ $i }}={{ $share }}
{{ end -}}
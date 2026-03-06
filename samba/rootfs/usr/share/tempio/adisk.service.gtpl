# /etc/mdns.d/adisk.service -- mDNS-SD _adisk._tcp for macOS Finder
# macOS uses _adisk._tcp TXT records to discover SMB shares and honours
# the port from the companion _smb._tcp SRV record.
name {{ env "HOSTNAME" }}
type _adisk._tcp
port 9
txt sys=adVF=0x100
{{ range $i, $share := .enabled_shares -}}
txt dk{{ $i }}=adVN={{ $share }},adVF=0x80
{{ end -}}
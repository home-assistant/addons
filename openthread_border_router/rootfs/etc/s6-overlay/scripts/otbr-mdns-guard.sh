#!/usr/bin/with-contenv bashio
# otbr-mdns-guard — LAN multicast-storm guard (validated 2026-10-02).
# Caps multicast mDNS (224.0.0.251 / ff02::fb) and, when mdns_guard_extra is set,
# LLMNR (224.0.0.252 / ff02::1:3, 5355) + SSDP (239.255.255.250 / ff02::c, 1900)
# in+out over the backbone interface with the nft `limit` ACCEPT/DROP pair, so a
# multicast amplification storm cannot starve the HA stack. Unicast SRP/mDNS and all
# wpan0 Thread rules are untouched.
# Options: mdns_guard (bool), mdns_guard_extra (bool) and mdns_guard_{in,out}_{rate,burst}.

ITF=$(bashio::config 'backbone_interface' 'end0')

if bashio::config.true 'mdns_guard'; then
  IN_RATE=$(bashio::config 'mdns_guard_in_rate' '40/second')
  IN_BURST=$(bashio::config 'mdns_guard_in_burst' '120')
  OUT_RATE=$(bashio::config 'mdns_guard_out_rate' '30/second')
  OUT_BURST=$(bashio::config 'mdns_guard_out_burst' '60')
  EXTRA="no"
  bashio::config.true 'mdns_guard_extra' && EXTRA="yes"

  nft delete table inet otbr_mdns_guard 2>/dev/null || true
  (
    printf 'table inet otbr_mdns_guard {\n'
    # ---- ingress ----
    printf '  chain mg_in4 {\n    type filter hook input priority 0; policy accept;\n'
    printf '    iifname "%s" ip daddr 224.0.0.251 udp dport 5353 limit rate %s burst %s packets counter accept\n' "$ITF" "$IN_RATE" "$IN_BURST"
    printf '    iifname "%s" ip daddr 224.0.0.251 udp dport 5353 counter drop\n' "$ITF"
    if [ "$EXTRA" = "yes" ]; then
      printf '    iifname "%s" ip daddr 224.0.0.252 udp dport 5355 limit rate %s burst %s packets counter accept\n' "$ITF" "$IN_RATE" "$IN_BURST"
      printf '    iifname "%s" ip daddr 224.0.0.252 udp dport 5355 counter drop\n' "$ITF"
      printf '    iifname "%s" ip daddr 239.255.255.250 udp dport 1900 limit rate %s burst %s packets counter accept\n' "$ITF" "$IN_RATE" "$IN_BURST"
      printf '    iifname "%s" ip daddr 239.255.255.250 udp dport 1900 counter drop\n' "$ITF"
    fi
    printf '  }\n'
    printf '  chain mg_in6 {\n    type filter hook input priority 0; policy accept;\n'
    printf '    iifname "%s" ip6 daddr ff02::fb udp dport 5353 limit rate %s burst %s packets counter accept\n' "$ITF" "$IN_RATE" "$IN_BURST"
    printf '    iifname "%s" ip6 daddr ff02::fb udp dport 5353 counter drop\n' "$ITF"
    if [ "$EXTRA" = "yes" ]; then
      printf '    iifname "%s" ip6 daddr ff02::1:3 udp dport 5355 limit rate %s burst %s packets counter accept\n' "$ITF" "$IN_RATE" "$IN_BURST"
      printf '    iifname "%s" ip6 daddr ff02::1:3 udp dport 5355 counter drop\n' "$ITF"
      printf '    iifname "%s" ip6 daddr ff02::c udp dport 1900 limit rate %s burst %s packets counter accept\n' "$ITF" "$IN_RATE" "$IN_BURST"
      printf '    iifname "%s" ip6 daddr ff02::c udp dport 1900 counter drop\n' "$ITF"
    fi
    printf '  }\n'
    # ---- egress ----
    printf '  chain mg_out4 {\n    type filter hook output priority 0; policy accept;\n'
    printf '    oifname "%s" ip daddr 224.0.0.251 udp sport 5353 limit rate %s burst %s packets counter accept\n' "$ITF" "$OUT_RATE" "$OUT_BURST"
    printf '    oifname "%s" ip daddr 224.0.0.251 udp sport 5353 counter drop\n' "$ITF"
    if [ "$EXTRA" = "yes" ]; then
      printf '    oifname "%s" ip daddr 224.0.0.252 udp sport 5355 limit rate %s burst %s packets counter accept\n' "$ITF" "$OUT_RATE" "$OUT_BURST"
      printf '    oifname "%s" ip daddr 224.0.0.252 udp sport 5355 counter drop\n' "$ITF"
      printf '    oifname "%s" ip daddr 239.255.255.250 udp sport 1900 limit rate %s burst %s packets counter accept\n' "$ITF" "$OUT_RATE" "$OUT_BURST"
      printf '    oifname "%s" ip daddr 239.255.255.250 udp sport 1900 counter drop\n' "$ITF"
    fi
    printf '  }\n'
    printf '  chain mg_out6 {\n    type filter hook output priority 0; policy accept;\n'
    printf '    oifname "%s" ip6 daddr ff02::fb udp sport 5353 limit rate %s burst %s packets counter accept\n' "$ITF" "$OUT_RATE" "$OUT_BURST"
    printf '    oifname "%s" ip6 daddr ff02::fb udp sport 5353 counter drop\n' "$ITF"
    if [ "$EXTRA" = "yes" ]; then
      printf '    oifname "%s" ip6 daddr ff02::1:3 udp sport 5355 limit rate %s burst %s packets counter accept\n' "$ITF" "$OUT_RATE" "$OUT_BURST"
      printf '    oifname "%s" ip6 daddr ff02::1:3 udp sport 5355 counter drop\n' "$ITF"
      printf '    oifname "%s" ip6 daddr ff02::c udp sport 1900 limit rate %s burst %s packets counter accept\n' "$ITF" "$OUT_RATE" "$OUT_BURST"
      printf '    oifname "%s" ip6 daddr ff02::c udp sport 1900 counter drop\n' "$ITF"
    fi
    printf '  }\n'
    printf '}\n'
  ) | nft -f -

  bashio::log.info "otbr-mdns-guard: enabled on $ITF (in ${IN_RATE}/${IN_BURST} out ${OUT_RATE}/${OUT_BURST}, extra=$EXTRA)"
else
  nft delete table inet otbr_mdns_guard 2>/dev/null || true
  bashio::log.info "otbr-mdns-guard: disabled"
fi

exit 0

#!/bin/ash

SS_MERLIN_HOME=/opt/share/ss-merlin
SHADOW_CONFIG_FILE=${SS_MERLIN_HOME}/etc/shadowsocks/config.json

# Start if process not running
ss_pid=$(pidof ssr-redir)
if [[ -z "$ssr_pid" ]]; then
  ssr-redir -c ${SHADOW_CONFIG_FILE} -f /opt/var/run/ssr-redir.pid
fi

sleep 3

unbound_pid=$(pidof unbound)
if [[ -z "$unbound_pid" ]]; then
  unbound -c ${SS_MERLIN_HOME}/etc/unbound/unbound.conf
fi

echo "All service started."

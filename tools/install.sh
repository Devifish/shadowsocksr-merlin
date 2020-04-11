#!/bin/ash

install() {
  set -e

  ansi_red="\033[1;31m"
  ansi_green="\033[1;32m"
  ansi_yellow="\033[1;33m"
  ansi_std="\033[m"

  SS_MERLIN_HOME=/opt/share/ss-merlin

  echo -e "$ansi_green Checking installation environment... $ansi_std"
  if ! git --version 2>/dev/null; then
    echo -e "$ansi_red Error: git is not installed, please install git first! $ansi_std"
    exit 1
  fi

  if ! opkg --version 2>/dev/null; then
    echo -e "$ansi_red Error: opkg is not found, please install Entware first! $ansi_std"
    exit 1
  fi

  if [[ ! -d /jffs ]]; then
    echo -e "$ansi_red JFFS partition not exist, please enable JFFS partition first! $ansi_std"
    exit 1
  fi

  if [[ -d "$SS_MERLIN_HOME" ]]; then
    echo -e "$ansi_yellow You already have shadowsocks-asuswrt-merlin installed. $ansi_std"
    echo -e "$ansi_yellow You'll need to delete $SS_MERLIN_HOME if you want to re-install. $ansi_std"
    exit 1
  fi

  echo -e "$ansi_green Installing required packages... $ansi_std"
  opkg update
  opkg upgrade
  opkg install haveged unbound-daemon shadowsocksr-libev
  /opt/etc/init.d/S02haveged start

  echo -e "$ansi_green Giving execute permissions... $ansi_std"
  chmod +x ${SS_MERLIN_HOME}/bin/*
  chmod +x ${SS_MERLIN_HOME}/scripts/*.sh
  chmod +x ${SS_MERLIN_HOME}/tools/*.sh

  echo -e "$ansi_green Updating IP and DNS whitelists... $ansi_std"
  ${SS_MERLIN_HOME}/scripts/update_ip_whitelist.sh
  ${SS_MERLIN_HOME}/scripts/update_dns_whitelist.sh

  echo -e "$ansi_green Updating GFW list... $ansi_std"
  ${SS_MERLIN_HOME}/scripts/update_gfwlist.sh

  echo -e "$ansi_green Creating system links... $ansi_std"
  ln -sf ${SS_MERLIN_HOME}/bin/ss-merlin /opt/bin/ss-merlin

  echo -e "$ansi_green Creating dnsmasq config file... $ansi_std"
  if [[ ! -f /jffs/configs/dnsmasq.conf.add ]]; then
    touch /jffs/configs/dnsmasq.conf.add
  fi

  set +e
  # Remove default start script
  rm -f /opt/etc/init.d/S22shadowsocks 2>/dev/null
  rm -f /opt/etc/init.d/S61unbound 2>/dev/null

  # Remove default configutation files
  rm -rf /opt/etc/shadowsocks 2>/dev/null
  rm -rf /opt/etc/unbound/ 2>/dev/null
}

install

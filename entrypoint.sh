#!/bin/sh
TEST_IP="2606:4700:4700::1111"

if [ -z "$PROXY_INTERFACE" ]
then
echo "Proxy Interface is not given. Trying to find interface.
You can also set manualy env variable in docker with -e PROXY_INTERFACE=\"eth0\""
PROXY_INTERFACE=`ip ro get $TEST_IP | awk -F"dev " '{print $2}' | cut -d " " -f 1`
  if [ $? -eq 0 ]
  then
    if [ -d "/sys/class/net/$PROXY_INTERFACE" ]; then
      echo "Proxy interface is setted to $PROXY_INTERFACE"
    else
      echo "Err: Program does not found correct interface, $PROXY_INTERFACE" >&2
    fi
  else
    echo "Err: Program can not found interface, $PROXY_INTERFACE" >&2
  fi
fi

if [ -z "$IPv6_SUBNET" ]
then
echo "IPv6_SUBNET is not set. System try to find subnet.
You can set manualy env variable in docker with -e IPv6=\"2001:db8:900d:c0de::/64\" arg."
IPv6_SUBNET=`ip ro get $TEST_IP | awk -F"src " '{print $2}' | awk -F":" '{print $1":"$2":"$3":"$4"::/64"}'`
fi

echo "Proxy Interface: $PROXY_INTERFACE
IPv6 Subnet: $IPv6_SUBNET"

if [ -z "$DOCKER_INTERFACE" ]
then
  echo "Docker Interface: is not setted. Using static method"
  cat << EOF > /etc/ndppd.conf
route-ttl 30000
proxy $PROXY_INTERFACE {
  router yes
  timeout 500
  ttl 30000
  rule $IPv6_SUBNET {
    static
  }
}
EOF
else
  # This method recommend for Scaleway,Ovh,Digitalocean
  echo "Docker Interface: $DOCKER_INTERFACE"
  cat << EOF > /etc/ndppd.conf
route-ttl 30000
proxy $PROXY_INTERFACE {
  router yes
  timeout 500
  ttl 30000
  rule $IPv6_SUBNET {
    iface $DOCKER_INTERFACE
  }
}
EOF
fi
trap exit_trap INT EXIT

/usr/sbin/ndppd -c /etc/ndppd.conf -v

if [ $? -eq 0 ]
then
  echo "Error. ndppd exited with err."
  sleep 5
else
  exit_trap
fi

function exit_trap() {
    echo "Program closed."
}
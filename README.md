# NDPPD Container System

***ndppd***, or ***NDP Proxy Daemon***, is a daemon that proxies *neighbor discovery* messages. It listens for *neighbor solicitations* on a
specified interface and responds with *neighbor advertisements* - as described in **RFC 4861** (section 7.2).

## Container

You can easily run ndppd on your system with docker container.

You can just run container and system will be automatically detect your /64 prefix and
your proxy interface.

```bash
docker run -it --restart always --cap-add NET_ADMIN --cap-add NET_RAW --network host ahmetozer/ndppd
```

If you want to set default proxy interface by manual, set `PROXY_INTERFACE` variable to your interface.  
If the program is not detect right IPv6 subnet, please set also `IPv6_SUBNET` variable by manual.
System normally runs static mode but if you define `DOCKER_INTERFACE`, system only forward requests to your defined docker interface.

```bash
#       Examples        #

#   Set Proxy Interface by manual
docker run -it --restart always --cap-add NET_ADMIN --cap-add NET_RAW --network host -e PROXY_INTERFACE="enp0s4" ahmetozer/ndppd

#   Set IPv6 subnet by manual
docker run -it --restart always --cap-add NET_ADMIN --cap-add NET_RAW --network host -e IPv6_SUBNET="2001:db8:900d:c0de::/64" ahmetozer/ndppd

#   Set IPv6 subnet and Proxy Interface by manual
docker run -it --restart always --cap-add NET_ADMIN --cap-add NET_RAW --network host -e PROXY_INTERFACE="enp0s4" -e IPv6_SUBNET="2001:db8:900d:c0de::/64" ahmetozer/ndppd

#   Set IPv6 subnet and Proxy Interface by manual and dedicated Docker interface
docker run -it --restart always --cap-add NET_ADMIN --cap-add NET_RAW --network host -e PROXY_INTERFACE="enp0s4" -e IPv6_SUBNET="2001:db8:900d:c0de::/64" -e DOCKER_INTERFACE="docker0" ahmetozer/ndppd

#   Dedicated Docker interface only
docker run -it --restart always --cap-add NET_ADMIN --cap-add NET_RAW --network host -e DOCKER_INTERFACE="docker0" ahmetozer/ndppd
```

### Run in other container network

For any reason, you might be run under other container network. For this purpose, you can follow the below examples.

```bash
docker run -it --rm --privileged -e container_name=net-tools-service -v /proc/:/proc2/ -v /var/run/docker.sock:/var/run/docker.sock --name teredo ahmetozer/ndppd
```

```bash
# Please change container_name variable to your container id or name.
container_name="net-tools-service"

docker run -it --rm --privileged -v /proc/$(docker inspect -f '{{.State.Pid}}' $container_name)/ns/net:/var/run/netns/container ahmetozer/ndppd
```

If you don't want to run container for NDP proxy, here is bash solution [dockeripv6.sh](https://gist.github.com/ahmetozer/a08345dd9c04e08bf0df342cf079f8fc)

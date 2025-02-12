#!/bin/bash

# openstack network create                                                                                                                                                                   
# usage: openstack network create [-h] [-f {json,shell,table,value,yaml}] [-c COLUMN] [--noindent] [--prefix PREFIX] [--max-width <integer>] [--fit-width] [--print-empty]
#     [--extra-property type=<property_type>,name=<property_name>,value=<property_value>] [--share | --no-share] [--enable | --disable] [--project <project>]
#     [--description <description>] [--mtu <mtu>] [--project-domain <project-domain>] [--availability-zone-hint <availability-zone>]
#     [--enable-port-security | --disable-port-security] [--external | --internal] [--default | --no-default] [--qos-policy <qos-policy>]
#     [--transparent-vlan | --no-transparent-vlan] [--provider-network-type <provider-network-type>] [--provider-physical-network <provider-physical-network>]
#     [--provider-segment <provider-segment>] [--dns-domain <dns-domain>] [--tag <tag> | --no-tag]
#     <name>

# openstack subnet create                                                                                                                                                               1 ↵  
# usage: openstack subnet create [-h] [-f {json,shell,table,value,yaml}] [-c COLUMN] [--noindent] [--prefix PREFIX] [--max-width <integer>] [--fit-width] [--print-empty]
#     [--extra-property type=<property_type>,name=<property_name>,value=<property_value>] [--project <project>] [--project-domain <project-domain>]
#     [--subnet-pool <subnet-pool> | --use-prefix-delegation USE_PREFIX_DELEGATION | --use-default-subnet-pool] [--prefix-length <prefix-length>] [--subnet-range <subnet-range>]
#     [--dhcp | --no-dhcp] [--dns-publish-fixed-ip | --no-dns-publish-fixed-ip] [--gateway <gateway>] [--ip-version {4,6}]
#     [--ipv6-ra-mode {dhcpv6-stateful,dhcpv6-stateless,slaac}] [--ipv6-address-mode {dhcpv6-stateful,dhcpv6-stateless,slaac}] [--network-segment <network-segment>] --network
#     <network> [--description <description>] [--allocation-pool start=<ip-address>,end=<ip-address>] [--dns-nameserver <dns-nameserver>]
#     [--host-route destination=<subnet>,gateway=<ip-address>] [--service-type <service-type>] [--tag <tag> | --no-tag]
#     <name>

openstack network create \
--share \
--external \
--provider-network-type flat \
--provider-physical-network physnet \
public-network

openstack subnet create \
--network 'public-network' \
--subnet-range 200.18.99.0/24 \
--allocation-pool start=200.18.99.112,end=200.18.99.119 \
--gateway 200.18.99.1 \
--dns-nameserver 200.18.99.1 --dns-nameserver 1.1.1.1 --dns-nameserver 8.8.8.8 \
--no-dhcp \
'public-subnet'
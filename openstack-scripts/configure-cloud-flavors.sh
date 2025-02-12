#!/bin/bash

# openstack flavor create
#     [--id <id>]
#     [--ram <size-mb>]
#     [--disk <size-gb>]
#     [--ephemeral-disk <size-gb>]
#     [--swap <size-mb>]
#     [--vcpus <num-cpu>]
#     [--rxtx-factor <factor>]
#     [--public | --private]
#     [--property <key=value> [...] ]
#     [--project <project>]
#     [--project-domain <project-domain>]
#     <flavor-name>

openstack flavor create --ram 512   --disk 1   --vcpus 1  m1.nano
openstack flavor create --ram 1024  --disk 1   --vcpus 1  m1.micro
openstack flavor create --ram 2048  --disk 20  --vcpus 1  m1.small
openstack flavor create --ram 4096  --disk 10  --vcpus 2  m1.medium
openstack flavor create --ram 8192  --disk 80  --vcpus 4  m1.large
openstack flavor create --ram 16384 --disk 80  --vcpus 4  m1.xlarge
openstack flavor create --ram 32768 --disk 80  --vcpus 4  m1.2xlarge

openstack flavor create --ram 512   --vcpus 1  m2.nano
openstack flavor create --ram 1024  --vcpus 1  m2.micro
openstack flavor create --ram 2048  --vcpus 1  m2.small
openstack flavor create --ram 4096  --vcpus 2  m2.medium
openstack flavor create --ram 8192  --vcpus 4  m2.large
openstack flavor create --ram 16384 --vcpus 4  m2.xlarge
openstack flavor create --ram 32768 --vcpus 4  m2.2xlarge

openstack flavor create --ram 512   --vcpus 1    m3.nano
openstack flavor create --ram 1024  --vcpus 1    m3.micro
openstack flavor create --ram 2048  --vcpus 2    m3.small
openstack flavor create --ram 4096  --vcpus 4    m3.medium
openstack flavor create --ram 8192  --vcpus 8    m3.large
openstack flavor create --ram 16384 --vcpus 16   m3.xlarge
openstack flavor create --ram 32768 --vcpus 32   m3.2xlarge
openstack flavor create --ram 65536 --vcpus 64   m3.4xlarge
openstack flavor create --ram 131072 --vcpus 96  m3.8xlarge
openstack flavor create --ram 262144 --vcpus 192 m3.16xlarge
openstack flavor create --ram 393216 --vcpus 192 m3.32xlarge
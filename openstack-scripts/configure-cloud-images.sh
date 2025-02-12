#!/bin/bash

wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-uefi1.img                      	    # Ubuntu 16.04 LTS (Xenial Xerus)
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img                            	    # Ubuntu 18.04 LTS (Bionic Beaver)
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img                              	    # Ubuntu 20.04 LTS (Focal Fossa)
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img                              	    # Ubuntu 22.04 LTS (Jammy Jellyfish)
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img					                    # Ubuntu 24.04 LTS (Noble Numbat)
wget https://ap.edge.kernel.org/fedora/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2	# Fedora Cloud 40
wget https://ap.edge.kernel.org/fedora/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2    	    # Fedora Cloud 39
wget https://ap.edge.kernel.org/fedora/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2    	    # Fedora Cloud 38
wget https://ap.edge.kernel.org/fedora/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-37-1.7.x86_64.qcow2    	    # Fedora Cloud 37
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2				                # Debian 11 (Bullseye)
wget https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2				                # Debian 12 (Bookworm)

openstack image create --disk-format qcow2 --container-format docker --shared --file xenial-server-cloudimg-amd64-uefi1.img --min-disk 5 --min-ram 1024 'Ubuntu 16.04 LTS (Xenial Xerus)' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file bionic-server-cloudimg-amd64.img --min-disk 5 --min-ram 1024 'Ubuntu 18.04 LTS (Bionic Beaver)' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file focal-server-cloudimg-amd64.img --min-disk 5 --min-ram 1024 'Ubuntu 20.04 LTS (Focal Fossa)' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file jammy-server-cloudimg-amd64.img --min-disk 5 --min-ram 1024 'Ubuntu 22.04 LTS (Jammy Jellyfish)' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file noble-server-cloudimg-amd64.img --min-disk 5 --min-ram 1024 'Ubuntu 24.04 LTS (Noble Numbat)' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2 --min-disk 5 --min-ram 1024 'Fedora 40' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file Fedora-Cloud-Base-39-1.5.x86_64.qcow2 --min-disk 5 --min-ram 1024 'Fedora 39' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file Fedora-Cloud-Base-38-1.6.x86_64.qcow2 --min-disk 5 --min-ram 1024 'Fedora 38' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file Fedora-Cloud-Base-37-1.7.x86_64.qcow2 --min-disk 5 --min-ram 1024 'Fedora 37' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file debian-11-generic-amd64.qcow2 --min-disk 5 --min-ram 1024 'Debian 11 (Bullseye)' --fit-width
openstack image create --disk-format qcow2 --container-format docker --shared --file debian-12-generic-amd64.qcow2 --min-disk 5 --min-ram 1024 'Debian 12 (Bookworm)' --fit-width

openstack image set --public 'Ubuntu 16.04 LTS (Xenial Xerus)'
openstack image set --public 'Ubuntu 18.04 LTS (Bionic Beaver)'
openstack image set --public 'Ubuntu 20.04 LTS (Focal Fossa)'
openstack image set --public 'Ubuntu 22.04 LTS (Jammy Jellyfish)'
openstack image set --public 'Ubuntu 24.04 LTS (Noble Numbat)'
openstack image set --public 'Debian 11 (Bullseye)'
openstack image set --public 'Debian 12 (Bookworm)'
openstack image set --public 'Fedora 40'
openstack image set --public 'Fedora 39'
openstack image set --public 'Fedora 38'
openstack image set --public 'Fedora 37'
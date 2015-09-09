#!/bin/sh

#Create symlink to scripts folder
ln -s /mnt/sda2/scripts /home/docker/scripts

grep -q "for f in ~/scripts/*.sh; do source \$f; done" /home/docker/.ashrc || echo "for f in ~/scripts/*.sh; do source \$f; done" >> /home/docker/.ashrc

#Create symlink to projects folder
ln -s /mnt/sda2/projects /projects

#Create symlink to certificates folder
ln -s /mnt/sda2/ssl_certs /ssl_certs

# Assign default IP address to eth1
ifconfig eth1 192.168.10.10 netmask 255.255.255.0

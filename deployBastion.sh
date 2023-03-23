#!/bin/bash

# Disk creation
qemu-img create -o preallocation=metadata -f qcow2 /var/lib/libvirt/pool/ssd/testing.eazytraining.lab.qcow2 200G

sleep 15

# Boostrap Installation
 virt-install \
 --network network:ocpnet \
 --name testing \
 --os-type=linux \
 --location /var/lib/libvirt/pool/ssd/iso/AlmaLinux-8.7-x86_64-minimal.iso \
 --ram=8192 \
 --os-variant=almalinux8 \
 --vcpus=4 \
 --disk /var/lib/libvirt/pool/ssd/testing.eazytraining.lab.qcow2 --boot hd,menu=on\
 --nographics \
 --initrd-inject /root/okd-upi-install/ks.cfg \
 --extra-args "inst.ks=file:/root/okd-upi-install/ks.cfg console=tty0 console=ttyS0,115200n8"
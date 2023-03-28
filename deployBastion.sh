#!/bin/bash
set -e -u -o pipefail

_log() {
    local level=$1; shift
    echo -e "$level: $@"
}

info() {
    _log "\nINFO\n" "$@"
}

# Disk creation
bastion_disk_creation() {
    info "Creating Bastion disk"
    qemu-img create -o preallocation=metadata -f qcow2 /var/lib/libvirt/pool/ssd/bastion.eazytraining.lab.qcow2 200G
    sleep 15
}


# Bastion Installation
bastion_installation() {
    info "Deploying Alma Linux 8.7 on the Bastion server"
    virt-install \
    --network network:ocpnet \
    --name testing \
    --os-type=linux \
    --location /var/lib/libvirt/pool/ssd/iso/AlmaLinux-8.7-x86_64-minimal.iso \
    --ram=8192 \
    --os-variant=almalinux8 \
    --vcpus=4 \
    --disk /var/lib/libvirt/pool/ssd/bastion.eazytraining.lab.qcow2 --boot hd,menu=on\
    --nographics \
    --initrd-inject /ks.cfg \
    --extra-args "inst.ks=file:/ks.cfg console=tty0 console=ttyS0,115200n8"
}

bastion_disk_creation
bastion_installation
#!/bin/bash 

# Disk Creation
qemu-img create -o preallocation=metadata -f qcow2 /var/lib/libvirt/pool/sdd/ocp-control-03.caas.eazytraining.lab.qcow2 60G 

sleep 15

# Control Plane 03 Installation
virt-install \
 --network network:ocpnet \
 --mac 52:54:00:a8:99:b6\
 --name ocp-control-03 \
 --os-type=linux \
 --ram=10240 \
 --os-variant=fedora-coreos-stable \
 --vcpus=6 \
 --disk /var/lib/libvirt/pool/sdd/ocp-control-03.caas.eazytraining.lab.qcow2 --boot hd,menu=on\
 --nographics \
 --location=http://192.168.110.9:8080/okd4-image/ \
 --extra-args "rd.neednet=1 console=tty0 console=ttyS0,115200n8 coreos.inst=yes coreos.inst.install_dev=/dev/vda \
    coreos.live.rootfs_url=http://192.168.110.9:8080/okd4-image/fcos-37-rootfs.img coreos.inst.insecure=yes \
    coreos.inst.ignition_url=http://192.168.110.9:8080/ocp4/master.ign \
    ip=192.168.110.113::192.168.110.1:255.255.255.0:ocp-control-03.caas.eazytraining.lab:enp1s0:none nameserver=192.168.110.9"

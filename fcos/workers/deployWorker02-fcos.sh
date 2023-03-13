#!/bin/bash 

# Disk Creation
qemu-img create -o preallocation=metadata -f qcow2 /var/lib/libvirt/pool/ssd/ocp-worker-02.caas.eazytraining.lab.qcow2 60G

sleep 15

# Worker 02 Installation
virt-install \
 --network network:ocpnet \
 --mac 52:54:00:3d:71:8c\
 --name ocp-worker-02 \
 --os-type=linux \
 --ram=12288 \
 --os-variant=rhel8.0 \
 --vcpus=8 \
 --disk /var/lib/libvirt/pool/ssd/ocp-worker-02.caas.eazytraining.lab.qcow2 --boot hd,menu=on\
 --nographics \
 --location=http://192.168.110.9:8080/okd4-image/ \
 --extra-args "rd.neednet=1 console=tty0 console=ttyS0,115200n8 coreos.inst=yes coreos.inst.install_dev=/dev/vda \
    coreos.live.rootfs_url=http://192.168.110.9:8080/okd4-image/fcos-37-rootfs.img coreos.inst.insecure=yes \
    coreos.inst.ignition_url=http://192.168.110.9:8080/ocp4/worker.ign \
    ip=192.168.110.115::192.168.110.1:255.255.255.0:ocp-worker-02.caas.eazytraining.lab:enp1s0:none nameserver=192.168.110.9"

# okd-upi-install

This repository provides the configurations in order to install OKD or Red Hat OpenShift through KVM (libvirt).

The folder **fcos** contain the scripts for installing OKD (Fedora CoreOS). 

### Prerequisites - Variables

In order to perform Day2 specific actions regarding authentication, persistent storage for the internal image register, it will therefore be necessary to inject environment variables. It's best to reference all the variables so you don't forget anything.

Here is below the exhaustive list: 

- `HTPASSWD_SECRET`: htpasswd secret [base64]
- `HTPASSWD_SECRET_NAME`: name of the secret
- `REGISTRY_PV_NAME`: name of the persistent volume 


# OpenShift 4 Install - User Provisioned Infrastructure (UPI)

## Architecture diagram
***

###### Information 
- Cluster name: caas
- Base Domain: eazytraining.lab 

![Diagram](diagram/eazytraining-lab.png)

**OKD VMs**
|          VM             |  CPU | Memory |     OS            |    IP Address         | Disk (GB) |
|-------------------------|------|--------|-------------------|-----------------------|-----------|
|     Bastion             |   4  |    4   |  Alma Linux 8.7   |  192.168.110.9        |     420   |
|     Master-[1-3]        |   6  |    10  |  Fedora CoreOS 37 |  192.168.110.[111-113]|     60    |
|     Worker-[1-4]        |   8  |    12  |  Fedora CoreOS 37 |  192.168.110.[114-117]|     60    | 
|     Bootstrap           |   4  |    8   |  Fedora CoreOS 37 |  192.168.110.9        |     40    |


## Download Software
***

1. Download [Alma Linux 8.7](http://mirror.almalinux.ikoula.com/8.7/isos/x86_64/AlmaLinux-8.7-x86_64-minimal.iso) for installing the bastion node
2. Download the following files
    -  [FCOS 37 Build 37.20230205.3.0](https://builds.coreos.fedoraproject.org/browser?stream=stable&arch=x86_64)
        - [kernel](https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230205.3.0/x86_64/fedora-coreos-37.20230205.3.0-live-kernel-x86_64)
        - [initramfs](https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230205.3.0/x86_64/fedora-coreos-37.20230205.3.0-live-initramfs.x86_64.img)
        - [rootfs](https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230205.3.0/x86_64/fedora-coreos-37.20230205.3.0-live-rootfs.x86_64.img)
    -  [RHCOS 4.12](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.12/4.12.0/)
        - [kernel](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.12/latest/rhcos-live-kernel-x86_64)
        - [initramfs](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.12/latest/rhcos-live-initramfs.x86_64.img)
        - [rootfs](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.12/latest/rhcos-live-rootfs.x86_64.img)
    
3. Login to [Red Hat OpenShift Cluster Manager](https://cloud.redhat.com/openshift) to download the Pull Secret
4. Select 'Create Cluster' from the 'Clusters' navigation menu
5. Select 'RedHat OpenShift Container Platform
6. Select 'Run on Bare Metal'
7. Download the Pull Secret


## Prepare the environment for installing OKD 4.12
**In KVM Hypervisor**

All the below commands should be performed by using the root account. 

1. Create the **ocpnet** network in KVM
```sh
mkdir ~/ocp && cd ocp
cat <<EOF  | tee ocpnet.xml
<network>
  <name>ocpnet</name>
  <forward mode='nat' dev='enp4s0'/>
  <bridge name='ocpnet'/>
  <ip address='192.168.110.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF
```

```sh
virsh net-define ocpnet.xml
virsh net-list --all
virsh net-autostart ocpnet
virsh net-start ocpnet
virsh net-list --all
virsh net-destroy default
virsh net-undefine default
systemctl restart libvirtd
```

4. Configure the network interfaces and the firewall 
```sh
nmcli connection modify ocpnet connection.zone internal
nmcli connection modify 'System enp4s0' connection.zone public
firewall-cmd --get-active-zones
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --reload
firewall-cmd --list-all --zone=internal
firewall-cmd --list-all --zone=public
```

3. Copy the Alma Linux 8.7 iso to the pool dedicated for the iso images on the host server. <br>
```sh
mkdir -p /var/lib/libvirt/pool/hdd/iso && cd iso
wget http://mirror.almalinux.ikoula.com/8.7/isos/x86_64/AlmaLinux-8.7-x86_64-minimal.iso
```

4. Create the Bastion node server and install Alma Linux 8.7
```sh 
qemu-img create -o preallocation=metadata -f qcow2 /var/lib/libvirt/pool/hdd/bastion.eazytraining.lab.qcow2 420G
virt-install --virt-type kvm --name bastion --ram 4192 --vcpus=4 \
   --disk /var/lib/libvirt/pool/hdd/bastion.eazytraining.lab.qcow2,format=qcow2 \
   --network network=ocpnet \
   --os-type=linux --os-variant=almalinux8 \
   --location=/var/lib/libvirt/pool/hdd/iso/AlmaLinux-8.7-x86_64-minimal.iso \
   --graphics none \
   --console pty,target_type=serial \
   --extra-args 'console=ttyS0,115200n8 serial'
```

## Configure Environmental Services

1. SSH to the Bastion server

2. Download Client and Installer tools  
```sh 
mkdir -p ~/ocp && cd ocp
curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.10/openshift-install-linux.tar.gz
curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.10/openshift-client-linux.tar.gz
```

3. Extract Client and Installer tools and copy them to /usr/local/bin
```sh 
# Client tools
tar xvf openshift-client-linux.tar.gz
mv oc kubectl /usr/local/bin

# Installer
tar xvf openshift-install-linux.tar.gz
mv openshift-install /usr/local/bin
```

4. Confirm Client and Installer tools are working 
```sh 
kubectl version
oc version
openshift-install version
```

5. Update Alma Linux and install required dependencies 
```sh 
dnf update
dnf install -y bind bind-utils dhcp-server httpd haproxy nfs-utils vim jq wget
```

6. Download [config files](https://github.com/ObieBent/okd-upi-install.git) for each of the services
```sh 
git clone https://github.com/ObieBent/okd-upi-install.git
```

7. Configure BIND DNS

Apply configuration 
```sh
cp ~/okd-upi-install/dns /etc/named.conf
cp -R ~/okd-upi-install/dns/zones /etc/named
```
  
Configure the firwall for DNS
```sh
firewall-cmd --add-port=53/tcp --permanent
firewall-cmd --reload
```



# System language
lang fr_FR
keyboard fr

# System timezone
timezone Europe/Paris

# Root password
rootpw $2b$10$CMXvi8Jb3v9q5rZFPS5i3uURq4c1xf6wBj69tLcTO.8.XxSHr/AHa --iscrypted
eula --agreed
reboot

# Use CDROM installation media
cdrom

# System bootloader configuration
bootloader --append="rhgb quiet crashkernel=auto"
zerombr

# Partition clearing information
clearpart --all --initlabel --drives=vda

# Disk partitioning
part /boot --fstype ext4 --ondisk=vda --size=1024 --asprimary
part pv.01 --size=203776
volgroup vg_eazy pv.01
logvol / --fstype ext4 --vgname vg_eazy --size=20480 --grow --name=root
logvol swap --fstype ext4 --vgname vg_eazy --size=4096 --name=swap
logvol /var --fstype ext4 --vgname vg_eazy --size=40960 --name=var
logvol /tmp --fstype ext4 --vgname vg_eazy --size=1024 --name=tmp
logvol /var/tmp --fstype ext4 --vgname vg_eazy --size=1024 --name=tempvar
logvol /home --fstype ext4 --vgname vg_eazy --size=34816 --name=home
logvol /shares --fstype ext4 --vgname vg_eazy --size=102400 --name=shares

# Network configuration
network --device=enp1s0 --gateway=192.168.110.1 --bootproto=static --ip=192.168.110.99 --nameserver=185.12.64.1,185.12.64.2 --netmask=255.255.255.0 --noipv6 --activate
network --hostname=testing.eazytraining.lab

# Do not configure the X Window System
skipx

# Run the Setup Agent on first boot
firstboot --disable

# SELinux
selinux --enforcing

# Firewalling
firewall --enabled

%packages
@^minimal-environment
@standard
@system-tools
kexec-tools
almalinux-release
firewalld
%end

%addon com_redhat_kdump --enable --reserve-mb='auto'
%end
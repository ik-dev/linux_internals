#!/bin/bash
# Based upon:
# "Lightweight Linux Kernel Development With KVM"
#  https://blog.nelhage.com/2013/12/lightweight-linux-kernel-development-with-kvm/ 
#
# TODO- setup networking, fs sharing.
# Author	: Kaiwan NB, kaiwanTECH.
# Updated	: Ibad Khan

# Config vars
ROOTFS=./rootfs
ROOTFS_FNAME=wheezy.img
MNT=/mnt/tmp

setup()
{
# Get the Debian 7 Wheezy base root filesystem using debootstrap.
# [FYI: from https://wiki.debian.org/Debootstrap :
# "debootstrap is a tool which will install a Debian base system into 
# a subdirectory of another, already installed system. It doesn't require 
# an installation CD, just access to a Debian repository. It can also be 
# installed and run from another operating system, so, for instance, you 
# can use debootstrap to install Debian onto an unused partition from a 
# running Gentoo system. It can also be used to create a rootfs for a machine 
# of a different architecture. This is "cross-debootstrapping". ...]"

# ~ 223 MB download; will take some time..
debootstrap wheezy ${ROOTFS} http://http.debian.net/debian/

#--- Perform some manual cleanup on the resulting chroot:
# Make root passwordless for convenience.
sudo sed -i '/^root/ { s/:x:/::/ }' ${ROOTFS}/etc/passwd
# Add a getty on the virtio console
echo 'V0:23:respawn:/sbin/getty 115200 hvc0' | sudo tee -a ${ROOTFS}/etc/inittab
# Automatically bring up eth0 using DHCP
printf '\nauto eth0\niface eth0 inet dhcp\n' | sudo tee -a ${ROOTFS}/etc/network/interfaces
# Set up my ssh pubkey for root in the VM
sudo mkdir ${ROOTFS}/root/.ssh/
cat ~/.ssh/id_?sa.pub | sudo tee ${ROOTFS}/root/.ssh/authorized_keys
}

build_rootfs()
{
dd if=/dev/zero of=${ROOTFS_FNAME} bs=1M seek=4095 count=1
mkfs.ext4 -F ${ROOTFS_FNAME}
}

update_rootfs()
{
[ ! -d ${MNT} ] && mkdir -p ${MNT}
mount -o loop ${ROOTFS_FNAME} ${MNT}
cp -au ${ROOTFS}/* ${MNT}/
umount ${MNT}
}


run()
{
# Note- kvm is a wrapper over qemu-system-[x86[_64]] !
HYPERVISOR=/usr/bin/kvm
# In case we are on a VM then QEMU would work fine !
# HYPERVISOR=/usr/bin/qemu-system-x86_64
$HYPERVISOR -kernel ./kernel/linux-3.10.24-x86_64/arch/x86/boot/bzImage -drive file=./wheezy.img,if=virtio -append 'root=/dev/vda console=hvc0' -chardev stdio,id=stdio,mux=on,signal=off -device virtio-serial-pci -device virtconsole,chardev=stdio -mon chardev=stdio -display none
}


### "main"
name=$(basename $0)
[ $(id -u) -ne 0 ] && {
  echo "${name}: need to run as root."
  exit 1
}

SETUP_REQD=0   # make 1 to run 'setup' and update_rootfs
[ ${SETUP_REQD} -eq 1 ] && {
 [ ! -d ${ROOTFS} ] && mkdir -p ${ROOTFS}
 setup
 build_rootfs
 update_rootfs
}
run

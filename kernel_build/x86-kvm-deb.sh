#!/bin/bash
# Based upon:
# "Lightweight Linux Kernel Development With KVM"
#  https://blog.nelhage.com/2013/12/lightweight-linux-kernel-development-with-kvm/ 
#
# TODO- setup networking, fs sharing.
# Kaiwan NB, kaiwanTECH.

#--------------------- Config vars ------------------------------------
SETUP_REQD=1     # make 1 to run the 'setup' and update_rootfs
DOWNLOAD_DEB=0   # make 1 to turn On the download
ROOTFS=./rootfs
ROOTFS_FNAME=wheezy.img
MNT=/mnt/tmp
KVM_ENABLED=0    # make 1 to use kvm
#----------------------------------------------------------------------

trap 'echo "$(basename $0): [trap] Exiting due to signal or (normal) EXIT ... " ; sync' INT QUIT EXIT HUP

FatalError()
{
  echo "${name}: Fatal Error!"
  echo "$@"
  exit 1
}

setup_deb_rootfs()
{
echo "== ${name}:setup_deb_rootfs() "

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

[ ${DOWNLOAD_DEB} -eq 1 ] && {
 debootstrap wheezy ${ROOTFS} http://http.debian.net/debian/ || {
   FatalError "${name}: debootstrap failed!"
 }
}

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

update_rootfs()
{
echo "== ${name}:update_rootfs() "
[ ! -d ${MNT} ] && mkdir -p ${MNT}
mount -o loop ${ROOTFS_FNAME} ${MNT} || {
   FatalError "${name}: loop mount failed!"
 }
cp -au ${ROOTFS}/* ${MNT}/ || {
   FatalError "${name}: cp failed!"
 }
umount ${MNT}
}

#--- Build a disk image
build_rootfs()
{
echo "== ${name}:build_rootfs() "
re="y"
[ -f ${ROOTFS_FNAME} ] && {
  echo -n "${name}: overwrite existing root filesystem image now? "
  read re
  if [ ${re} != "y" ]; then
    return
  fi
 }
rm -f ${ROOTFS_FNAME}

# 100MB
szMB=300 #1024 #250
blksz=4096
let count=(${szMB}*1024*1024)/${blksz}

dd if=/dev/zero of=${ROOTFS_FNAME} bs=${blksz} count=${count} || {
   FatalError "${name}: dd failed!"
 }
mkfs.ext4 -F ${ROOTFS_FNAME} || {
   FatalError "${name}: mkfs.ext4 failed!"
 }
update_rootfs
}

run()
{
echo "== ${name}:run() "
# Note- kvm is a wrapper over qemu-system-[x86[_64]] !
#/usr/bin/kvm 
[ ${KVM_ENABLED} -eq 0 ] && {
  qemu-system-x86_64 -kernel ./kernel/linux-3.10.24-x86_64/arch/x86/boot/bzImage -drive file=./wheezy.img,if=virtio -append 'root=/dev/vda console=hvc0'
} || {
  kvm -kernel ./kernel/linux-3.10.24-x86_64/arch/x86/boot/bzImage -drive file=./wheezy.img,if=virtio -append 'root=/dev/vda console=hvc0' -chardev stdio,id=stdio,mux=on,signal=off -device virtio-serial-pci -device virtconsole,chardev=stdio -mon chardev=stdio -display none
}
}

check_installed_pkg()
{
 which dd > /dev/null 2>&1 || {
   FatalError "The dd program does not seem to be installed! Aborting..."
 }
 which qemu-system-x86_64 > /dev/null 2>&1 || {
   FatalError "QEMU x86_64 packages do net seem to be installed! Pl Install qemu-system-x86_64 and qemu-kvm and retry.."
 }
 which kvm > /dev/null 2>&1 || {
   echo "Warning! kvm does not seem to be installed! PATH issue?"
 }
 which mkfs.ext4 > /dev/null 2>&1 || {
   FatalError "mkfs.ext4 does not seem to be installed. Aborting..."
 }
}


### "main"
name=$(basename $0)
[ $(id -u) -ne 0 ] && {
  FatalError "${name}: need to run as root."
}

[ ${SETUP_REQD} -eq 1 ] && {
  [ ! -d ${ROOTFS} ] && mkdir -p ${ROOTFS}
  check_installed_pkg
  setup_deb_rootfs
  build_rootfs
}
run

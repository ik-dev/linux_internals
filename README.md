Linux Internals Training
========================

* Compile and build Kernel from source
* Simple examples on LKM(Loadable Kernel Modules)
* Simiple example to read process information


Compiling and installing Kernel
----------------------------------------------------
Prerequisite: gcc & libncurses5(Ubuntu)

1. Get the latest Linux Kernel code from http://kernel.org/
2. Extract the source file using  
   `tar pxvf source.tar.xz` or `tar jxvf source.tar.bz3`
3. Configure kernel using  
   `make [x|g|menu]config` or `make [x|g|menu]config ARCH=x86_64`  
   Note: Architecture specific libraries are must
4. Compile the kernel using `make`
5. Compile modules `make modules` and install them `make modules_install`
6. Install the newly compiled kernel using `make install`
7. Create initrd image `cd /boot` and `mkinitramfs -o initfd.img-ver ver`
8. Update grub using `update-grub`

[SOURCE](http://www.cyberciti.biz/tips/compiling-linux-kernel-26.html)


Compiling and installing Kernel Module
----------------------------------------------------
Prerequisite: Minimal Kernel source

  1. Build ko(kernel object) file by running `make`
  2. Load ko file by running `sudo insmod hello.ko`
  3. Validate if ko was succesfully loaded by 
    * Checking `dmesg` output for 'printk' statements
    * Run `sudo lsmod` and find your module listed
  4. Unload a module by running `sudo rmmod hello`

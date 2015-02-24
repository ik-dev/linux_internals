Linux internals training

- Steps to be followed to build Kernel from source
- Simple examples on LKM(Loadable Kernel Modules)
- Simiple example to read process information

Example for working with kernel modules:
  1. Build ko(kernel object) file by running `make`
  2. Load ko file by running `sudo insmod hello.ko`
  3. Validate if ko was succesfully loaded by 
     a. Checking dmesg output for 'printk' functions
     b. Run `sudo lsmod` and find your module listed
  4. Unload a module by running `sudo rmmod hello`

ifneq ($(KERNELRELEASE),)
	obj-m := pinfo.o
else
	KERNELDIR := /lib/modules/$(shell uname -r)/build
	PWD := $(shell pwd)
default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
endif
clean:
	$(MAKE) -C $(KERNELDIR) SUBDIRS=$(PWD) clean

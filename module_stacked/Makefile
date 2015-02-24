ifneq ($(KERNELRELEASE),)
	obj-m := stacked.o
	stacked-objs := foo.o bar.o
else
	KERNELDIR := /lib/modules/$(shell uname -r)/build
	PWD := $(shell pwd)
default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
endif
clean:
	$(MAKE) -C $(KERNELDIR) SUBDIRS=$(PWD) clean

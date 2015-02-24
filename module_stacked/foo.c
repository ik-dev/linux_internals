#include <linux/init.h>
#include <linux/module.h>
#include "foo.h"

MODULE_LICENSE("Dual BSD/GPL");

// Definition of the method
void foo(void) {
	printk(KERN_INFO "%s:%s:%d I'm called\n", __FILE__, __FUNCTION__, __LINE__);
}

static int __init in(void) {
	printk(KERN_INFO "Hello world!\n");
	return 0;
}

static void __exit out(void) {
	printk(KERN_INFO "Goodbye world!\n");
}

EXPORT_SYMBOL(foo);

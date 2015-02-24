#include <linux/init.h>
#include <linux/module.h>
#include "bar.h"

MODULE_LICENSE("Dual BSD/GPL");

// Initializer
// This calls one of the methods defined under foo.c
static int __init initialize(void) {
	printk(KERN_INFO "Hello world!\n");
	foo();
	return 0;
}

// Cleanup
static void __exit cleanup(void) {
	printk(KERN_INFO "Goodbye world!\n");
}

module_init(initialize);
module_exit(cleanup);

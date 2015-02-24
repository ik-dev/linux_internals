#include <linux/init.h>
#include <linux/module.h>

// Used to indicate that module bears a free license
MODULE_LICENSE("Dual BSD/GPL");

// Initializer method
// Invoked when module is loaded
static int __init initialize(void) {
	printk(KERN_INFO "Hello world!\n");
	// Return 0 is must 
	// else kernel unloads the module
	return 0;
}

// Cleanup method
// Invoked when module is removed
static void __exit cleanup(void) {
	printk(KERN_INFO "Goodbye world!\n");
}

// Specify the initializer and cleanup methods
module_init(initialize);
module_exit(cleanup);

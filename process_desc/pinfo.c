#include <linux/init.h>
#include <linux/module.h>
#include <linux/sched.h>

static int __init initialize(void) {
	// Descriptor for each process/thread
	struct task_struct *p;
	printk(KERN_INFO "Printing process's information\n");

	// Macro defined under linux/sched.h
	for_each_process(p) {
		// Accessing process information like process_id, task_group_id...
		printk("%d\t%d\t%s\n", p->pid, p->tgid, p->comm);
	}
	return 0;
}

static void __exit cleanup(void) {
	printk(KERN_INFO "Done with printing process's information\n");
}

module_init(initialize);
module_exit(cleanup);

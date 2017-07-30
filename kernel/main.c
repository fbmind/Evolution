#include "evolution/proc.h"
#include "evolution/prot.h"
#include "global.h"
#include "stdio.h"
#include "string.h"

static void delay (int seconds);
void task_a ();
void task_b ();
void restart();

int kernel_main ()
{
	int i;
	struct proc *p_proc;

	/* init tasks */
	tasks[0].pid = pid_next++;
	tasks[0].entry = (void *) task_a;

	tasks[1].pid = pid_next++;
	tasks[1].entry = (void *) task_b;

	for (i = 0; i < sizeof tasks / sizeof tasks[0]; i++) {
		p_proc = proc_table + i;

		/* LDT */
		p_proc->ldt_sel = SELECTOR_LDT_FIRST + i * 8;
		/* Code */
		p_proc->ldts[0].limit1 = 0xFFFF;
		p_proc->ldts[0].base1 = 0x0000;
		p_proc->ldts[0].base2 = 0x00;
		p_proc->ldts[0].attr1 = 0xF8;
		p_proc->ldts[0].attr2_limit2 = 0xCF;
		p_proc->ldts[0].base3 = 0x00;
		/* Data */
		p_proc->ldts[1].limit1 = 0xFFFF;
		p_proc->ldts[1].base1 = 0x0000;
		p_proc->ldts[1].base2 = 0x00;
		p_proc->ldts[1].attr1 = 0xF2;
		p_proc->ldts[1].attr2_limit2 = 0xCF;
		p_proc->ldts[1].base3 = 0x00;

		/* init LDT descriptor in GDT */
		init_descriptor(gdt + INDEX_LDT_FIRST + i,
			(u32_t) p_proc->ldts, p_proc->ldts , LDT_ATTR);

		/* stackframe */
		p_proc->regs.cs = 0x03;
		p_proc->regs.ds = 0x0F;
		p_proc->regs.es = 0x0F;
		p_proc->regs.fs = 0x0F;
		p_proc->regs.ss = 0x0F;
		p_proc->regs.gs = 0x0F;
		p_proc->regs.eip = (u32_t) tasks[i].entry;
		p_proc->regs.esp = (u32_t) (task_stack + TASK_STACK_SIZE * i);
		p_proc->regs.eflags = 0x1202;

		/* tss */
		tss.ss0 = SELECTOR_KERNEL_CODE;
		tss.iobase = sizeof tss;
		init_descriptor(gdt + INDEX_TSS,
			(u32_t) &tss, sizeof tss - 1, TSS_ATTR);

		/* other info */
		p_proc->pid = tasks[i].pid;
	}

	proc_next = proc_table;
	restart();

	while (1) {
	}
}

void task_a () 
{
	puts("A");
	delay(3);
}

void task_b () 
{
	puts("B");
	delay(3);
}

static void delay (int seconds)
{
	int i, j;

	for (i = 0; i < seconds; i++) {
		for (j = 0; j < 100000; j++) {
		}
	}
}

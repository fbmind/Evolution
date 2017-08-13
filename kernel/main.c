#include "evolution/proc.h"
#include "evolution/prot.h"
#include "global.h"
#include "stdio.h"
#include "string.h"

static void delay (int seconds);
void task_a ();
void task_b ();
void restart ();
void task_c ();

char buf[128];

int kernel_main ()
{
	int i;
	struct proc *p_proc;

	/* init tasks */
	tasks[0].pid = pid_next++;
	tasks[0].entry = (void *) task_a;

	tasks[1].pid = pid_next++;
	tasks[1].entry = (void *) task_b;

	tasks[2].pid = pid_next++;
	tasks[2].entry = (void *) task_c;

	for (i = 0; i < sizeof tasks / sizeof tasks[0]; i++) {
		p_proc = proc_table + i;

		/* LDT */
		p_proc->ldt_sel = SELECTOR_LDT_FIRST + i * 8;
		/* Base 0x00000000
		 * Limit 0xFFFFF
		 * Type 8 exec only | P 1 exists | DPL 3 | S 1 Data or code | G 1 | D/B 1 | AVL 0
		*/
		p_proc->ldts[0].limit1 = 0xFFFF;
		p_proc->ldts[0].base1 = 0x0000;
		p_proc->ldts[0].base2 = 0x00;
		p_proc->ldts[0].attr1 = 0xF8;
		p_proc->ldts[0].attr2_limit2 = 0xCF;
		p_proc->ldts[0].base3 = 0x00;
		/* Base 0x00000000
		 * Limit 0xFFFFF
		 * Type 2 read write | P 1 exists | DPL 3 | S 1 Data or code | G 1 | D/B 1 | AVL 0
		*/
		p_proc->ldts[1].limit1 = 0xFFFF;
		p_proc->ldts[1].base1 = 0x0000;
		p_proc->ldts[1].base2 = 0x00;
		p_proc->ldts[1].attr1 = 0xF2;
		p_proc->ldts[1].attr2_limit2 = 0xCF;
		p_proc->ldts[1].base3 = 0x00;

		/* init LDT descriptor in GDT */
		init_descriptor(gdt + INDEX_LDT_FIRST + i,
			(u32_t) (p_proc->ldts), (u32_t) (sizeof p_proc->ldts - 1), LDT_ATTR);

		/* stackframe */
		p_proc->regs.cs = SELECTOR_LDT_CODE;
		p_proc->regs.ds = SELECTOR_LDT_DATA;
		p_proc->regs.es = SELECTOR_LDT_DATA;
		p_proc->regs.fs = SELECTOR_LDT_DATA;
		p_proc->regs.ss = SELECTOR_LDT_DATA;
		p_proc->regs.gs = SELECTOR_LDT_DATA;
		p_proc->regs.eip = (u32_t) tasks[i].entry;
		p_proc->regs.esp = (u32_t) (task_stack + TASK_STACK_SIZE * i);
		p_proc->regs.eflags = 0x1002; // 0x1202

		/* other info */
		p_proc->pid = tasks[i].pid;
	}

	/* tss */
	tss.ss0 = SELECTOR_KERNEL_DATA;
	tss.iobase = sizeof tss;
	init_descriptor(gdt + INDEX_TSS,
		(u32_t) &tss, sizeof tss - 1, TSS_ATTR);

	proc_next = proc_table;
	restart();

	while (1) {
	}
}

void task_a ()
{
	while (1) {
		puts("A");
		delay(3);
	}
}

void task_b ()
{
	while (1) {
		puts("B");
		delay(3);
	}
}

void task_c ()
{
	while (1) {
		puts("C");
		delay(3);
	}
}

static void delay (int seconds)
{
	int i, j;

	for (i = 0; i < seconds; i++) {
		for (j = 0; j < 100000; j++) {
		}
	}
}

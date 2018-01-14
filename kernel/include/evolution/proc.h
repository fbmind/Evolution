#ifndef _PROC_H_
#define _PROC_H_

#include "evolution/type.h"
#include "evolution/prot.h"

#define NR_TASKS 3
#define TASK_STACK_SIZE 1024
#define KERNEL_STACK_SIZE 1024

#define MAX_PROC_TICKS 100

typedef struct stackframe {
	u32_t gs;
	u32_t fs;
	u32_t es;
	u32_t ds;
	u32_t edi;
	u32_t esi;
	u32_t ebp;
	u32_t kernel_esp;
	u32_t ebx;
	u32_t edx;
	u32_t ecx;
	u32_t eax;
	u32_t ret_addr;
	u32_t eip;
	u32_t cs;
	u32_t eflags;
	u32_t esp;
	u32_t ss;
} stackframe_t;

typedef struct proc {
	stackframe_t regs;
	u16_t ldt_sel;
	descriptor_t ldts[LDT_SIZE];
	u32_t pid;
	u32_t ticks;
	char p_name[16];
} proc_t;

typedef struct tss {
	u32_t backlink;
	u32_t esp0;
	u32_t ss0;
	u32_t esp1;
	u32_t ss1;
	u32_t esp2;
	u32_t ss2;
	u32_t cr3;
	u32_t eip;
	u32_t flags;
	u32_t eax;
	u32_t ecx;
	u32_t edx;
	u32_t ebx;
	u32_t esp;
	u32_t ebp;
	u32_t esi;
	u32_t edi;
	u32_t es;
	u32_t cs;
	u32_t ss;
	u32_t ds;
	u32_t fs;
	u32_t gs;
	u32_t ldt;
	u16_t trap;
	u16_t iobase;
} tss_t;

typedef struct task {
	u32_t pid;
	char p_name[16];
	void *entry;
} task_t;

void schedule();

#endif

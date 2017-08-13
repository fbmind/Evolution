#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#include "evolution/type.h"
#include "evolution/const.h"
#include "evolution/prot.h"
#include "evolution/proc.h"

#define EXTERN extern

#ifdef TABLE
	#undef EXTERN
	#define EXTERN
#endif

EXTERN descriptor_t gdt[GDT_SIZE];
EXTERN u8_t gdt_info[6];
EXTERN gate_t idt[GATE_SIZE];
EXTERN u8_t idt_info[6];
EXTERN int tty_pos;
EXTERN proc_t proc_table[NR_TASKS];
EXTERN proc_t *proc_next;
EXTERN tss_t tss;
EXTERN task_t tasks[NR_TASKS];
EXTERN u32_t pid_next;
EXTERN u8_t task_stack[TASK_STACK_SIZE * NR_TASKS];

#endif

#include "evolution/type.h"
#include "evolution/prot.h"
#include "evolution/proc.h"

#include "global.h"
#include "stdio.h"
#include "string.h"

/* Exception they call exception_handler */
void divide_error ();
void single_step_exception ();
void nmi ();
void breakpoint_exception ();
void overflow ();
void bounds_check ();
void inval_opcode ();
void copr_not_available ();
void double_fault ();
void copr_seg_overrun ();
void inval_tss ();
void segment_not_present ();
void stack_exception ();
void general_protection ();
void page_fault ();
void copr_error ();

/* Interrupt */
void hwint00 ();

void clock_handler();

void init_idt ()
{
	init_gate(idt, SELECTOR_KERNEL_CODE, (u32_t) divide_error, EXCEPTION_ATTR);
	init_gate(idt + 1, SELECTOR_KERNEL_CODE, (u32_t) single_step_exception, EXCEPTION_ATTR);
	init_gate(idt + 2, SELECTOR_KERNEL_CODE, (u32_t) nmi, EXCEPTION_ATTR);
	init_gate(idt + 3, SELECTOR_KERNEL_CODE, (u32_t) breakpoint_exception, EXCEPTION_ATTR);
	init_gate(idt + 4, SELECTOR_KERNEL_CODE, (u32_t) overflow, EXCEPTION_ATTR);
	init_gate(idt + 5, SELECTOR_KERNEL_CODE, (u32_t) bounds_check, EXCEPTION_ATTR);
	init_gate(idt + 6, SELECTOR_KERNEL_CODE, (u32_t) inval_opcode, EXCEPTION_ATTR);
	init_gate(idt + 7, SELECTOR_KERNEL_CODE, (u32_t) copr_not_available, EXCEPTION_ATTR);
	init_gate(idt + 8, SELECTOR_KERNEL_CODE, (u32_t) double_fault, EXCEPTION_ATTR);
	init_gate(idt + 9, SELECTOR_KERNEL_CODE, (u32_t) copr_seg_overrun, EXCEPTION_ATTR);
	init_gate(idt + 10, SELECTOR_KERNEL_CODE, (u32_t) inval_tss, EXCEPTION_ATTR);
	init_gate(idt + 11, SELECTOR_KERNEL_CODE, (u32_t) segment_not_present, EXCEPTION_ATTR);
	init_gate(idt + 12, SELECTOR_KERNEL_CODE, (u32_t) stack_exception, EXCEPTION_ATTR);
	init_gate(idt + 13, SELECTOR_KERNEL_CODE, (u32_t) general_protection, EXCEPTION_ATTR);
	init_gate(idt + 14, SELECTOR_KERNEL_CODE, (u32_t) page_fault, EXCEPTION_ATTR);
	init_gate(idt + 15, SELECTOR_KERNEL_CODE, (u32_t) copr_error, EXCEPTION_ATTR);

	init_gate(idt + 32, SELECTOR_KERNEL_CODE, (u32_t) hwint00, EXCEPTION_ATTR);

	u16_t *plimit = (u16_t *) idt_info;
	u32_t *pbase = (u32_t *) (idt_info + 2);

	*pbase = (u32_t) &idt;
	*plimit = sizeof idt - 1;
}

void exception_handler (int vector_no, int errcode, int eip, int cs, int eflags)
{
	char buf[120];
	char *errmsg[] = {
		"#DE",
		"#DB",
		"NMI",
		"#BP",
		"#OF",
		"#BR",
		"#UD",
		"#NM",
		"#DF",
		"CSO",
		"#TS",
		"#NP",
		"#SS",
		"#GP",
		"#PF",
		"Reserved",
		"#MF",
		"#AC",
		"#MC",
		"#XF",
	};

	puts("[");
	puts(errmsg[vector_no]);
	puts("/");
	uitoa(vector_no, buf, sizeof buf);
	puts(buf);
	puts("/");
	uitoa(errcode, buf, sizeof buf);
	puts(buf);
	puts("/");
	uitoa(cs, buf, sizeof buf);
	puts(buf);
	puts("/");
	uitoa(eip, buf, sizeof buf);
	puts(buf);
	puts("]");
}

void clock_handler ()
{
	proc_next->ticks++;
	schedule();
}

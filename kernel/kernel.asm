	[bits 32]
	[SECTION .text]

	global _start
	global restart

	global divide_error
	global single_step_exception
	global nmi
	global breakpoint_exception
	global overflow
	global bounds_check
	global inval_opcode
	global copr_not_available
	global double_fault
	global copr_seg_overrun
	global inval_tss
	global segment_not_present
	global stack_exception
	global general_protection
	global page_fault
	global copr_error

	global hwint00

	extern exception_handler
	extern clock_handler
	extern cstart
	extern kernel_main
	extern gdt_info
	extern idt_info
	extern proc_next
	extern kernel_stack
	extern tss

	extern reenable_8259a
	extern whoisnext

	extern debug_num

_start:
	; reload GDT
	sgdt [gdt_info]
	call cstart
	lgdt [gdt_info]

	lidt [idt_info]

	jmp CODE_SEG_SELECTOR:flush
flush:
	mov ax, DATA_SEG_SELECTOR
	mov ds, ax
	mov es, ax
	mov ax, STACK_SEG_SELECTOR
	mov ss, ax

	sti

	jmp kernel_main

restart:
	mov eax, 0
	mov ax, SELECTOR_TSS
	ltr ax

	; use proc_next's stackframe as stack
	mov esp, [proc_next]

	; use proc_next's LDT and esp0
	lldt [esp + P_LDT_SEL]
	lea eax, [esp + P_STACKTOP]
	mov dword [tss + TSS_ESP0], eax

	pop gs
	pop fs
	pop es
	pop ds
	popad

	add esp, 4

	iretd

	; idt
	; error_code vector_no
divide_error:
	push 0xFFFFFFFF
	push 0
	jmp exception

single_step_exception:
	push 0xFFFFFFFF
	push 1
	jmp exception

nmi:
	push 0xFFFFFFFF
	push 2
	jmp exception

breakpoint_exception:
	push 0xFFFFFFFF
	push 3
	jmp exception

overflow:
	push 0xFFFFFFFF
	push 4
	jmp exception

bounds_check:
	push 0xFFFFFFFF
	push 5
	jmp exception

inval_opcode:
	push 0xFFFFFFFF
	push 6
	jmp exception

copr_not_available:
	push 0xFFFFFFFF
	push 7
	jmp exception

double_fault:
	push 8
	jmp exception

copr_seg_overrun:
	push 0xFFFFFFFF
	push 9
	jmp exception

inval_tss:
	push 10
	jmp exception

segment_not_present:
	push 11
	jmp exception

stack_exception:
	push 12
	jmp exception

general_protection:
	push 13
	jmp exception

page_fault:
	push 14
	jmp exception

copr_error:
	push 0xFFFFFFFF
	push 16
	jmp exception

exception:
	call exception_handler
	add esp, 4 * 2
	hlt

hwint00:
	; save regs in stackframe
	sub esp, 4
	pushad
	push ds
	push es
	push fs
	push gs

	; use kernel segments
	mov dx, ss
	mov ds, dx
	mov es, dx

	; use kernel stack
	mov eax, esp
	mov esp, [kernel_stack]

	; push eax
	; call debug_num
	; add esp, 4

	call clock_handler
	call reenable_8259a
	; call whoisnext

	; reuse stackframe as stack
	mov esp, [proc_next]

	; use new proc's LDT and esp0
	lldt [esp + P_LDT_SEL]
	lea eax, [esp + P_STACKTOP]
	mov dword [tss + TSS_ESP0], eax

	; restore regs from stackframe
	pop gs
	pop fs
	pop es
	pop ds
	popad

	add esp, 4

	iretd

	[SECTION .data]
	CODE_SEG_SELECTOR equ 0008h
	DATA_SEG_SELECTOR equ 0010h
	STACK_SEG_SELECTOR equ 0018h
	SELECTOR_TSS equ 020h

	VIDEO_START equ 0C00B8000h

	; proc_table related consts
	P_LDT_SEL equ 72
	P_STACKTOP equ 72

	; tss related consts
	TSS_ESP0 equ 4

	[bits 32]
	[SECTION .text]

	global _start
	global restart
	global task_c

	extern cstart
	extern kernel_main
	extern gdt_info
	extern proc_next
	extern tss

_start:
	; reload GDT
	sgdt [gdt_info]
	call cstart
	lgdt [gdt_info]

	jmp CODE_SEG_SELECTOR:flush
flush:
	mov ax, DATA_SEG_SELECTOR
	mov ds, ax
	mov es, ax
	mov ax, STACK_SEG_SELECTOR
	mov ss, ax
	; mov esp, STACK_TOP

	jmp kernel_main

restart:
	mov eax, 0
	mov ax, SELECTOR_TSS
	ltr ax

	mov esp, [proc_next]
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

	hlt

task_c:
	mov eax, 1
	mov ebx, 2
	mov ecx, 3
	jmp task_c

	[SECTION .data]
	CODE_SEG_SELECTOR equ 0008h
	DATA_SEG_SELECTOR equ 0010h
	STACK_SEG_SELECTOR equ 0018h
	SELECTOR_TSS equ 020h

	VIDEO_START equ 0C00B8000h
	; STACK_TOP equ 060000h

	; proc_table related consts
	P_LDT_SEL equ 72
	P_STACKTOP equ 72

	; tss related consts
	TSS_ESP0 equ 4

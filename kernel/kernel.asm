	[bits 32]
	[SECTION .text]

	global _start
	extern cstart
	extern gdt_info

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

	; display 'Kernel'
	mov esi, kernel_msg
	mov edi, VIDEO_START+320
	mov ecx, KERNEL_MSG_LEN
	rep movsb

	hlt

	[SECTION .data]
	CODE_SEG_SELECTOR equ 0008h
	DATA_SEG_SELECTOR equ 0010h
	STACK_SEG_SELECTOR equ 0018h
	SYS_CALL_SELECTOR equ 0020h

	VIDEO_START equ 0C00B8000h
	; STACK_TOP equ 060000h

	kernel_msg db 'K', 07h, 'e', 07h, 'r', 07h, 'n', 07h, 'e', 07h, 'l', 07h
	KERNEL_MSG_LEN equ $-kernel_msg

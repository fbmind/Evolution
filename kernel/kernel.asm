	[bits 32]
	[SECTION .text]

	global _start

_start:
	; reload GDT
	lgdt [gdt_size]
	jmp CODE_SEG_SELECTOR:flush
flush:
	mov ax, DATA_SEG_SELECTOR
	mov ds, ax
	mov es, ax
	mov ax, STACK_SEG_SELECTOR
	mov ss, ax
	mov esp, STACK_TOP

	; display 'Kernel'
	mov esi, kernel_msg
	mov edi, VIDEO_START+320
	mov ecx, KERNEL_MSG_LEN
	rep movsb

	; call SYS_CALL_SELECTOR:00000000h
	hlt

kprintf:
	; KPRINTF_OFFSET equ (CODE_SEC_VSTART + $ - $$)

	; mov esi, call_msg 
	; mov edi, VIDEO_START+480
	; mov ecx, CALL_MSG_LEN
	; rep movsb

	; hlt

	; Base Limit Attr
	%macro Descriptor 3
	dw %2 & 0FFFFh
	dw %1 & 0FFFFh
	db (%1 >> 16) & 0FFh
	dw (%3 & 0F0FFh) | ((%2 >> 8) & 0F00h)
	db (%1 >> 24) & 0FFh
	%endmacro

	; Selector Offset Attr Count
	%macro CallGateDescriptor 4
	dw %2 & 0FFFFh
	dw %1
	db %4 & 01Fh
	db %3
	dw (%2 >> 16) & 0FFFFh
	%endmacro

	[SECTION .data]

GDT_BASE:
	Descriptor 00000000h, 000000h, 00000h
	Descriptor 00000000h, 0FFFFFh, 0C098h
	Descriptor 00000000h, 0FFFFFh, 0C092h
	Descriptor 00000000h, 0FFFFFh, 0C092h
	; CallGateDescriptor CODE_SEG_SELECTOR, KPRINTF_OFFSET, 0ECh, 0

	SEG_NUM equ ($ - $$) / 8
	times (128 - SEG_NUM) dd 0
	times (128 - SEG_NUM) dd 0

	GDT_SIZE equ $-GDT_BASE

	gdt_size dw GDT_SIZE
	gdt_base dd GDT_BASE

	CODE_SEG_SELECTOR equ 0008h
	DATA_SEG_SELECTOR equ 0010h
	STACK_SEG_SELECTOR equ 0018h
	SYS_CALL_SELECTOR equ 0020h

	VIDEO_START equ 0B8000h
	STACK_TOP equ 060000h

	kernel_msg db 'K', 07h, 'e', 07h, 'r', 07h, 'n', 07h, 'e', 07h, 'l', 07h
	KERNEL_MSG_LEN equ $-kernel_msg

	call_msg db 'C', 07h, 'a', 07h, 'l', 07h, 'l', 07h, ' ', 07h, 'G', 07h, 'a', 07h, 't', 07h, 'e', 07h
	CALL_MSG_LEN equ $-call_msg

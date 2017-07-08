	[bits 32]

	CODE_SEC_VSTART equ 040000h
	DATA_SEC_VSTART equ 050000h

	SECTION code ALIGN=32 VSTART=CODE_SEC_VSTART

	kernel_length dd kernel_end
	entry dd start
	      dw CODE_SEG_SELECTOR
start:
	; adjust kernel
	cld
	mov esi, CODE_SEC_VSTART + section.data.start
	mov edi, DATA_SEC_VSTART
	mov ecx, section.trail.start
	sub ecx, section.data.start
	inc ecx
	rep movsb

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

	hlt

	%macro Descriptor 3
	dw %2 & 0FFFFh
	dw %1 & 0FFFFh
	db (%1 >> 16) & 0FFh
	dw (%3 & 0F0FFh) | ((%2 >> 8) & 0F00h)
	db (%1 >> 24) & 0FFh
	%endmacro

	SECTION data ALIGN=1 VSTART=DATA_SEC_VSTART

GDT_BASE:
	Descriptor 00000000h, 000000h, 00000h
	Descriptor 00000000h, 0FFFFFh, 0C098h
	Descriptor 00000000h, 0FFFFFh, 0C092h
	Descriptor 00000000h, 0FFFFFh, 0C092h
	SEG_NUM equ ($ - $$) / 8
	times (128 - SEG_NUM) dd 0
	times (128 - SEG_NUM) dd 0

	GDT_SIZE equ $-GDT_BASE

	gdt_size dw GDT_SIZE
	gdt_base dd GDT_BASE

	CODE_SEG_SELECTOR equ 0008h
	DATA_SEG_SELECTOR equ 0010h
	STACK_SEG_SELECTOR equ 0018h

	VIDEO_START equ 0B8000h
	STACK_TOP equ 060000h

	kernel_msg db 'i', 07h, 'n', 07h, ' ', 07h, 'K', 07h, 'e', 07h, 'r', 07h, 'n', 07h, 'e', 07h, 'l', 07h
	KERNEL_MSG_LEN equ $-kernel_msg

	SECTION trail ALIGN=1
kernel_end:

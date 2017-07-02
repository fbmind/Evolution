	[bits 32]
	SECTION code ALIGN=32 VSTART=040000h

	kernel_length dd kernel_end
	entry dd start
	      dw CODE_SEG_SELECTOR
start:
	; 显示 'PM OK'
	mov esi, kernel_msg
	mov edi, VIDEO_START+320
	mov ecx, KERNEL_MSG_LEN
	rep movsb
	hlt

	KERNEL_CODE_LENGTH equ $-$$

	SECTION data VSTART=(040000h+KERNEL_CODE_LENGTH)

	kernel_msg db 'K', 07h, 'e', 07h, 'r', 07h, 'n', 07h, 'e', 07h, 'l', 07h
	KERNEL_MSG_LEN equ $-kernel_msg

	KERNEL_DATA_LENGTH equ $-$$

	SECTION trail
kernel_end:

	VIDEO_START equ 0B8000h

	CODE_SEG_SELECTOR equ 0008h
	DATA_SEG_SELECTOR equ 0010h
	STACK_SEG_SELECTOR equ 0018h

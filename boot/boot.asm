	SECTION CODE ALIGN=16 VSTART=07C00h

	[bits 16]
	; Base Limit Attr
	%macro Descriptor 3
	dw %2 & 0FFFFh
	dw %1 & 0FFFFh
	db (%1 >> 16) & 0FFh
	dw (%3 & 0F0FFh) | ((%2 >> 8) & 0F00h)
	db (%1 >> 24) & 0FFh
	%endmacro

	mov ax, cs
	mov ds, ax
	mov ss, ax
	mov sp, 07C00h

	mov ax, VIDEO_SEG
	mov es, ax

	; 清屏
	cld
	mov ax, 00720h
	mov edi, 0
	mov ecx, 1920
	rep stosw

	; 显示 'boot'
	mov esi, boot_msg
	mov edi, 0
	mov ecx, BOOT_MSG_LEN
	rep movsb

	; div r/m16; dx:ax / r/m16 => ax ... dx
	; ax:dx => ds:bx 为 GDT 的逻辑地址
	mov ax, [cs:gdt_base]
	mov dx, [cs:gdt_base+02h]
	mov bx, 16
	div bx
	mov ds, ax
	mov bx, dx

	lgdt [cs:gdt_size]

	; 开启 A20 地址线
	in al, 092h
	or al, 0000_0010B
	out 092h, al

	cli

	; 保护模式开关
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	jmp CODE_SEG_SELECTOR:dword flush

	[bits 32]
flush:
	mov cx, DATA_SEG_SELECTOR
	mov es, cx
	mov ds, cx

	; 显示 'PM OK'
	mov esi, pm_msg
	mov ecx, PM_MSG_LEN
	rep movsb

	hlt

VIDEO_SEG equ 0B800h

boot_msg db 'b', 07h, 'o', 07h, 'o', 07h, 't', 07h, ' ', 07h
BOOT_MSG_LEN equ $ - boot_msg

pm_msg db 'P', 07h, 'M', 07h, ' ', 07h, 'O', 07h, 'K', 07h, ' ', 07h
PM_MSG_LEN equ $ - pm_msg

GDT_BASE:
	Descriptor 00000000h, 000000h, 00000h
	Descriptor 00000000h, 0FFFFFh, 01098h
	Descriptor 00000000h, 0FFFFFh, 01092h
GDT_SIZE equ $ - GDT_BASE

gdt_size dw GDT_SIZE
gdt_base dd GDT_BASE

CODE_SEG_SELECTOR equ 0008h
DATA_SEG_SELECTOR equ 0010h

times 510-($-$$) db 0
db 0x55, 0xaa

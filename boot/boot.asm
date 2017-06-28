	mov ax, cs
	mov ds, ax
	mov ss, ax
	mov sp, 07c00h

	mov ax, VIDEO_SEG
	mov es, ax

	; 清屏
	cld
	mov ax, 00720h
	mov edi, 0
	mov ecx, 1920
	rep stosw

	; 显示 'boot'
	mov esi, boot_msg+07c00h
	mov edi, 0
	mov ecx, BOOT_MSG_LEN
	rep movsb

	hlt

	; div r/m16; dx:ax / r/m16 => ax ... dx
	; ax:dx => ds:bx 为 GDT 的逻辑地址
	mov ax, [cs:gdt_base+07c00h]
	mov dx, [cs:gdt_base+07c00h+02h]
	mov bx, 16
	div bx
	mov ds, ax
	mov bx, dx

	; 哑描述符
	mov dword [bx+00h], 00h
	mov dword [bx+04h], 00h

	mov dword [bx+08h], 07c0001ffh    
	mov dword [bx+0ch], 000409800h

	mov dword [bx+010h], 08000ffffh     
	mov dword [bx+014h], 00040920bh     

	mov dword [bx+018h], 000007a00h
	mov dword [bx+01ch], 000409600h

	mov word [cs: gdt_size+07c00h], 31
	lgdt [cs: gdt_size+07c00h]

	; 开启 A20 地址线
	in al, 092h
	or al, 0000_0010B
	out 092h, al

	cli

	; 保护模式开关
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	jmp dword 0x0008:flush

	[bits 32]
flush:
	mov cx, 00000000000_10_000B
	mov ds, cx
	mov byte [0x00], 'P'
	mov byte [0x02], 'r'
	mov byte [0x04], 'o'
	mov byte [0x06], 't'
	mov byte [0x08], 'e'
	mov byte [0x0a], 'c'
	mov byte [0x0c], 't'
	mov byte [0x0e], ' '
	mov byte [0x10], 'm'
	mov byte [0x12], 'o'
	mov byte [0x14], 'd'
	mov byte [0x16], 'e'
	mov byte [0x18], ' '
	mov byte [0x1a], 'O'
	mov byte [0x1c], 'K'
	mov cx, 00000000000_11_000B
	mov ss, cx
	mov esp, 0x7c00
	mov ebp, esp
	push byte '.'
	sub ebp, 4
	cmp ebp, esp
	jnz ghalt
	pop eax
	mov [0x1e], al
ghalt:
	hlt

VIDEO_SEG equ 0b800h

boot_msg db 'b', 07h, 'o', 07h, 'o', 07h, 't', 07h
BOOT_MSG_LEN equ $ - boot_msg

protect_mode_msg db 'protect mode', 10
PROTECT_MODE_MSG_LEN equ $ - protect_mode_msg

gdt_size dw 0
gdt_base dd 0x00007e00

times 510-($-$$) db 0
db 0x55,0xaa

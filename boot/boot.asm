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
	mov eax, STACK_SEG_SELECTOR
	mov ss, eax
	mov esp, STACK_TOP

	mov eax, DATA_SEG_SELECTOR
	mov ds, eax
	mov es, eax

	; 显示 'PM OK'
	mov esi, pm_msg
	mov edi, VIDEO_START+160
	mov ecx, PM_MSG_LEN
	rep movsb

	; 读取内核信息，位于软盘的第二个扇区，扇区号为 1
	mov eax, KERNEL_INFO_START
	mov ebx, KERNEL_BASE
	call read_hard_disk_0

	mov edi, KERNEL_BASE
	mov ecx, [edi] ; 内核所占扇区数

	; 读内核
	mov eax, KERNEL_SECTOR_START
	mov ebx, KERNEL_BASE
rdkernel:
	call read_hard_disk_0
	inc eax
	loop rdkernel

setup:
	; 程序头的数量
	mov cx, [KERNEL_BASE + 02Ch]
	movzx ecx, cx

	; 程序头的位置
	mov ebx, [KERNEL_BASE + 01Ch]
	add ebx, KERNEL_BASE

.Begin:
	mov eax, [ebx]
	cmp eax, 0
	jz .NoAction

	push ecx

	; 拷贝一个程序段
	mov esi, [ebx + 04h] ; 偏移
	add esi, KERNEL_BASE
	mov edi, [ebx + 08h] ; 虚拟地址
	mov ecx, [ebx + 010h] ; 大小
	rep movsb

	pop ecx

.NoAction:
	add ebx, 020h
	dec ecx
	jnz .Begin

	jmp KERNEL_ENTRY

	hlt

; 读取主硬盘
; eax 起始扇区编号
; 数据写到ds:ebx 中
; ebx = ebx + 512
read_hard_disk_0:
	push eax 
	push ecx
	push edx

	push eax

	; 读取一个扇区
	mov dx, 01F2h
	mov al, 1
	out dx, al

	pop eax

	; 起始扇区编号，LBA，主硬盘
	inc dx
	out dx, al

	inc dx
	mov cl, 8
	shr eax, cl
	out dx, al

	inc dx
	shr eax, cl
	out dx, al

	inc dx
	shr eax, cl
	or al, 0E0h
	out dx, al

	; 读硬盘
	inc dx
	mov al, 020h
	out dx, al

.waits:
	in al, dx
	and al, 088h
	cmp al, 008h
	jnz .waits

	; 读取数据到 ds:ebx 中
	mov ecx, 256
	mov dx, 01F0h
.readw:
	in ax, dx
	mov [ebx], ax
	add ebx, 2
	loop .readw

	pop edx
	pop ecx
	pop eax 

	ret

	boot_msg db 'B', 07h, 'o', 07h, 'o', 07h, 't', 07h
	BOOT_MSG_LEN equ $-boot_msg

	pm_msg db 'P', 07h, 'r', 07h, 'o', 07h, 't', 07h, 'e', 07h
	       db 'c', 07h, 't', 07h, ' ', 07h, 'm', 07h, 'o', 07h
	       db 'd', 07h, 'e', 07h
	PM_MSG_LEN equ $-pm_msg

GDT_BASE:
	Descriptor 00000000h, 000000h, 00000h
	Descriptor 00000000h, 0FFFFFh, 0C098h
	Descriptor 00000000h, 0FFFFFh, 0C092h
	Descriptor 00000000h, 0FFFFFh, 0C092h

	GDT_SIZE equ $-GDT_BASE

	gdt_size dw GDT_SIZE
	gdt_base dd GDT_BASE

	CODE_SEG_SELECTOR equ 0008h
	DATA_SEG_SELECTOR equ 0010h
	STACK_SEG_SELECTOR equ 0018h

	VIDEO_SEG equ 0B800h
	VIDEO_START equ 0B8000h
	STACK_TOP equ 07C00h

	KERNEL_INFO_START equ 1
	KERNEL_SECTOR_START equ 2
	KERNEL_BASE equ 010000h
	KERNEL_ENTRY equ 030400h

	times 510-($-$$) db 0
	db 0x55, 0xaa

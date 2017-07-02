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

	; 读取内核 
	; 内核第一个扇区，含有内核的信息，从该扇区提取信息后，继续读其他的扇区
	mov eax, KERNEL_SECTOR_START
	mov ebx, KERNEL_BASE
	call read_hard_disk_0

	mov edi, KERNEL_BASE
	mov eax, [edi] ; 内核长度
	xor edx, edx
	mov ecx, 512
	div ecx
	or edx, edx
	jnz @1
	; eax 里面存的是整扇区数，edx 是不够一扇区的字节数
	; 若 edx 为 0，说明内核总共占 eax 个扇区，否则为 eax + 1 个扇区
	; 因为已经读取了 1 个扇区，若 edx 为 0，则仍需读 eax - 1 个扇区，否则再读 eax 个扇区
	dec eax

@1:
	; eax 为 0，内核只有一个扇区
	or eax,eax
	jz setup

	; 继续读内核
	mov ecx, eax
	mov eax, KERNEL_SECTOR_START
	inc eax
@2:
	call read_hard_disk_0
	inc eax
	loop @2 

setup:
	jmp far [edi+04h]

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

	KERNEL_SECTOR_START equ 1
	KERNEL_BASE equ 040000h

	times 510-($-$$) db 0
	db 0x55, 0xaa

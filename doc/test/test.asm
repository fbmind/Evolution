	[bits 16]
	mov ax, 8
	mov eax, 8
	jmp 00h:dword flush
	jmp 00h:flush

flush:
	mov ax, 8

	[bits 32]
	mov ax, 8
	mov eax, 8
	jmp 00h:dword flush
	jmp 00h:flush

flush2:
	mov ax, 8

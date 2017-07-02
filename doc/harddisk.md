# 读取硬盘

## 主硬盘控制器分配的端口号

01f0h ~ 01f7h 共 7 个端口

01F1h 端口是错误寄存器。

## 读逻辑扇区

###  设置要读取的扇区数量

```
mov dx, 01F2h
mov al, 01h
out dx, al
```

### 设置起始 LBA 扇区号

```
mov dx, 01F3h
mov al, 01h
out dx, al

mov dx, 01F4h
mov al, 00h
out dx, al

mov dx, 01F5h
mov al, 00h
out dx, al

mov dx, 01F6h
mov al, 0E0h
out dx, al
```

> 28 位扇区号分成 4 段，分别写入 01F3 01F4 01F5 01F6 端口。01F6 端口的低 4 位用于存放端口号，低 4 位用于指示硬盘号，0 表示主盘，1 表示从盘。第 6 位为 1 表示 LBA 模式。

### 向端口 01F7h 写入 020h 表示读硬盘。

```
mov dx, 01F7h
mov al, 020h
out dx, al
```

### 等待读写操作完成

```
	mov dx, 01F7h
.wait:
	in al, dx
	and al, 088h
	cmp al, 08h
	jnz .wait
```

> 080h 表示正在读取中，08h 表示读取完毕。

### 读取数据

```
	mov cx, 256
	mov dx, 01F0h
.readw:
	in ax, dx
	mov [bx], ax
	inc bx
	inc bx
	loop .readw
```

> 01F0h 端口是 16 位端口。

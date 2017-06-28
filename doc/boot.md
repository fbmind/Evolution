# boot.asm 详解

## 寄存器的初始值

```
mov ax, cs
mov ss, ax
mov sp, 07c00h
```

> 引导程序开始执行前的一句为 jmp 0000:7c00，cs 为 0000h，ip 为 7c00h。
> 将栈的段地址也设为 0000h，栈顶设为引导扇区加载的位置以下。

## 内存分布

1. 0000 ~ 07c00 栈
2. 07c00 ~ 07e00 引导扇区
3. 07e00 ~ GDT

> GDT 没有在引导扇区内部

## 获取 GDT 的逻辑地址

```
gdt_base dd 011223344h
mov ax, [cs:gdt_base+07c00h]
mov dx, [cs:gdt_base+07c00h+02h]
```

L ............... H
044h 033h 022h 011h

ax = 03344h
dx = 01122h
dx:ax = 011223344h

div r/m16; dx:ax / r/m16 => ax ... dx

进行触发操作后 ax:dx 为 GDT 的逻辑地址，该逻辑地址的段地址不是 0000h。

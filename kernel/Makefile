all: kernel.bin

kernel.bin: kernel.asm start.c table.c main.c prot.c idt.c \
	libc/string.c \
	libc/stdio.c \
	global.h \
	include/evolution/type.h \
	include/evolution/const.h \
	include/evolution/proc.h \
	include/evolution/prot.h \
	include/string.h \
	include/stdio.h
	nasm -f elf32 -o kernel.o -l kernel.lst kernel.asm
	gcc -c table.c -o table.o -I. -I./include/
	gcc -c start.c -o start.o -I. -I./include/
	gcc -c main.c -o main.o -I. -I./include/
	gcc -c prot.c -o prot.o -I. -I./include/
	gcc -fno-stack-protector -c idt.c -o idt.o -I. -I./include/
	gcc -c libc/stdio.c -o libc/stdio.o -I. -I./include/
	gcc -fno-stack-protector -c libc/string.c -o libc/string.o -I. -I./include/
	ld -s -Ttext 0xC0000400 -o kernel.bin kernel.o table.o start.o main.o prot.o idt.o \
	libc/string.o \
	libc/stdio.o

.PHONY: install clean

install:
	/bin/echo -e -n "\x"`du -b kernel.bin | cut -f 1 | xargs -I {} expr {} / 512 + 1` > .ksize
	/bin/echo -e -n "\x0\x0\x0" >> .ksize
	dd if=.ksize of=../c.img bs=512 seek=1 count=1 conv=notrunc
	dd if=kernel.bin of=../c.img bs=512 seek=2 count=`du -b kernel.bin | cut -f 1 | xargs -I {} expr {} / 512 + 1` conv=notrunc

clean:
	rm -rf kernel.bin kernel.lst .ksize *.o libc/*.o

all: kernel.bin

kernel.bin: kernel.asm
	nasm -f elf32 -o kernel.o -l kernel.lst kernel.asm
	ld -s -Ttext 0x30400 -o kernel.bin kernel.o

.PHONY: install clean

install:
	/bin/echo -e -n "\x"`du -b kernel.bin | cut -f 1 | xargs -I {} expr {} / 512 + 1` > .ksize
	/bin/echo -e -n "\x0\x0\x0" >> .ksize
	dd if=.ksize of=../c.img bs=512 seek=1 count=1 conv=notrunc
	dd if=kernel.bin of=../c.img bs=512 seek=2 count=`du -b kernel.bin | cut -f 1 | xargs -I {} expr {} / 512 + 1` conv=notrunc

clean:
	rm -rf kernel.bin kernel.o kernel.lst .ksize

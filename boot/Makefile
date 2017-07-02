boot.bin: boot.asm
	nasm boot.asm -o boot.bin -l boot.lst

.PHONY: install clean

install:
	dd if=boot.bin of=../c.img bs=512 count=1 conv=notrunc

clean:
	rm -rf boot.bin boot.lst

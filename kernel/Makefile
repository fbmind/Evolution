kernel.bin: kernel.asm
	nasm kernel.asm -o kernel.bin -l kernel.lst

.PHONY: install clean

install:
	dd if=kernel.bin of=../c.img bs=512 seek=1 count=10 conv=notrunc

clean:
	rm -rf kernel.bin kernel.lst

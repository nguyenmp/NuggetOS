NAME=myfirst
SOURCE=$(NAME).asm
BINARY=$(NAME).bin
FLOPPY=$(NAME).flp

default: floppy

binary: $(SOURCE)
	nasm -f bin -o $(BINARY) $(SOURCE)

floppy: binary
	dd status=noxfer conv=notrunc if=$(BINARY) of=$(FLOPPY)

run: floppy
	qemu-system-x86_64 -fda $(FLOPPY)

clean:
	rm -f $(BINARY) $(FLOPPY)

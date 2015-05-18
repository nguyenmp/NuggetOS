NAME=myfirst
SOURCE=$(NAME).asm
BINARY=$(NAME).bin
FLOPPY=$(NAME).flp
RMFILES=$(BINARY) $(FLOPPY)

default: $(FLOPPY)

$(BINARY): $(SOURCE)
	nasm -f bin -o $(BINARY) $(SOURCE)

$(FLOPPY): $(BINARY)
	dd status=noxfer conv=notrunc if=$(BINARY) of=$(FLOPPY)

run: $(FLOPPY)
	qemu-system-x86_64 -fda $(FLOPPY)

clean:
	rm -f $(RMFILES)

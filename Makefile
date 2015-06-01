NAME=myfirst
SOURCE=$(NAME).asm
BINARY=$(NAME).bin
FLOPPY=$(NAME).flp
RMFILES=$(BINARY) $(FLOPPY) test.o test.bin

default: $(FLOPPY)

$(BINARY): $(SOURCE)
	nasm -f bin -o $(BINARY) $(SOURCE)

test.o: test.c
	cc -c test.c

test.bin: test.o
	objcopy -O binary test.o test.bin

$(FLOPPY): $(BINARY) test.bin
	dd conv=notrunc if=$(BINARY) of=$(FLOPPY)
	dd conv=notrunc obs=512 seek=1 if=$(BINARY) of=$(FLOPPY)

run: $(FLOPPY)
	qemu-system-x86_64 -fda $(FLOPPY)

clean:
	rm -f $(RMFILES)
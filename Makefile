AS = nasm
LD = ld
RM = rm -f

ASFLAGS	= -f elf
BOOTFLAGS = -f bin
LDFLAGS	= -melf_i386 -Ttext 0x010000 --oformat binary

OBJS = main.o string.o memory.o pic.o idt.o interrupts.o kbd.o console.o scr.o


kernel: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o kernel



main.o main.asm:
	$(AS) $(ASFLAGS) main.asm
string.o: string.asm
	$(AS) $(ASFLAGS) string.asm
memory.o: memory.asm
	$(AS) $(ASFLAGS) memory.asm
pic.o	:	pic.asm
	$(AS) $(ASFLAGS) pic.asm
idt.o :	idt.asm
	$(AS) $(ASFLAGS) idt.asm
interrupts.o :	interrupts.asm
	$(AS) $(ASFLAGS) interrupts.asm
kbd.o :	kbd.asm
	$(AS) $(ASFLAGS) kbd.asm
console.o :	console.asm
	$(AS) $(ASFLAGS) console.asm
scr.o :	scr.asm
	$(AS) $(ASFLAGS) scr.asm

clean:
	$(RM) *.o kernel boot img image.img bochsout.txt
fd:
	$(AS) $(BOOTFLAGS) boot.asm
	cat boot >img
	cat kernel >> img
	dd if=img of=/dev/fd0
vp: kernel
	$(AS) $(BOOTFLAGS) boot.asm
	cat boot >img
	cat kernel >>img
	dd if=/dev/zero bs=1k count=1440 of=image.img
	cat img > image.img
	
fdimage: kernel
	$(AS) $(BOOTFLAGS) boot.asm
	cat boot > image.img
	cat kernel >> image.img
	./rest.sh
	
run: fdimage
	bochs -f bochsrc -q

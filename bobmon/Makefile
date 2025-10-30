.PHONY: all clean disks

LWAR=lwar
LWASM=lwasm
LWLINK=lwlink
CONV=conv

LWASMFLAGS=--pragma=cescapes

SOURCES=\
	args.asm \
	bobmon.asm \
	boot_cmd.asm \
	cf_io.asm \
	commands.asm \
	cpu_cmd.asm \
	devices.asm \
	disasm.asm \
	disk_cmd.asm \
	dump_cmd.asm \
	fat16.asm \
	go_cmd.asm \
	help_cmd.asm \
	load_cmd.asm \
	mc6850.asm \
	radix_cmds.asm \
	register_cmd.asm \
	stdio.asm \
	string_functions.asm \
	syscalls.asm \
	system_vectors.asm \
	unassemble_cmd.asm \
	window_cmd.asm \
	zob_cmd.asm

OBJECTS_809 = $(SOURCES:.asm=.809_o)
OBJECTS_309 = $(SOURCES:.asm=.309_o)

%.309_o: %.asm devices.s constants.s
	$(LWASM) $(LWASMFLAGS) --6309 -fobj -DHD6309 --output=$@ $<

%.809_o: %.asm devices.s constants.s
	$(LWASM) $(LWASMFLAGS) --6809 -fobj -DMC6809 --output=$@ $<

%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

all: bobmon809.decb bobmon309.decb

bobmon809.decb: $(OBJECTS_809)
	$(LWLINK) --decb --script=bobmon.lnk --output=$@ --map=bobmon809.map --library-path=../libX09 --library=809 $(OBJECTS_809)
	$(CONV) -i bobmon809.decb -f dragon -o bobmon809.hex -t ihex -r 0 --start-address=0xc000 --end-address=0xffff

bobmon309.decb: $(OBJECTS_309)
	$(LWLINK) --decb --script=bobmon.lnk --output=$@ --map=bobmon309.map --library-path=../libX09 --library=309 $(OBJECTS_309)
	$(CONV) -i bobmon309.decb -f dragon -o bobmon309.hex -t ihex -r 0 --start-address=0xc000 --end-address=0xffff

disks:
	rm -f disk1.img disk2.img
	mkfs.msdos -C -n System ./disk1.img 64000
	mkfs.msdos -C -n Utils ./disk2.img 256000
	
clean:
	rm -f *.hex *.809_o *.309_o *.lst *.lst8 *.lst3 *~
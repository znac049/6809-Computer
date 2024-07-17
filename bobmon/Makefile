.PHONY: all clean disks

LWAR=lwar
LWASM=lwasm
LWLINK=lwlink

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
	window_cmd.asm

OLD= \
				bobmon.asm \
				cf_io.s \
				commands/boot_cmd.s \
				commands/commands.s \
				commands/cpu_cmd.s \
				commands/disk_cmds.s \
				commands/go_cmd.s \
				commands/load_cmd.s \
				commands/dump_cmd.s \
				commands/help_cmd.s \
				commands/radix_cmds.s \
				commands/register_cmd.s \
				commands/unassemble.s \
				commands/window_cmd.s \
				constants.s \
				devices/devices.s \
				devices/character/mc6850.s \
				devices/block/LSN.s \
				fs/fat16.s \
				macros.s \
				stdio.s \
				string_functions.s \
				sysdefs.s \
				syscalls.s \
				system_vectors.s \
				variables.s

OBJECTS_809 = $(SOURCES:.asm=.809_o)
OBJECTS_309 = $(SOURCES:.asm=.309_o)

%.309_o: %.asm devices.s constants.s
	$(LWASM) $(LWASMFLAGS) --6309 -fobj -DHD6309 --output=$@ $<

%.809_o: %.asm devices.s constants.s
	$(LWASM) $(LWASMFLAGS) --6809 -fobj -DMC6809 --output=$@ $<

%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

all: bobmon809.hex bobmon309.hex
	echo $(OBJECTS_309)
	echo $(OBJECTS_809)

bobmon809.hex: $(OBJECTS_809)

bobmon309.hex: $(OBJECTS_309)

disks:
	rm -f disk1.img disk2.img
	mkfs.msdos -C -n System ./disk1.img 64000
	mkfs.msdos -C -n Utils ./disk2.img 256000
	
clean:
	rm -f *.hex *.809_o *.309_o *.lst *~
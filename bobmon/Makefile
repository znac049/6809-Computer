.PHONY: all clean disks

SOURCES=bobmon.asm \
				3rdParty/lance.s \
				args.s \
				cf_io.s \
				commands/boot_cmd.s \
				commands/commands.s \
				commands/disassemble.s \
				commands/go_cmd.s \
				commands/load_cmd.s \
				commands/dump_cmd.s \
				commands/help_cmd.s \
				commands/radix_cmds.s \
				commands/register_cmd.s \
				commands/window_cmd.s \
				constants.s \
				devices/devices.s \
				devices/character/mc6850.s \
				devices/block/virt_disk.s \
				disasm.s \
				disk_io.s \
				fs/fat16.s \
				fs/fs.s \
				macros.s \
				quad.s \
				radix.s \
				sd_io.s \
				stdio.s \
				string_functions.s \
				sysdefs.s \
				syscalls.s \
				system_vectors.s \
				variables.s


%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

all: bobmon.hex

bobmon.hex: $(SOURCES)

disks:
	rm -f disk1.img disk2.img
	mkfs.msdos -C -n System ./disk1.img 64000
	mkfs.msdos -C -n Utils ./disk2.img 256000
	
clean:
	rm *.hex *.lst *~
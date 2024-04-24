.PHONY: all clean

SOURCES=bobmon.asm \
				args.s \
				boot_cmd.s \
				cf_io.s \
				commands/commands.s \
				commands/go_cmd.s \
				commands/load_cmd.s \
				constants.s \
				devices/devices.s \
				devices/mc6850.s \
				disasm.s \
				disassemble.s \
				disk_io.s \
				dump_cmd.s \
				help_cmd.s \
				macros.s \
				quad.s \
				register_cmd.s \
				sd_io.s \
				stdio.s \
				string_functions.s \
				sysdefs.s \
				syscalls.s \
				system_vectors.s \
				variables.s \
				window_cmd.s


%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

all: bobmon.hex

bobmon.hex: $(SOURCES)

clean:
	rm *.hex *.lst *~
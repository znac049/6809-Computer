.PHONY: all clean

SOURCES=bobmon.asm \
				args.s \
				basic_cmd.s \
				commands.s \
				constants.s \
				disk_io.s \
				dump_cmd.s \
				forth_cmd.s \
				go_cmd.s \
				help_cmd.s \
				io_functions.s \
				register_cmd.s \
				serial_io.s \
				string_functions.s \
				sysdefs.s \
				system_vectors.s \
				variables.s \
				window_cmd.s


%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

all: bobmon.hex

bobmon.hex: $(SOURCES)

clean:
	rm *.hex *.lst
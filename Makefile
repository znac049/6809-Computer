.PHONY: all

all: assist09.hex bobmon.hex

assist09.hex: assist09.asm
	asm6809 --hex --6809 --listing=assist09.lst --output=assist09.hex assist09.asm

bobmon.hex: bobmon.asm disk_io.s io_functions.s string_functions.s system_vectors.s
	asm6809 --hex --6809 --listing=bobmon.lst --output=bobmon.hex bobmon.asm

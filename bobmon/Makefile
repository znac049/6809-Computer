.PHONY: all clean

%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

all: bobmon.hex

bobmon.hex: disk_io.s io_functions.s string_functions.s system_vectors.s

clean:
	rm *.hex *.lst
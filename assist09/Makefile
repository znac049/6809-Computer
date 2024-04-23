.PHONY: all clean

%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

all: assist09.hex

clean:
	rm *.hex *.lst
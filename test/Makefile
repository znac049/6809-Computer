.PHONY: all clean

%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

%.hex: %.s
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

%.srec: %.asm
	asm6809 --srec --6809 --listing=$*.lst --output=$@ $<

%.srec: %.s
	asm6809 --srec --6809 --listing=$*.lst --output=$@ $<

all: cftest.srec hello.srec

clean:
	rm -f *.hex *.srec *.lst *~
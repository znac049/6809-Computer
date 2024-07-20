.PHONY: all clean install

LWAR=lwar
LWASM=lwasm

LIB_ASM = \
	binToBin.asm \
	binToBinDigits.asm \
	binToDec.asm \
	binToHex.asm \
	binToHexDigit.asm \
	clearLSN.asm \
	copyLSN.asm \
	getHexByte.asm \
	getHexDigit.asm \
	getHexWord.asm \
	getLChar.asm \
	incLSN.asm \
	padToCol.asm \
	printNum.asm \
	putHexByte.asm \
	putHexDigit.asm \
	putHexWord.asm \
	putLSN.asm \
	putNL.asm \
	putPrintableChar.asm \
	putStr.asm \
	putnStr.asm \
	putnpStr.asm \
	shiftLSNL.asm \
	skipLine.asm \
	strToLower.asm \
	strToLSN.asm \
	strToUpper.asm

LIB809_OBJ = $(LIB_ASM:.asm=.809_o)
LIB309_OBJ = $(LIB_ASM:.asm=.309_o)

all: lib809.a lib309.a

lib809.a: $(LIB809_OBJ)
	$(LWAR) -c $@ $(LIB809_OBJ)

lib309.a: $(LIB309_OBJ)
	$(LWAR) -c $@ $(LIB309_OBJ)

%.309_o: %.asm lib.s
	$(LWASM) $(LWASMFLAGS) --6309 -fobj -DHD6309 --output=$@ $<

#%.void_o: %.asm std.inc ../float/float.inc
%.809_o: %.asm lib.s
	$(LWASM) $(LWASMFLAGS) --6809 -fobj -DMC6809 --output=$@ $<

clean:
	rm -f *~ *.809_o *.309_o *.lst *.a

install: all
	install libcmoc-crt-void.a $(LIBDIR)
	install libcmoc-std-void.a $(LIBDIR)
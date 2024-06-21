.PHONY: all clean install

LWAR=lwar
LWASM=lwasm
CMOC=cmoc

CMOC_LIB_FLAGS = -O2 -DNDEBUG -nostdinc $(INTERMEDIATE) -Werror -Wno-inline-asm-array-indexes

LIBDIR=/home/bob/8bit/share/cmoc/lib

CRT_ASM = \
	crt.asm \
	addDWordDWord.asm \
	addDWordInt.asm \
	addDWordUnsignedInt.asm \
	adddww.asm \
	addIntDWord.asm \
	addUnsignedIntDWord.asm \
	andDWordDWord.asm \
	andDWordWord.asm \
	cmpDWordDWord.asm \
	cmpDWordSignedInt.asm \
	cmpDWordUnsignedInt.asm \
	cmpdww.asm \
	cmpSignedIntDWord.asm \
	cmpUnsignedIntDWord.asm \
	copyDWord.asm \
	copyDWordFromXToD.asm \
	copyMem.asm \
	copyWordToDWord.asm \
	decrementDWord.asm \
	DIV16.asm \
	DIV16BY10.asm \
	DIV32.asm \
	DIV8.asm \
	DIV8BY7.asm \
	DIV8BY3.asm \
	divDBy16.asm \
	divdwb.asm \
	divDWordDWord.asm \
	divDWordUnsignedInt.asm \
	divdww.asm \
	divModDWordDWord.asm \
	divModDWordUnsignedInt.asm \
	divModUnsignedIntDWord.asm \
	divUnsignedIntDWord.asm \
	incrementDWord.asm \
	initByteFromDWord.asm \
	initDWordFromSignedWord.asm \
	initDWordFromUnsignedWord.asm \
	initWordFromDWord.asm \
	isDWordZero.asm \
	jumpTableSwitch.asm \
	leftShiftDWord.asm \
	leftShiftDWordAtXByB.asm \
	modDWordDWord.asm \
	modDWordUnsignedInt.asm \
	modUnsignedIntDWord.asm \
	MUL168_TO24.asm \
	MUL168_TO32.asm \
	MUL16.asm \
	MUL16BY10.asm \
	MUL32.asm \
	mulDWordDWord.asm \
	mulDWordInt.asm \
	mulDWordUnsignedInt.asm \
	mulIntDWord.asm \
	mulUnsignedIntDWord.asm \
	negateDWord.asm \
	orDWordDWord.asm \
	orDWordWord.asm \
	push4ByteStruct.asm \
	push5ByteStruct.asm \
	pushStruct.asm \
	pushSmallStruct.asm \
	resetBBytes.asm \
	resetDBytes.asm \
	rightShiftDWord.asm \
	rightShiftDWordAtXByB.asm \
	SDIV16.asm \
	SDIV8.asm \
	shiftByteLeft.asm \
	shiftByteRightSigned.asm \
	shiftByteRightUnsigned.asm \
	shiftLeft.asm \
	shiftRightSigned.asm \
	shiftRightUnsigned.asm \
	signedDivDWordDWord.asm \
	signExtWordToDWord.asm \
	sub32.asm \
	sub32xu.asm \
	subDWordDWord.asm \
	subDWordInt.asm \
	subDWordUnsignedInt.asm \
	subdww.asm \
	subIntDWord.asm \
	subUnsignedIntDWord.asm \
	testAndRemoveSignOnDWord.asm \
	testAndRemoveSignOnWord.asm \
	tfrZtoB.asm \
	xorDWordDWord.asm \
	xorDWordWord.asm


# So-called "standard" CMOC library, which contains some Standard C functions
# and other useful C functions.
#
STD_ASM = \
	abs.asm \
	atoi.asm \
	atoui.asm \
	ATOW.asm \
	checkGuardVar.asm \
	checknull.asm \
	checkstack.asm \
	delay.asm \
	dwtoa.asm \
	labs.asm \
	LINBUF.asm \
	memcmp.asm \
	memicmp.asm \
	memcmpimpl.asm \
	memcpy.asm \
	memmove.asm \
	memset.asm \
	MUL168.asm \
	printf.asm \
	putchar_a.asm \
	putstr.asm \
	readline.asm \
	readword.asm \
	sbrk.asm \
	sbrkmax.asm \
	seed.asm \
	setConsoleOutHook.asm \
	sprintf.asm \
	vsprintf.asm \
	chrtomem.asm \
	strcat.asm \
	strchr.asm \
	strrchr.asm \
	strstr.asm \
	strcmp.asm \
	stricmp.asm \
	strcmpimpl.asm \
	strcpy.asm \
	strlen.asm \
	strlwr.asm \
	strncpy.asm \
	strtoul.asm \
	strupr.asm \
	tolower.asm \
	toupper.asm \
	zerodw.asm \
	convertABToUpperCase.asm


# Also part of 'std' library:
#
C_COMMON = \
	atol.c \
	atoul.c \
	strtol.c \
	strspn.c \
	strcspn.c \
	strtok.c \
	strpbrk.c \
	utoa.c \
	itoa.c \
	ultoa.c \
	ltoa.c \
	_FinishIntegerToASCII.c \
	stdarg.c \
	setjmp.c \
	sqrt16.c \
	sqrt32.c \
	divmod16.c \
	divmod8.c \
	rand.c \
	initCoCoSupport.c \
	qsort.c \
	bsearch.c \
	strncmp.c \
	memchr.c \
	memichr.c \
	memset16.c \
	isspace.c \
	isdigit.c \
	isalpha.c \
	isalnum.c \
	assert.c

CRT_USIM_OBJ = $(CRT_ASM:.asm=.usim_o)
CRT_VOID_OBJ = $(CRT_ASM:.asm=.void_o)

STD_USIM_OBJ = $(STD_ASM:.asm=.usim_o) $(C_COMMON:.c=.usim_o)
STD_VOID_OBJ = $(STD_ASM:.asm=.void_o)  $(C_COMMON:.c=.void_o)

INTERMEDIATE = --intermediate
CMOC_LIB_FLAGS = -O2 -DNDEBUG -nostdinc -I . $(INTERMEDIATE) -Werror -Wno-inline-asm-array-indexes

all: libcmoc-crt-void.a libcmoc-std-void.a

libcmoc-crt-usim.a: $(CRT_USIM_OBJ)
	$(LWAR) -c $@ $(CRT_USIM_OBJ)
libcmoc-crt-void.a: $(CRT_VOID_OBJ)
	$(LWAR) -c $@ $(CRT_VOID_OBJ)

libcmoc-std-usim.a: $(STD_USIM_OBJ)
	$(LWAR) -c $@ $(STD_USIM_OBJ)
libcmoc-std-void.a: $(STD_VOID_OBJ)
	$(LWAR) -c $@ $(STD_VOID_OBJ)

%.usim_o: %.asm std.inc ../float/float.inc
	$(LWASM) $(LWASMFLAGS) -fobj -DUSIM --output=$@ $<
#%.void_o: %.asm std.inc ../float/float.inc
%.void_o: %.asm std.inc
	$(LWASM) $(LWASMFLAGS) -fobj -D_CMOC_VOID_TARGET_ --list=$*.lst --output=$@ $<

%.usim_o: %.c std.inc ../float/float.inc
	$(CMOC) -c $(CMOC_LIB_FLAGS) --usim -o $@ $<
#%.void_o: %.c std.inc ../float/float.inc
%.void_o: %.c std.inc
	$(CMOC) -c $(CMOC_LIB_FLAGS) --void-target -o $@ $<

clean:
	rm -f *~ *.usim_o *.void_o *.a

install: all
	install libcmoc-crt-void.a $(LIBDIR)
	install libcmoc-std-void.a $(LIBDIR)
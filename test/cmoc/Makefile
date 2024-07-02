.PHONY: all clean

#CMOCTARGET=coco
#CMOCTARGET=vectrex
CMOCTARGET=void-target
#CMOCTARGET=usim

BLIBOBJ=putChar.o

CMOCARGS=--$(CMOCTARGET) -i

%.o: %.c
	cmoc --compile -o $@ $(CMOCARGS) $< 

%.o: %.s
	lwasm --6809 --obj --list=$*.lst --output=$@ $<

all: blib.a hello

blib.a: $(BLIBOBJ)
	lwar -a blib.a $(BLIBOBJ)

hello: hello.o
	cmoc -L . --$(CMOCTARGET) -o hello.srec --srec --org=4000 -i hello.o blib.a
	cmoc -L . --$(CMOCTARGET) -o hello.bin --raw --org=4000 -i hello.o blib.a
	flip -u hello.srec

clean:
	rm -f *.hex *.srec *.lst *.a *.o *~
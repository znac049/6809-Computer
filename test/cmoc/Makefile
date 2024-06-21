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
	cmoc -i -L . --$(CMOCTARGET) -o hello.srec --srec --org=4000 --data=0100 hello.o blib.a

clean:
	rm -f *.hex *.srec *.lst *.a *.o *~
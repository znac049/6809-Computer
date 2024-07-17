.PHONY: all clean

%.hex: %.asm
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

%.hex: %.s
	asm6809 --hex --6809 --listing=$*.lst --output=$@ $<

%.srec: %.asm
	asm6809 --srec --6809 --listing=$*.lst --output=$@ $<

%.srec: %.s
	asm6809 --srec --6809 --listing=$*.lst --output=$@ $<

%.decb: %.asm
	asm6809 --coco --6809 --listing=$*.lst --output=$@ $<

%.decb: %.s
	asm6809 --coco --6809 --listing=$*.lst --output=$@ $<

all: cftest.srec hello.decb

testdisk: disk1.img
	sudo mount -o loop ./disk1.img /mnt
	sudo cp hello.decb /mnt/hello.bin
	sudo cp hello.asm /mnt
	sudo umount /mnt

disk1.img: hello.decb
	truncate disk1.img -s 32M
	mkfs.fat -S512 -s1 -n TestDisk disk1.img

clean:
	rm -f *.hex *.srec *.decb *.lst *~
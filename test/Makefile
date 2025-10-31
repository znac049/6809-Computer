.PHONY: all clean disks install mount unmount

MOUNTPOINT=/home/bob/src/6809-Computer/test
CF1=$(MOUNTPOINT)/cf1
CF2=$(MOUNTPOINT)/cf2

OBJS=hello.hex \
		cftest.hex

%.hex: %.bin
	conv -i $< -o $@ -f dragon -t ihex --verbose

%.bin: %.asm
	asm6809 --coco --6809 --listing=$*.lst --output=$@ $<

%.bin: %.s
	asm6809 --coco --6809 --listing=$*.lst --output=$@ $<

all: cftest.bin hello.bin

disks: cf_1.img cf_2.img

cf_1.img:
	truncate cf_1.img -s 32M
	mkfs.fat -S512 -s1 -n CF1 cf_1.img

cf_2.img:
	truncate cf_2.img -s 64M
	mkfs.fat -S1024 -s1 -n CF2 cf_2.img

install: disks $(OBJS)
	mkdir -p $(CF1)
	sudo mount -o loop ./cf_1.img $(CF1)
	sudo cp hello.bin $(CF1)/
	sudo cp cftest.bin $(CF1)/
	sudo cp *.asm $(CF1)/
	sudo umount $(CF1)

mount:
	sudo mount -o loop ./cf_1.img $(CF1)

unmount:
	sudo umount $(CF1)

clean:
	rm -f *.hex *.srec *.decb *.bin *.lst *.img *~
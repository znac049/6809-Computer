#include <cstdlib>
#include <cstdio>
#include <csignal>
#include <unistd.h>

#include "diskinfo.h"
#include "fatdisk.h"

#define BLOCK_SIZE 512

typedef unsigned char byte;

FILE *disk;
byte block[BLOCK_SIZE];


/*
void dump(byte *buffer)
{
    for (int i=0; i<BLOCK_SIZE; i+= 16) {
        printf("%04x: ", i);
        for (int j=0; j<16; j++) {
            printf("%02x ", buffer[i+j]);
        }

        for (int j=0; j<16; j++) {
            byte c = buffer[i+j];
            
            if ((c < ' ') || (c > '_'))
                c = '.';

            putchar(c);
        }
        printf("\n");
    }
}

void getBlock(long blockNum, byte *buffer)
{
    if (fseek(disk, blockNum*BLOCK_SIZE, SEEK_SET)) {
        printf("Failed to seek to record %ld\n", blockNum);
        exit(EXIT_FAILURE);
    }

    if (fread(buffer, sizeof(byte), BLOCK_SIZE, disk) != BLOCK_SIZE) {
        printf("Failed to read %d bytes\n", BLOCK_SIZE);
        exit(EXIT_FAILURE);
    }

}

void checkBootBlock()
{
    getBlock(0, block);
    dump(block);

    printf("  bytes per sector: %d\n", getWord(block, 0x0b));
    printf("  sectors per cluster: %d\n", getByte(block, 0x0d));
    printf("  reserved sectors: %d\n", getWord(block, 0x0e));
    printf("  number of FATs: %d\n", getByte(block, 0x10));
    printf("  max number of root entries: %d\n", getWord(block, 0x11));

    printf("  small number of sectors: %d\n", getWord(block, 0x13));
    printf("  large number of sectors: %d\n", getLong(block, 0x20));

    printf("    media descriptor: %d\n", getByte(block, 0x15));
    printf("    sectors per fat: %d\n", getWord(block, 0x16));
    printf("    sectors per track: %d\n", getWord(block, 0x18));
    printf("    number of heads: %d\n", getWord(block, 0x1a));
    printf("    hidden sectors: %d\n", getLong(block, 0x1c));

    printf("  volume serial number: %08x\n", getLong(block, 0x27));
    printf("  file system type: ");
    for (int i=0; i<8; i++) {
        putchar(block[0x36+i]);
    }
    putchar('\n');

    printf("  boot sector signature: %04x\n", getWord(block, 0x1fe));
}
*/

int main(int argc, char *argv[])
{
    fatdisk disk;
	long blocks;

	if (argc != 2) {
		fprintf(stderr, "usage: diskinfo <disk image file>\n");
		return EXIT_FAILURE;
	}

    disk.openDisk(argv[1]);

	return EXIT_SUCCESS;
}
#include <cstdlib>
#include <cstdio>
#include <csignal>
#include <unistd.h>

#include "diskinfo.h"
#include "fatdisk.h"

#define BLOCK_SIZE 512

typedef unsigned char byte;

FILE *disk;

int main(int argc, char *argv[])
{
    fatdisk disk;
	long blocks;

	if (argc != 2) {
		fprintf(stderr, "usage: diskinfo <disk image file>\n");
		return EXIT_FAILURE;
	}

    disk.openDisk(argv[1]);
    // disk.dumpInfo();

	return EXIT_SUCCESS;
}
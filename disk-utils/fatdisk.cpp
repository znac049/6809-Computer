#include <stdio.h>
#include <stdlib.h>

#include "diskinfo.h"
#include "fatdisk.h"

fatdisk::fatdisk()
{
    numBlocks = -1;
    currentBlock = -1;
    diskHandle = NULL;
}

bool fatdisk::openDisk(const char *diskPath)
{
    diskHandle = fopen(diskPath, "a+");
    if (diskHandle == NULL) {
        printf("Failed to open the disk\n");
        exit(EXIT_FAILURE);
    }

	fseek(diskHandle, 0L, SEEK_END);
	numBlocks = ftell(diskHandle) / BLOCK_SIZE;

	printf("Disk opened ok - number of blocks: %ld\n", numBlocks);

    return true;
}

byte fatdisk::getByte(byte *buffer, int offset)
{
    return buffer[offset];
}

int fatdisk::getWord(byte *buffer, int offset)
{
    return buffer[offset] | (buffer[offset+1] << 8); 
}

int fatdisk::getLong(byte *buffer, int offset)
{
    return getWord(buffer, offset) | (getWord(buffer, offset+2) << 16);
}

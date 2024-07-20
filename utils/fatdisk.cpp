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
    int fatOffset;

    reservedRegion = 0;

    diskHandle = fopen(diskPath, "a+");
    if (diskHandle == NULL) {
        printf("Failed to open the disk\n");
        exit(EXIT_FAILURE);
    }

	fseek(diskHandle, 0L, SEEK_END);
	numBlocks = ftell(diskHandle) / BLOCK_SIZE;

	printf("Disk opened ok - number of blocks: %d\n", numBlocks);

    readBlock(0, blockBuffer);

    bytesPerSector = getWord(blockBuffer, BS_BYTES_PER_SECTOR);
    sectorsPerCluster = getByte(blockBuffer, BS_SECTORS_PER_CLUSTER);
    numberOfReservedSectors = getWord(blockBuffer, BS_NUMBER_OF_RESERVED_SECTORS);
    sectorsPerFat = getWord(blockBuffer, BS_SECTORS_PER_FAT);
    numberOfFats = getByte(blockBuffer, BS_NUMBER_OF_FATS);
    numberOfRootEntries = getWord(blockBuffer, BS_NUMBER_OF_ROOT_ENTRIES);

    fatRegion = reservedRegion + numberOfReservedSectors;
    rootDirectoryRegion = fatRegion + (numberOfFats * sectorsPerFat);
    dataRegion = rootDirectoryRegion + ((numberOfRootEntries * 32) / bytesPerSector);

    currentDirectory = rootDirectoryRegion;

    printf("Reserved region: %d\n", reservedRegion);
    printf("FAT region     : %d\n", fatRegion);
    printf("Root dir region: %d\n", rootDirectoryRegion);
    printf("Data region    : %d\n", dataRegion);

    printf("Sectors per Cluster: %d\n", sectorsPerCluster);

    listDirectory(currentDirectory);

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


void fatdisk::printFile(const char *name)
{

}

void fatdisk::listDirectory(int blockNum)
{
    int entNum = 0;
    const int numEntriesPerBlock = bytesPerSector / 32;
    byte *ent = blockBuffer;

    readBlock(blockNum, blockBuffer);
    for (int i=0; i<numEntriesPerBlock; i++) {
        byte attribute = ent[0x0b];
        int size = getLong(ent, 28);
        int cluster = getWord(ent, 26);

        if (ent[0] == 0) {
            return;
        }

        if ((attribute != 0x0f) && !(attribute & 0x08)) {
            printf("%03d: ", entNum);
            for (int x=0; x<11; x++) {
                if (x==8) {
                    putchar('.');
                }

                putchar(ent[x]);
            }

            printf("  att=%02x %s%s%s%s%s %6d Cluster=%d\n", 
                    attribute,
                    (attribute & 0x10)?"d":"-",
                    (attribute & 0x01)?"r-":"rw",
                    (attribute & 0x02)?"h":"-",
                    (attribute & 0x04)?"s":"-",
                    (attribute & 0x08)?"V":"-",
                    size, cluster);
        }

        ent += 32;
        entNum++;
    }
}

void fatdisk::dumpInfo()
{
    readBlock(0, blockBuffer);

    printf("  bytes per sector: %d\n", bytesPerSector);
    printf("  sectors per cluster: %d\n", sectorsPerCluster);
    printf("  reserved sectors: %d\n", numberOfReservedSectors);
    printf("  number of FATs: %d\n", numberOfFats);
    printf("  max number of root entries: %d\n", getWord(blockBuffer, 0x11));

    printf("  small number of sectors: %d\n", getWord(blockBuffer, 0x13));
    printf("  large number of sectors: %d\n", getLong(blockBuffer, 0x20));

    printf("    media descriptor: 0x%02x\n", getByte(blockBuffer, BS_MEDIA_DESCRIPTOR));
    printf("    sectors per fat: %d\n", getWord(blockBuffer, BS_SECTORS_PER_FAT));
    printf("    sectors per track: %d\n", getWord(blockBuffer, 0x18));
    printf("    number of heads: %d\n", getWord(blockBuffer, 0x1a));
    printf("    hidden sectors: %d\n", getLong(blockBuffer, 0x1c));

    printf("  volume serial number: 0x%08x\n", getLong(blockBuffer, 0x27));
    printf("  file system type: ");
    for (int i=0; i<8; i++) {
        putchar(blockBuffer[0x36+i]);
    }
    putchar('\n');

    printf("  boot sector signature: 0x%04x\n", getWord(blockBuffer, 0x1fe));
}

void fatdisk::dumpCluster(int clusterNumber)
{

}

void fatdisk::dumpBlock(int blockNum)
{
    readBlock(blockNum, blockBuffer);

    for (int i=0; i<BLOCK_SIZE; i+= 16) {
        printf("%04x: ", i);
        for (int j=0; j<16; j++) {
            printf("%02x ", blockBuffer[i+j]);
        }

        for (int j=0; j<16; j++) {
            byte c = blockBuffer[i+j];
            
            if ((c < ' ') || (c > '_'))
                c = '.';

            putchar(c);
        }
        printf("\n");
    }
}

bool fatdisk:: readBlock(int blockNum, byte *buffer)
{
    if (blockNum == currentBlock) {
        return true;
    }

    if (fseek(diskHandle, blockNum*BLOCK_SIZE, SEEK_SET)) {
        printf("Failed to seek to record %d\n", blockNum);
        return false;
    }

    if (fread(buffer, sizeof(byte), BLOCK_SIZE, diskHandle) != BLOCK_SIZE) {
        printf("Failed to read %d bytes\n", BLOCK_SIZE);
        return false;
    }

    currentBlock = blockNum;
    return true;
}

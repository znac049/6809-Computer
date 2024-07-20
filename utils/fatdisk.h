#pragma once

class fatdisk {
	protected:
		const static int BLOCK_SIZE = 512;

        // Boot Sector offsets
        const static int BS_BYTES_PER_SECTOR = 0x0b;
        const static int BS_SECTORS_PER_CLUSTER = 0x0d;
        const static int BS_NUMBER_OF_RESERVED_SECTORS = 0x0e;
        const static int BS_NUMBER_OF_FATS = 0x10;
        const static int BS_NUMBER_OF_ROOT_ENTRIES = 0x11;
        const static int BS_MEDIA_DESCRIPTOR = 0x15;
        const static int BS_SECTORS_PER_FAT = 0x16;

    private:
        FILE *diskHandle;
        int numBlocks;
        int currentBlock;
        byte blockBuffer[BLOCK_SIZE];

        int sectorsPerFat;
        int numberOfFats;
        int numberOfReservedSectors;
        int bytesPerSector;
        int numberOfRootEntries;
        int sectorsPerCluster;

        int reservedRegion;
        int fatRegion;
        int rootDirectoryRegion;
        int dataRegion;

        int currentDirectory;


	// Read and write functions
	public:

	// Other exposed interfaces
	public:
		fatdisk();

        bool openDisk(const char *diskPath);

        byte getByte(byte *buffer, int offset);
        int getWord(byte *buffer, int offset);
        int getLong(byte *buffer, int offset);

        bool readBlock(int, byte *);

        void dumpInfo();
        void dumpCluster(int);
        void dumpBlock(int);
        void listDirectory(int blockNum);
        void printFile(const char *);
};

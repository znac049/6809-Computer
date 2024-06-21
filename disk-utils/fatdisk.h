#pragma once

class fatdisk {
	protected:
		const static int BLOCK_SIZE = 512;

    private:
        FILE *diskHandle;
        long numBlocks;
        long currentBlock;


	// Read and write functions
	public:

	// Other exposed interfaces
	public:
		fatdisk();

        bool openDisk(const char *diskPath);

        byte getByte(byte *buffer, int offset);
        int getWord(byte *buffer, int offset);
        int getLong(byte *buffer, int offset);
};

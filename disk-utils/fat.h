#pragma once

class fat {
	protected:
		const static int MAX_DISKS = 2;
		const static int BLOCK_SIZE = 512;

		const static Byte CMD_WRITE_BLOCK	= 0x01;
		const static Byte CMD_READ_BLOCK	= 0x02;
		const static Byte CMD_QUERY_DRIVE 	= 0x03; 
		const static Byte CMD_RESET	      	= 0x04; 

		const static Byte SR_ERR  			= 0x01;		// Command failed
		const static Byte SR_PRESENT		= 0x02;		// Drive is present
        const static Byte SR_RDA            = 0x04;     // Data available to read
		const static Byte SR_IN_PROG 		= 0x10;		// Another operation in progress
    	const static Byte SR_BUSY 			= 0x40;		// Controller is busy
		const static Byte SR_RDY  			= 0x80;

	// Internal registers
	protected:
		Byte				cmd, sr, cr, dr;

	// Initialisation functions
	bool openDisk(const char *name, int diskNum);

	// Read and write functions
	public:
		virtual Byte		read(Word offset);

	// Other exposed interfaces
	public:
		dkc();
};

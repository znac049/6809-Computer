#include <cstdlib>
#include <cstdio>
#include <csignal>
#include <unistd.h>

int getByte(FILE *fd)
{
    int b = fgetc(fd);

    if (b == EOF) {
        fprintf(stderr, "\r\nEOF!\n");
        exit(-1);
    }

    return b;
}

int getWord(FILE *fd)
{
    int w = getByte(fd);
    int b = getByte(fd);

    if ((w == -1) || (b == -1)) {
        return w;
    }

    // return w | (b<<8);
    return b | (w<<8);
}

int main(int argc, char *argv[])
{
    FILE *fd;
	long blocks;
    int fieldType;
    int addr,len;
    int b;
    int ok = 1;

	if (argc != 2) {
		fprintf(stderr, "usage: decbinfo <file>\n");
		return EXIT_FAILURE;
	}

    fd = fopen (argv[1], "r");
    if (fd == NULL) {
        fprintf(stderr, "Couldn't open file '%s\n", argv[1]);
        return EXIT_FAILURE;
    }

    while (ok) { 
        fieldType = getByte(fd);
        printf("Field Type=%02x\n", fieldType);
        switch (fieldType) {
            case 0:
                len = getWord(fd);
                addr = getWord(fd);

                if ((len == -1) || (addr == -1)) {
                    fprintf(stderr, "Bad format - EOF\n");
                    ok = 0;
                }

                printf("Reading %04x bytes into %04x\n", len, addr);
                for (int i=0; i<len; i++) {
                    printf("%04x\r", i);
                    b = getByte(fd);
                }
                break;

            case 0xff:
                ok = 0;
                break;

            default:
                fprintf(stderr, "Funny field type - %02x\n", fieldType);
                ok = 0;
                break;
        }
    }

    fclose(fd);

	return EXIT_SUCCESS;
}


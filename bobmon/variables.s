;--------------------------------------------------------
;
; variables.s - variables used by the monitor
;
; They will be placed at the end of ram
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

			globals
			
MAX_LINE		equ	80
MAX_ARGS		equ	5

g.memoryAddress		rmb	2
g.linesPerPage		rmb	1	; the number of terminal lines to display at a time

; Used by the command parser
lsn.p			rmb	4	; The os9 sector number
lba.p			rmb	4	; SD card block number

rootLSN.p		rmb	4	; The start of the root directory
bootLSN.p		rmb	4	; The fisrt LSN of the boot file
bootSize		rmb	2	; Length in bytes of the boot file


* Virtual disk subsystem
secBuff			rmb	512

; Used by getHexWord
word_value		rmb	2

* S Records
srType		rmb	1	; The type of the most recent record read
srCount		rmb	1	; The count of the most recent record read
srAddr		rmb	2	; The address to load the next data byte into
srXSum		rmb	1	; The calculated checksum


; Used by disassembler

ADDR    RMB     2               ; Current address to disassemble
OPCODE  RMB     1               ; Opcode of instruction
AM      RMB     1               ; Addressing mode of instruction
OPTYPE  RMB     1               ; Instruction type
POSTBYT RMB     1               ; Post byte (for indexed addressing)
LEN     RMB     1               ; Length of instruction
TEMP    RMB     2               ; Temp variable (used by print routines)
TEMP1   RMB     2               ; Temp variable
FIRST   RMB     1               ; Flag used to indicate first time an item printed
PAGE23  RMB     1               ; Flag indicating page2/3 instruction when non-zero




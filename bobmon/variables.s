;--------------------------------------------------------
;
; variables.s - variables used by the monitor
;
; They will be placed at the end of ram
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

			section	"BSS"
			
			org	(ram_end-variables_size)+1
variables_start		equ	*

cpu6809			equ	0
cpu6309			equ	1

cpu_type		rmb	1

ramEnd			rmb    	2

putChar_fn		rmb	2
getChar_fn		rmb	2

current_column		rmb	1

MAX_LINE		equ	80
MAX_ARGS		equ	5
line_buff		rmb	MAX_LINE
argc			rmb	1
argv			rmb	MAX_ARGS*2

dump_address		rmb	2
dump_window		rmb	1	; the number of terminal lines to display at a time

ihex_length		rmb	1
ihex_address		rmb	2
ihex_type		rmb	1
ihex_xsum		rmb	1

; Used by the command parser
matched_ccb		rmb	2
match_count		rmb	1

lsn.p		rmb	4	; The os9 sector number
lba.p		rmb	4	; SD card block number

rootLSN.p		rmb	4	; The start of the root directory
bootLSN.p		rmb	4	; The fisrt LSN of the boot file
bootSize		rmb	2	; Length in bytes of the boot file


* Virtual disk subsystem
secBuff			rmb	512

; Used by getHexWord
word_value		rmb	2

; Used by getHexByte
upper_nibble		rmb	1

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



variables_size		equ	*-variables_start
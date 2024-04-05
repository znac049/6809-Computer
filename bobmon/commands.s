;--------------------------------------------------------
;
; commands.s - command processing
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

; Main command table
cmd_table	fdb	doDebug
		fcn	"debug"

		fdb	doDump
		fcn	"dump"

		fdb	doLoad
		fcn	"load"

		fdb	doRegisters
		fcn	"registers"

		fdb	doHelp
		fcn	"?"

		fdb	0

doDebug		rts

doDump		leax	dump_msg,pcr
		lbsr	putStr
		rts

;
; doLoad - load Intel hex records
;
doLoad		leax	loading_msg,pcr
		lbsr	putStr

loadRecord	lbsr	getChar
		cmpa	#CTRLC
		lbeq	loadAbort

; read a record
		cmpa	#':'
		bne	loadRecord

		lbsr	getHexByte
		sta	ihex_length
		sta	ihex_xsum

		lbsr	getHexWord
		std	ihex_address
		adda	ihex_xsum
		sta	ihex_xsum
		addb	ihex_xsum
		stb	ihex_xsum

		lbsr	getHexByte
		sta	ihex_type
		adda	ihex_xsum
		sta	ihex_xsum

; we only need type 00 and 01 records - ignore anything else
		lda	ihex_type
		cmpa	#0	; data record
		beq	loadData
		cmpa	#1
		beq	loadEOF
		
; Record type not supported. Whine and then abort.
		leax	load_not_supported_msg,pcr
		lbsr	putStr
		bsr	loadGobbleLine
		bra	loadAbort

loadData	ldx	ihex_address

		tfr	x,d
		lbsr	putHexWord
		lda	#CR
		lbsr	putChar

		ldb	ihex_length
		beq	2F		; This would be unusual - a data record of 0 items

1		lbsr	getHexByte
		
		sta	,x+

		adda	ihex_xsum
		sta	ihex_xsum

		decb
		bne	1B

2		bsr	getLoadChecksum
		bne	loadBadXsum
		bsr	loadGobbleLine

		bra	loadRecord	; look for the next record

loadEOF		bsr	getLoadChecksum
		bne	loadBadXsum
		leax	load_ok_msg,pcr
		lbsr	putStr
		bra	loadDone

loadBadEOF	leax	load_eof_err_msg,pcr
		lbsr	putStr
		bsr	loadGobbleLine
		bra	loadDone

loadBadXsum	leax	load_xsum_err_msg,pcr
		lbsr	putStr
		
loadGobbleLine	lbsr	getChar
		cmpa	#CR
		bne	loadGobbleLine
		rts
		
loadAbort	leax	load_aborted_msg,pcr
		lbsr	putStr

loadDone	rts

getLoadChecksum	pshs	b
		lbsr	getHexByte
		tfr	a,b
		lda	ihex_xsum
		coma
		adda	#1
		sta	ihex_xsum
		cmpb	ihex_xsum
		puls	b,pc

loading_msg	fcn	"Loading INTEL hex - press Ctrl-C to abort.",CR,LF
load_aborted_msg
		fcn	CR,LF,"Aborted.",CR,LF
load_ok_msg	fcn	CR,LF,"Loaded ok.",CR,LF
load_eof_err_msg
		fcn	CR,LF,"Badly formatted End of File record.",CR,LF
load_xsum_err_msg
		fcn	CR,LF,"Calculated checksum does not match expected checksum.",CR,LF
load_not_supported_msg
		fcn	CR,LF,"Unsupported record type found. We only support types 0 and 1.",CR,LF

doRegisters	pshs	a,b,x,y,u
		leax	reg_msg_1,pcr
		lbsr	putStr
		lbsr	putHexByte
		
		leax	reg_msg_2,pcr
		lbsr	putStr
		tfr	b,a
		lbsr	putHexByte
		
		leax	reg_msg_3,pcr
		lbsr	putStr
		tfr	x,d
		lbsr	putHexWord
		
		leax	reg_msg_4,pcr
		lbsr	putStr
		tfr	y,d
		lbsr	putHexWord
		
		leax	reg_msg_5,pcr
		lbsr	putStr
		tfr	u,d
		lbsr	putHexWord
		
		leax	reg_msg_6,pcr
		lbsr	putStr
		tfr	s,d
		lbsr	putHexWord

		lbsr	putNL
		
		puls	a,b,x,y,u,pc

reg_msg_1	fcn	"A:"
reg_msg_2	fcn	" B:"
reg_msg_3	fcn	" X:"
reg_msg_4	fcn	" Y:"
reg_msg_5	fcn	" U:"
reg_msg_6	fcn	" S:"

doHelp		rts

dump_msg	fcn	"Dumping...",CR,LF

; matchCommand -
;
;  
matchCommand	pshs	x,y,b
		tfr	x,y
		leax	cmd_table,pcr

		ldd	#0
		std	-5,s
		clr	-3,s
		sty	-2,s

1		ldd	,x		; address of handler
		beq	5F		; end of command table
		stx	-5,s
		leax	2,x		; Point at start of command string

2		lda	,y+		; compare strings
		beq	4F		; end of string

		cmpa	#SPACE		; end of command?
		beq	4F

		cmpa	,x+		; compare string with command
		beq	2B

3		lda	,x+		; No match - skip over rest of string
		bne	3B
		ldy	-2,s		; next command
		bra	1B

4		ldy	-2,s		; It's a match - try the next command
		inc 	-3,s		; Increment the match count
		ldd	[-5,s]
		std	matched_command_ptr
		bra	1B

5		lda	-3,s
		puls	x,y,b,pc

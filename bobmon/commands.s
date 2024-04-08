;--------------------------------------------------------
;
; commands.s - command processing
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

; Main command table
cmd_table	fdb	doDump
		fcb	0,2
		fcn	"dump"

		fdb	doDuty
		fcb	1,3
		fcn	"duty"

		fdb	doGo
		fcb	0,1
		fcn	"go"

		fdb	doLoad
		fcb	0,0
		fcn	"load"

		fdb	doRegisters
		fcb	0,0
		fcn	"registers"

		fdb	doHelp
		fcb	0,0
		fcn	"?"

		fdb	0

doDump		leax	dump_msg,pcr
		lbsr	putStr
		rts

doDuty		rts

doGo		rts

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

;
; matchCommand -
;
; Call with:
;	X - address of string (command) to look up
;
; Returns:
;	A - count of matches
;
matchCommand	pshs	y,b

		leay	cmd_table,pcr
		ldd	#0
		sta	match_count
		std	matched_ccb

mcTryNext	ldd	,y		; Handler addres
		beq	mcDone

		bsr	singleMatch
		tsta
		beq	mcNoMatch

; We found a match
		adda	match_count	; Bump the match count
		sta	match_count	;
		sty	matched_ccb	; Stash address of command block

mcNoMatch	lbsr	nextCCB
		bra	mcTryNext

mcDone		lda	match_count
		puls	y,b,pc

;
; singleMatch -
;
; Call with:
;	X - address of command line
;	Y - address of command block (CCB)
;
; Returns:
;	A - 0=no match, 1=match
;
singleMatch	pshs	x,y
		leay	4,y		; point at the start of the command string

smNext		lda	,x+
		beq	smEndCmd	; hit end of command line
		cmpa	#SPACE
		beq	smEndCmd
		cmpa	#TAB
		beq	smEndCmd
		cmpa	#CR
		beq	smEndCmd
		cmpa	,y+
		beq	smNext		; matching so far
; Strings don't match.
		clra			; signal no match and return
		bra	smDone

; We've hit the end of the command line or first arg, so it's a match
smEndCmd	lda	#1

smDone		puls	x,y,pc

;
; readCommandLine -
;
; Call with:
;	X - Address of buffer to read into
;	A - buffer size
;
; Returns:
;
readCommandLine	pshs	a,x
		clr	,x	; Clear the string

rclNextChar	lbsr	getLChar
		cmpa	#SPACE
		blt	rclNonPrintable
		cmpa	#DEL
		beq	rclDelete
		bra	rclPrintable

; Non printable char
rclNonPrintable	cmpa	#CR
		beq	rclEOL

		* lbsr	putNL
		* lbsr	putHexByte
		* lbsr	putNL
		
		cmpa	#DEL
		beq	rclDelete

; Complain and then ignore it
		lda	#BELL
		lbsr	putChar
		bra	rclNextChar

; Handle delete
rclDelete	cmpx	#line_buff	; Ignore if nothing to delete
		beq	rclNextChar
		
		leax	-1,x		; Back up one space
		clr	,x
		lda	#BS
		lbsr	putChar
		lda	#SPACE
		lbsr	putChar
		lda	#BS
		lbsr	putChar
		bra	rclNextChar

; It's a printable character
rclPrintable	lbsr	putChar

		sta	,x+
		clr	,x
		bra	rclNextChar	

rclEOL		lbsr	putNL
		puls	a,x,pc

;
; nextCCB -
;
; Called with:
;	Y - address of current CCB
;
;
; Returns:
;	Y - address of next CCB
;
nextCCB		pshs	a
		leay	4,y	; Start of current command string
ncNext		lda	,y+	; skip over the string
		bne	ncNext
		puls	a,pc
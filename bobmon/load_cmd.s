;
; doLoad - load Intel hex records
;

loadMinArgs	equ	0
loadMaxArgs	equ	0
loadCommand	fcn	"load"
loadHelp	fcn	TAB,"load intel hex records (types 0 and 1 only) from the terminal"

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

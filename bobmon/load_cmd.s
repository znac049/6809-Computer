;
; doLoad - load Intel hex records
;

		globals

g.ihexLength	rmb	1
g.ihexAddress	rmb	2
g.ihexType	rmb	1
g.ihexXsum	rmb	1


		code

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
		sta	g.ihexLength
		sta	g.ihexXsum

		lbsr	getHexWord
		std	g.ihexAddress
		adda	g.ihexXsum
		sta	g.ihexXsum
		addb	g.ihexXsum
		stb	g.ihexXsum

		lbsr	getHexByte
		sta	g.ihexType
		adda	g.ihexXsum
		sta	g.ihexXsum

; we only need type 00 and 01 records - ignore anything else
		lda	g.ihexType
		cmpa	#0	; data record
		beq	loadData
		cmpa	#1
		beq	loadEOF
		
; Record type not supported. Whine and then abort.
		leax	load_not_supported_msg,pcr
		lbsr	putStr
		bsr	loadGobbleLine
		bra	loadAbort

loadData	ldx	g.ihexAddress

		tfr	x,d
		lbsr	putHexWord
		lda	#CR
		lbsr	putChar

		ldb	g.ihexLength
		beq	2F		; This would be unusual - a data record of 0 items

1		lbsr	getHexByte
		
		sta	,x+

		adda	g.ihexXsum
		sta	g.ihexXsum

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
		lda	g.ihexXsum
		coma
		adda	#1
		sta	g.ihexXsum
		cmpb	g.ihexXsum
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

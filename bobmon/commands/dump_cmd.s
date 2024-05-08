dumpMinArgs	equ	0
dumpMaxArgs	equ	2
dumpCommand	fcn	"dump"
dumpHelp	fcn	"[<address> [<number of bytes to dump>]]",TAB,"display contents of memory"


doDump		ldy	g.memoryAddress	; load defaul values for addr and count
		ldb	g.linesPerPage

		lda	g.argc
		cmpa	#3		; All args
		beq	ddAllArgs
		cmpa	#2		; Just address
		beq	ddJustAddress
		bra	ddProceed	; no args (just command)

ddBadArgs	leax	dd_msg_1,pcr
		lbsr	putStr
		bra	ddDone
ddAllArgs	; convert argv[2] to window size
		leax	g.argv,pcr
		ldx	4,x
		lbsr	putNL
		lbsr	strToHex
		bcs	ddBadArgs
		tsta
		bne	ddBadArgs
		
		stb	g.linesPerPage

ddJustAddress	; convert argv[1] to address
		leax	g.argv,pcr
		ldx	2,x
		lbsr	strToHex
		bcs	ddBadArgs
		std	g.memoryAddress
		tfr	d,y

		ldb	g.linesPerPage

; Y = address to dump
; B = window size
ddProceed	bsr	dumpSixteen
		decb
		bne	ddProceed
ddDone		rts

dd_msg_1	fcn	"Badly formatted coomand line.",CR,LF

dumpSixteen	pshs	d,y,x
		ldd	g.memoryAddress
		tfr	d,y
		lbsr	putHexWord

		leax	ds_msg_1,pcr
		lbsr	putStr
		lbsr	dumpBytes
		leax	ds_msg_2,pcr
		lbsr	putStr
		lbsr	dumpAscii
		lbsr	putNL		

		leay	16,y
		sty	g.memoryAddress

		puls	d,x,y,pc

ds_msg_1	fcn	": "
ds_msg_2	fcn	"    "

dumpBytes	pshs	y,b,a
		ldb	#16

dbNext		lda	,y+
		lbsr	putHexByte
		lda	#SPACE
		lbsr	putChar

		decb
		bne	dbNext

		puls	y,b,a,pc

dumpAscii	pshs	y,b,a
		ldb	#16

daNext		lda	,y+
		cmpa	#SPACE
		blt	daDot
		cmpa	#DEL
		blt	daLoop
daDot		lda	#'.'
daLoop		lbsr	putChar
		
		decb
		bne	daNext
		
		puls	y,a,b,pc

dumpMinArgs	equ	0
dumpMaxArgs	equ	2
dumpCommand	fcn	"dump"
dumpHelp	fcn	"[<address> [<number of bytes to dump>]]",TAB,"display contents of memory"


doDump		ldb	#dump_window
ddLoop		tsta	; Any args?
		beq	ddNoArgs
		cmpa	#2
		bne	ddNoCount

ddNoCount	

		ldb	dump_window

ddNoArgs	bsr	dumpSixteen
		decb
		bne	ddLoop
		rts

dumpSixteen	pshs	d,y,x
		ldd	dump_address
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
		sty	dump_address

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

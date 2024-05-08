helpMinArgs	equ	0
helpMaxArgs	equ	0
helpCommand	fcn	"help"
helpHelp	fcn	TAB,"Display this help"

doHelp		leax	dh_msg_1,pcr
		lbsr	putStr
		leay	cmd_table,pcr
		
dhNext		ldd	,y
		beq	dhDone
		lda	#SPACE
		lbsr	putChar
		lbsr	putChar
		ldx	4,y		; The command string
		lbsr	putStr

		lda	#SPACE
		lbsr	putChar

		ldx	6,y		; The help string
dhPrNext	lda	,x+
		beq	dhCmdDone
		cmpa	#TAB
		bne	dhPrChar
		lda	#24
		lbsr	padToCol
		bra	dhPrNext
		
dhPrChar	lbsr	putChar
		bra	dhPrNext
dhCmdDone	lbsr	putNL
		lbsr	putNL

		leay	8,y
		bra	dhNext

dhDone		rts

dh_msg_1	fcn	"Commands I understand:",CR,LF


windowMinArgs	equ	0
windowMaxArgs 	equ	1
windowCommand	fcn	"window"
windowHelp	fcn	"[<# lines>]",TAB,"The numer of lines to display at a time"

doWindow	lda	argc
		cmpa	#2
		beq	dwSetWindow

		leax	dw_msg_1,pcr
		lbsr	putStr
		lda	dump_window
		lbsr	putHexByte
		lbsr	putNL
		bra	dwDone

dwSetWindow	leay	argv,pcr
		ldx	2,y		; argv[1]
		lbsr	strToHexByte
		sta	dump_window
dwDone		rts

dw_msg_1	fcn	"Current window is: "
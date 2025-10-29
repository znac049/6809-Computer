		import	g.argc
		import	g.argv
		import	g.linesPerPage

		import	putStr
		import	putHexByte
		import	putNL
		import	strToHex

		section code

		export	windowCommand
		export	windowHelp
windowCommand	fcn	"window"
windowHelp	fcn	"[<# lines>]\tThe numer of lines to display at a time"

		export	windowFn
windowFn	lda	g.argc
		cmpa	#2
		beq	dwSetWindow

		leax	dw_msg_1,pcr
		lbsr	putStr
		lda	g.linesPerPage
		lbsr	putHexByte
		lbsr	putNL
		bra	dwDone

dwSetWindow	leay	g.argv,pcr
		ldx	2,y		; argv[1]
		lbsr	strToHex
		bcs	dwOverflow
		tsta
		bne	dwOverflow
		stb	g.linesPerPage
		bra	dwDone

dwOverflow	leax	dw_msg_2,pcr
		lbsr	putStr
dwDone		rts

dw_msg_1	fcn	"Current window is: "
dw_msg_2	fcn	"Window size is too big or not a hex value.\r\n"

		end section
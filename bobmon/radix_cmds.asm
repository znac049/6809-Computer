;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; radix_cmds.asm - implements the "radix, "hexadecimal", "decimal" 
; and "binary" commands.
;
		include "constants.s"

		import	g.radix

		import 	putStr
		import	putNL

		section globals

		export	g.radix
g.radix		rmb	1		; Hold the current radix

		section code

		export	radixMinArgs
		export	radixMaxArgs
		export	radixCommand
		export	radixHelp
radixMinArgs	equ	0
radixMaxArgs	equ	1

radixCommand	fcn	"radix"
radixHelp	fcn	"\tDiaplay the current radix"


		export	decimalMinArgs
		export	decimalMaxArgs
		export	decimalCommand
		export	decimalHelp
decimalMinArgs	equ	0
decimalMaxArgs	equ	0
decimalCommand	fcn	"decimal"
decimalHelp	fcn	"\tChange the diaply radix to decimal"


		export	binaryMinArgs
		export	binaryMaxArgs
		export	binaryCommand
		export	binaryHelp
binaryMinArgs	equ	0
binaryMaxArgs	equ	0
binaryCommand	fcn	"binary"
binaryHelp	fcn	"\tChange the diaply radix to binary"


		export	hexadecimalMinArgs
		export	hexadecimalMaxArgs
		export	hexadecimalCommand
		export	hexadecimalHelp
hexadecimalMinArgs	equ	0
hexadecimalMaxArgs	equ	0
hexadecimalCommand fcn	"hexadecimal"
hexadecimalHelp	fcn	"\tChange the diaply radix to hexadecimal"


*******************************************************************
* doDecimal - called by the command processor when the "decimal" 
*	command is entered.
*
* on entry: nothing:
*
*  trashes: potentially everything (the command processor asumes this)
*
*  returns: nothing
*
		export  decimalFn
decimalFn	lda	#10
		sta	g.radix
		rts

*******************************************************************
* doBinary- called by the command processor when the "binary" 
*	command is entered.
*
* on entry: nothing:
*
*  trashes: potentially everything (the command processor asumes this)
*
*  returns: nothing
*
		export	binaryFn
binaryFn	lda	#2
		sta	g.radix
		rts

*******************************************************************
* doHexadecimal - called by the command processor when the "hexadecimal" 
*	command is entered.
*
* on entry: nothing:
*
*  trashes: potentially everything (the command processor asumes this)
*
*  returns: nothing
*
		export	hexadecimalFn
hexadecimalFn	lda	#16
		sta	g.radix
		rts

*******************************************************************
* doRadix - called by the command processor when the "radix" 
*	command is entered.
*
* on entry: nothing:
*
*  trashes: potentially everything (the command processor asumes this)
*
*  returns: nothing
*
		export	radixFn
radixFn		leax	radix_msg,pcr
		lbsr	putStr
		lda	g.radix
		cmpa	#2
		beq	drBinary
		cmpa	#16
		beq	drHex
		
		leax	radix_dec_msg,pcr
		lbsr	putStr
		bra	drDone

drBinary	leax	radix_binary_msg,pcr
		lbsr	putStr
		bra	drDone

drHex		leax	radix_hex_msg,pcr
		lbsr	putStr

drDone		lbsr	putNL
		rts

radix_msg	fcn	"The current radix is: "
radix_binary_msg fcn	"binary"
radix_dec_msg	fcn	"decimal (signed)"
radix_hex_msg	fcn	"hexadecimal"

		end section
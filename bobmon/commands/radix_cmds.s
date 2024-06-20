;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; radix_cmds.s - implements the "radix, "hexadecimal", "decimal" 
; and "binary" commands.
;

radixMinArgs	equ	0
radixMaxArgs	equ	1

decimalCommand	fcn	"decimal"
decimalHelp	fcn	TAB,"Change the diaply radix to decimal"
binaryCommand	fcn	"binary"
binaryHelp	fcn	TAB,"Change the diaply radix to binary"
hexadecimalCommand fcn	"hexadecimal"
hexadecimalHelp	fcn	TAB,"Change the diaply radix to hexadecimal"
radixCommand	fcn	"radix"
radixHelp	fcn	TAB,"Diaplay the current radix"


		globals

g.radix		rmb	1		; Hold the current radix


		code

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
doDecimal	lda	#10
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
doBinary	lda	#2
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
doHexadecimal	lda	#16
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
doRadix		leax	radix_msg,pcr
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


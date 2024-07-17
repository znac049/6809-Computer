		import	binToHexDigit

		section code

*******************************************************************
* binToHex - convert a 16-bit number to a hexadecimal ascii string
*
* on entry: 
*	D: the 16-bit number to convert
*	X: address of the buffer to write to
*
*  trashes: nothing
*
*  returns: nothing
*
		export	binToHex
binToHex	pshs	d,x,y

		tfr	x,y
		leax	1,x
		clr	,y		; Set count to zero
		
		cmpd	#0
		beq	Zero		; Special case

		tsta
		beq	LowByte

; Upper byte
		pshs	a
		lsra
		lsra
		lsra
		lsra
		lbsr	binToHexDigit
		puls	a
		anda	#$0f
		lbsr	binToHexDigit

; Lower byte
LowByte		tfr	b,a
		pshs	a
		lsra
		lsra
		lsra
		lsra
		lbsr	binToHexDigit
		puls	a
		anda	#$0f
		lbsr	binToHexDigit
		bra	Done

Zero		inc	,y
		lda	#'0'
		sta	,x

Done		puls	d,x,y,pc

		end section
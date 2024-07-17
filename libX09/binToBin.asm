		import 	binToBinDigits

		section code

*******************************************************************
* binToBin - convert a 16-bit number to a binary ascii string
*
* on entry: 
*	D: the 16-bit number to convert
*	X: address of the buffer to write to
*
*  trashes: nothing
*
*  returns: nothing
*
		export	binToBin
binToBin	pshs	d,x,y
		
		tfr	x,y
		leax	1,x
		clr	,y		; Set count to zero
		
		cmpd	#0
		beq	Zero		; Special case

		lbsr	binToBinDigits
		tfr	b,a
		lbsr	binToBinDigits
		bra	Done

Zero		inc	,y
		lda	#'z'
		sta	,x
Done		puls	d,x,y,pc

		end section
		section code

*******************************************************************
* binToBinDigits - convert an 8-bit number to a binary ascii string
*
* on entry: 
*	A: the 8-bit number to convert
*	X: the buffer to put the character into
*	Y: Address of the count byte
*
*  trashes:
*	X: gets incremented if characters were written, otherwise unchanged.
*
*  returns: nothing
*
		export	binToBinDigits
binToBinDigits	pshs	b		; Do not combine, the push order
		pshs	a		; is important

		ldb	#$80		; Top bit of byte
		pshs	b
btbdLoop	andb	1,s
		bne	btbdOne

		tst	,y		; Ignore if a leading zero
		beq	btbdShift
		lda	#'0'
		bra	btbdNext
		
btbdOne		lda	#'1'

btbdNext	sta	,x+		; Output digit
		inc	,y		; bump length
btbdShift	ldb	,s
		lsrb
		stb	,s
		tstb
		bne	btbdLoop

		puls	b
		puls	a		; Do not combine, the pull order
		puls	b,pc		; is important

		end section		
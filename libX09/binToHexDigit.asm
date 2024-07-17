		section code

*******************************************************************
* binToHexDigit - convert a 4-bit number to a hexadecimal ascii string
*
* on entry: 
*	A: the 4-bit number to convert (lower 4 bits)
*	X: the buffer to put the character into
*	Y: Address of the count byte
*
*  trashes:
*	X: gets incremented if a character was written, otherwise unchanged.
*
*  returns: nothing
*
		export	binToHexDigit
binToHexDigit	pshs	a

		anda	#$0f
		
		tsta
		bne	bthdMustPrint

; The value is zero. We can skip it if it's a leading zero
		tst	,y
		beq	bthdDone	; It's a leading zero

bthdMustPrint	cmpa	#10
		bge	bthdLetter

		adda	#'0'
		bra	bthdStash

bthdLetter	suba	#10
		adda	#'a'

bthdStash	sta	,x+
		inc	,y

bthdDone	puls	a,pc

		end section
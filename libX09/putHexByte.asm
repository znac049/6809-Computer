		import	putHexDigit

		section code

*******************************************************************
* putHexByte - print an 8-bit number as a hex number (2 digits)
*
* on entry: 
*	A: The number to print
*
*  trashes: nothing
*
*  returns: nothing
*
		export	putHexByte
putHexByte	pshs	a,cc
		rora
		rora
		rora
		rora
		lbsr	putHexDigit
		rora
		rora
		rora
		rora
		rora	; rotate through carry bit
		lbsr	putHexDigit
		puls	a,cc,pc

		end section
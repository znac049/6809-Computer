		import	putChar

		section code

*******************************************************************
* putHexDigit - print a 4-bit number as a hex number
*
* on entry: 
*	A: The number to print (bottom 4 bits)
*
*  trashes: nothing
*
*  returns: nothing
*
		export	putHexDigit
putHexDigit	pshs	a,cc
		anda	#$0f
		adda	#'0'
		cmpa	#'9'
		ble	number
		adda	#$27
number		lbsr	putChar
		puls	a,cc
		rts

		end section
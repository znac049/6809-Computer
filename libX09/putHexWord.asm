		import	putHexByte

		section code

*******************************************************************
* putHexWord - print a 16-bit number as a hex number (4 digits)
*
* on entry: 
*	D: The number to print
*
*  trashes: nothing
*
*  returns: nothing
*
		export	putHexWord
putHexWord	pshs	a,b
		lbsr	putHexByte
		exg	a,b
		lbsr	putHexByte
		puls	a,b,pc

		end section
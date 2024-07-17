		import	g.upperNibble

		import	getHexDigit

		section code

		*******************************************************************
* getHexByte - read (wait if necessary) two characters and treat them
*	as hexadecimal
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	A: the hex value
*
		export	getHexByte
getHexByte	lbsr	getHexDigit
		lsla
		lsla
		lsla
		lsla
		sta	g.upperNibble
		lbsr	getHexDigit
		adda	g.upperNibble
		rts

		end section
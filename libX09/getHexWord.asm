		import getHexByte

		section code

		*******************************************************************
* getHexWord - read (wait if necessary) four characters and treat them
*	as hexadecimal
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	D: the hex value
*
		export	getHexWord
getHexWord	lbsr	getHexByte
		tfr	a,b
		lbsr	getHexByte
		exg	a,b
		rts

		end section
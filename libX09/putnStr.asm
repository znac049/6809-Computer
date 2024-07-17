		import	putChar

		section code

*******************************************************************
* putnStr - print a string of a given length
*
* on entry: 
*	X: The string to print
*	B: The number of character to print
*
*  trashes: nothing
*
*  returns: nothing
*
		export	putnStr
putnStr		pshs	a,b,x

		cmpb    #0
		beq     pnStrEnd
            
pnStrNext	lda	,x+

		lbsr	putChar
		decb
		beq     pnStrEnd
		bra	pnStrNext

pnStrEnd 	puls	a,b,x,pc

		end section
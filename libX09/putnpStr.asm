		import	putPrintableChar

		section code

******************************************************************
* putnpStr - print a string of a given length, substituting
*	non-printables
*
* on entry: 
*	X: The string to print
*	B: The number of character to print
*
*  trashes: nothing
*
*  returns: nothing
*
		export	putnpStr
putnpStr	pshs	a,b,x

		tstb
		beq     end
            
next		lda	,x+
		lbsr	putPrintableChar
		decb
		beq     end
		bra	next

end	 	puls	x,b,a,pc

		end section
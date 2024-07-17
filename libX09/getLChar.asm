		include	"lib.s"

		import	getChar

		section code

*******************************************************************
* getLChar - read (wait if necessary) a character and convert 
*	uppercase to lower.
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	A: the character we read
*
		export	getLChar
getLChar	lbsr	getChar
		cmpa	#'A'
		blt	Done
		cmpa	#'Z'
		bgt	Done
		ora	#$20
Done		rts

		end section
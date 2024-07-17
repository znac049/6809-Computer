		import	getLChar

		section code

*******************************************************************
* getHexDigit - read (wait if necessary) a character and convert it's
*	ASCII value to it's hexadecimal equivalent
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	A: the character we read
*
		export	getHexDigit
getHexDigit	lbsr	getLChar
		cmpa	#'0'
		blt	badDigit
		cmpa	#'9'
		bgt	notNumber
		suba	#'0'
		bra	done

notNumber	cmpa	#'a'
		blt	badDigit
		cmpa	#'f'
		bgt	badDigit
		suba	#'a'
		adda	#10
		bra	done

badDigit	lda	#$ff
done		rts

		end section
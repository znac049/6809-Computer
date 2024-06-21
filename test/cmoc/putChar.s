		section code

		export _putChar
_putChar	lda	#'?'
		swi
		fcb	1
		rts
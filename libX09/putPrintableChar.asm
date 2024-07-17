		include "lib.s"

		import	putChar

		section globals

		export g.unprintable
g.unprintable	fcb	'.'

		section code

*******************************************************************
* putPrintableChar - write a character. Non printable chars will 
*		use a printable character instead (default: <space>)
*
* on entry: 
*	A: character to write
*
*  trashes: nothing
*
*  returns: nothing
*
		export putPrintableChar
putPrintableChar
		pshs	a
		cmpa	#SPACE
		blt	ppcNope
		cmpa	#127
		blt	ppcOk
ppcNope		lda	g.unprintable	; Use a special char to
					; indicate non-printable char
ppcOk		lbsr	putChar
		puls	a,pc

		end section
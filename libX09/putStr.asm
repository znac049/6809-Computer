		include "lib.s"

		import putChar

		section code


*******************************************************************
* putStr - write an EOS terminated string
*
* on entry: 
*	X: address of string to print
*
*  trashes: nothing
*
*  returns: nothing
*
		export 	putStr
putStr		pshs	a,x
Loop		lda	,x+
		beq	Done
		lbsr	putChar
		tsta
		bpl	Loop
Done		puls	a,x,pc

		end section
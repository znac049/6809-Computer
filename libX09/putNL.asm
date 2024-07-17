		include "lib.s"

		import	putChar

		section code

*******************************************************************
* putNL - print a Newline
*
* on entry: nothing
*
*  trashes: nothing
*
*  returns: nothing
*
		export 	putNL
putNL		pshs	a
		lda	#CR
		lbsr	putChar
		lda	#LF
		lbsr	putChar
		puls	a,pc

		end section
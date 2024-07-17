		include "lib.s"

		import	getChar

		section code

*******************************************************************
* skipLine - gobble all characters up to and including CR
*
* on entry: none
*
*  trashes: nothing
*
*  returns: nothing
*
		export	skipLine
skipLine	pshs	a
nextChar	lbsr	getChar
		cmpa	#CR
		bne	nextChar
		puls	a,pc

		end section
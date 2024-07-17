		import	putHexWord

		section code

*******************************************************************
* putLSN - print a long (32-bit) number
*
* on entry:
*	X: pointer to LSN
*
*  trashes: nothing
*
*  returns: nothing
*
		export	putLSN
putLSN		pshs	d

		ldd	,x
		lbsr	putHexWord
		ldd	2,x
		lbsr	putHexWord

		puls	d,pc

		end section
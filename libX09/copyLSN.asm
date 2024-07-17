		section code

*******************************************************************
* copyLSN - copy a LSN
*
* on entry:
*	X: pointer to source LSN
*       y: pointer to the destination LSN
*
*  trashes: nothing
*
*  returns: nothing
*
		export	copyLSN
copyLSN		pshs	a,b
		ldd	,x
		std	,y
		ldd	2,x
		std	2,y
		puls	a,b,pc

		end section		
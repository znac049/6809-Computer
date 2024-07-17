		section code

*******************************************************************
* clearLSN - initialise a LSN to 0
*
* on entry: 
*	X: pointer to LSN
*
*  trashes: nothing
*
*  returns: nothing
*
		export clearLSN
clearLSN	pshs	d
		ldd	#0
		std	,x
		std	2,x
		puls	d,pc

		end section


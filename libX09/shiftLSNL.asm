		section code

*******************************************************************
* shiftLSNL - shift LSN left one bit
*
* on entry:
*	X: pointer to LSN
*
*  trashes: nothing
*
*  returns: nothing
*
		export shiftLSNL
shiftLSNL	pshs	a
		
		andcc	#$fe	; clear carry

		lda	3,x
		rola
		sta	3,x

		lda	2,x
		rola
		sta	2,x

		lda	1,x
		rola
		sta	1,x

		lda	,x
		rola
		sta	,x
		
		puls	a,pc

		end section
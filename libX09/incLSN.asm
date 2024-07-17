		section code

*******************************************************************
* incLSN - increment a LSN by one
*
* on entry:
*	X: pointer to LSN

*
*  trashes: nothing
*
*  returns: nothing
*
		export	incLSN
incLSN		pshs	a,b

		lda	3,x
		inca
		sta	3,x
		bne	Done
; overflow in byte 0
		lda	2,x
		inca
		sta	2,x
		bne	Done
; overflow in byte 1
		lda	1,x
		inca
		sta	1,x
		bne	Done
; overflow in byte 2
		lda	,x
		inca
		sta	,x
Done		puls	a,b,pc

		end section
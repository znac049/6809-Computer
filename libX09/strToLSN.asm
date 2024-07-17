		import charToHex
		import clearLSN
		import shiftLSNL

		section code

*******************************************************************
* strToLSN - convert string to LSN
*
* on entry: 
*	X: pointer to LSN
*	Y: pointer to string
*	A: max number of chars to convert. If zero, keep going
*		until non convertable character found
*
*  trashes: nothing
*
*  returns: nothing
*
*
*  returns: A - number of characters converted
*
		export strToLSN
strToLSN	pshs	x,y,b
		pshs	a		; The two pushes are deliberate

		lbsr	clearLSN	; reset the LSN to 0
		ldb	#0		; char count

Next		lda	,y+		; grab the next char in the string
		exg	a,b
		lbsr	charToHex
		exg	a,b
		bcs	notHex
* valid conversion - shift it into the LSN
  		lbsr	shiftLSNL
		lbsr	shiftLSNL
		lbsr	shiftLSNL
		lbsr	shiftLSNL
		ora	3,x
		sta	3,x

		addb	#1

		tst	,s		; Did we specify a max ?
		beq	Next		; No max - try for another

		cmpb	,s		; have we converted the max?
		bne	Next		; No, try for another
notHex		puls	a
		puls	x,y,b,pc

		end section
;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; block_numbers.s - helper functions to manipulate disk block
; 	numbers. Block numbers are 24-bit so there's no simple way 
;	to do maths on them in the 6809. The 6309 supports a single
;	32-bit register which may prove useful. Whichever processor
;	is used, we will store them as 32-bit numbers
;


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
clearLSN	pshs	d
		ldd	#0
		std	,x
		std	2,x
		puls	d,pc


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


*******************************************************************
* atoq - convert string to LSN
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

atoq		pshs	x,y,b
		pshs	a		; The two pushes are deliberate

		bsr	clearLSN	; reset the LSN to 0
		ldb	#0		; char count

atoq_Next
		lda	,y+		; grab the next char in the string
		exg	a,b
		lbsr	charToHex
		exg	a,b
		bcs	atoq_notHex
* valid conversion - shift it into the LSN
  		bsr     shiftLSNL
		bsr	shiftLSNL
		bsr	shiftLSNL
		bsr	shiftLSNL
		ora	3,x
		sta	3,x

		addb	#1

		tst	,s		; Did we specify a max ?
		beq	atoq_Next	; No max - try for another

		cmpb	,s		; have we converted the max?
		bne	atoq_Next	; No, try for another

atoq_notHex
		puls	a
		puls	x,y,b,pc



*******************************************************************
* pLSN - print a long (32-bit) number
*
* on entry:
*	X: pointer to LSN
*
*  trashes: nothing
*
*  returns: nothing
*

putLSN		pshs	d

		ldd	,x
		lbsr	putHexWord
		ldd	2,x
		lbsr	putHexWord

		puls	d,pc




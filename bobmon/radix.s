;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;

*******************************************************************
* printNum - print a number in the current radix, using just as
*	much space as is needed.
*
* on entry: 
*	D: the 16-bit number to print
*
*  trashes: nothing
*
*  returns: nothing
*
printNum	pshs	a,b,x,y

		* mLocals	20		; Reserve 20 bytes of temp stack space
		* tfr	u,y
		leas	-18,s		; Temp buffer
		tfr	s,y
		
		pshs	d
		lda	g.radix
		cmpa	#2
		beq	pnIsBin
		cmpa	#16
		beq	pnIsHex

; decimal	
		puls	d
		tfr	y,x
		lbsr	binToDec
		bra	pnOutput

; binary
pnIsBin		puls	d
		tfr	y,x
		lbsr	binToBin
		bra	pnOutput

; hex
pnIsHex		puls	d
		tfr	y,x
		bsr	binToHex

pnOutput	ldb	,y+		; character count
dloop		lda	,y+
		lbsr	putChar
		decb
		bne	dloop

		* mFreeLocals
		leas	18,s		; free up the temporary buffer
		puls	a,b,x,y,pc


*
* Conversion functions
*

*******************************************************************
* binToHex - convert a 16-bit number to a hexadecimal ascii string
*
* on entry: 
*	D: the 16-bit number to convert
*	X: address of the buffer to write to
*
*  trashes: nothing
*
*  returns: nothing
*
binToHex	pshs	d,x,y

		tfr	x,y
		leax	1,x
		clr	,y		; Set count to zero
		
		cmpd	#0
		beq	bthZero		; Special case

		tsta
		beq	bthLowByte

; Upper byte
		pshs	a
		lsra
		lsra
		lsra
		lsra
		bsr	binToHexDigit
		puls	a
		anda	#$0f
		bsr	binToHexDigit

; Lower byte
bthLowByte	tfr	b,a
		pshs	a
		lsra
		lsra
		lsra
		lsra
		bsr	binToHexDigit
		puls	a
		anda	#$0f
		bsr	binToHexDigit
		bra	bthDone

bthZero		inc	,y
		lda	#'0'
		sta	,x

bthDone		puls	d,x,y,pc


*******************************************************************
* binToBin - convert a 16-bit number to a binary ascii string
*
* on entry: 
*	D: the 16-bit number to convert
*	X: address of the buffer to write to
*
*  trashes: nothing
*
*  returns: nothing
*
binToBin	pshs	d,x,y
		
		tfr	x,y
		leax	1,x
		clr	,y		; Set count to zero
		
		cmpd	#0
		beq	bthZero		; Special case

		bsr	binToBinDigits
		tfr	b,a
		bsr	binToBinDigits
		bra	btbDone

btbZero		inc	,y
		lda	#'z'
		sta	,x
btbDone		puls	d,x,y,pc



*******************************************************************
* binToHexDigit - convert a 4-bit number to a hexadecimal ascii string
*
* on entry: 
*	A: the 4-bit number to convert (lower 4 bits)
*	X: the buffer to put the character into
*	Y: Address of the count byte
*
*  trashes:
*	X: gets incremented if a character was written, otherwise unchanged.
*
*  returns: nothing
*
binToHexDigit	pshs	a

		anda	#$0f
		
		tsta
		bne	bthdMustPrint

; The value is zero. We can skip it if it's a leading zero
		tst	,y
		beq	bthdDone	; It's a leading zero

bthdMustPrint	cmpa	#10
		bge	bthdLetter

		adda	#'0'
		bra	bthdStash

bthdLetter	suba	#10
		adda	#'a'

bthdStash	sta	,x+
		inc	,y

bthdDone	puls	a,pc


*******************************************************************
* binToBinDigits - convert an 8-bit number to a binary ascii string
*
* on entry: 
*	A: the 8-bit number to convert
*	X: the buffer to put the character into
*	Y: Address of the count byte
*
*  trashes:
*	X: gets incremented if characters were written, otherwise unchanged.
*
*  returns: nothing
*
binToBinDigits	pshs	b		; Do not combine, the push order
		pshs	a		; is important

		ldb	#$80		; Top bit of byte
		pshs	b
btbdLoop	andb	1,s
		bne	btbdOne

		tst	,y		; Ignore if a leading zero
		beq	btbdShift
		lda	#'0'
		bra	btbdNext
		
btbdOne		lda	#'1'

btbdNext	sta	,x+		; Output digit
		inc	,y		; bump length
btbdShift	ldb	,s
		lsrb
		stb	,s
		tstb
		bne	btbdLoop

		puls	b
		puls	a		; Do not combine, the pull order
		puls	b,pc		; is important
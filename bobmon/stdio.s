;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; stdio.s - generic input and output io_functions.
;	Note. All functions either read or write from/to the
;	currently selected character device.
;

		globals

g.unprintable	rmb	1
g.upperNibble	rmb	1

		code

*******************************************************************
* putChar - write a character
*
* on entry: 
*	A: character to write
*
*  trashes: nothing
*
*  returns: nothing
*
putChar		pshs	b,x
		cmpa	#CR
		bne	pcNoCR
		ldb	#1		; Reset column number
		stb	current_column

pcNoCR		cmpa	#SPACE
		blt	pcNoInc
		cmpa	#DEL
		bge	pcNoInc
		ldb	#1
		addb	current_column
		stb	current_column

pcNoInc		ldx	g.currentCDev,pcr
		jsr	[CDev.Write,x]
		puls	b,x,pc


*******************************************************************
* putPrintableChar - write a character. Non printable chars will 
*		use a printable character instead (default: <space>)
*
* on entry: 
*	A: character to write
*
*  trashes: nothing
*
*  returns: nothing
*
putPrintableChar
		pshs	a
		cmpa	#SPACE
		blt	ppcNope
		cmpa	#127
		blt	ppcOk
ppcNope		lda	g.unprintable	; Use a special char to
					; indicate non-printable char
ppcOk		bsr	putChar
		puls	a,pc


*******************************************************************
* putStr - write an EOS terminated string
*
* on entry: 
*	X: address of string to print
*
*  trashes: nothing
*
*  returns: nothing
*
putStr		pshs	a,x,cc
1		lda	,x+
		beq	2F
		bsr	putChar
		bra	1B
2		puls	a,x,cc,pc

		
*******************************************************************
* putHexWord - print a 16-bit number as a hex number (4 digits)
*
* on entry: 
*	D: The number to print
*
*  trashes: nothing
*
*  returns: nothing
*
putHexWord	pshs	a,b
		bsr	putHexByte
		exg	a,b
		bsr	putHexByte
		puls	a,b,pc


*******************************************************************
* putHexByte - print an 8-bit number as a hex number (2 digits)
*
* on entry: 
*	A: The number to print
*
*  trashes: nothing
*
*  returns: nothing
*
putHexByte	pshs	a,cc
		rora
		rora
		rora
		rora
		bsr	putHexDigit
		rora
		rora
		rora
		rora
		rora	; rotate through carry bit
		bsr	putHexDigit
		puls	a,cc,pc


*******************************************************************
* putHexDigit - print a 4-bit number as a hex number
*
* on entry: 
*	A: The number to print (bottom 4 bits)
*
*  trashes: nothing
*
*  returns: nothing
*
putHexDigit	pshs	a,cc
		anda	#$0f
		adda	#'0'
		cmpa	#'9'
		ble	1F
		adda	#$27
1		bsr	putChar
		puls	a,cc
		rts

*******************************************************************
* putNL - print a Newline
*
* on entry: nothing
*
*  trashes: nothing
*
*  returns: nothing
*

putNL		pshs	x
		leax	1F,pcr
		lbsr	putStr
		puls	x,pc

1		fcn	CR,LF


*******************************************************************
* putnStr - print a string of a given length
*
* on entry: 
*	X: The string to print
*	B: The number of character to print
*
*  trashes: nothing
*
*  returns: nothing
*
putnStr		pshs	a,b,x

		cmpb    #0
		beq     pnStrEnd
            
pnStrNext	lda	,x+

		lbsr	putChar
		decb
		beq     pnStrEnd
		bra	pnStrNext

pnStrEnd 	puls	a,b,x,pc


*******************************************************************
* putnpStr - print a string of a given length, substituting
*	non-printables
*
* on entry: 
*	X: The string to print
*	B: The number of character to print
*
*  trashes: nothing
*
*  returns: nothing
*
putnpStr	pshs	a,b,x

		tstb
		beq     pnpStrEnd
            
1		lda	,x+
		bsr	putPrintableChar
		decb
		beq     pnpStrEnd
		bra	1B

pnpStrEnd 	puls	x,b,a,pc


*******************************************************************
* padToCol - move the cursor to a given column #. If we are beyond
*	that column on the current line, write a newline and then 
*	move to the indicated column
*
* on entry: 
*	A: The column # to move to
*
*  trashes: nothing
*
*  returns: nothing
*
padToCol	pshs	a,b
		tfr	a,b
		cmpb	current_column
		bpl	ptcJustPad
		lbsr	putNL			; Gone past the column, so start a new line

ptcJustPad	lda	g.unprintable
		lbsr	putChar
		cmpb	current_column
		bne	ptcJustPad

		puls	a,b,pc


*******************************************************************
* getChar - read (wait if necessary) a character. If a linefeed
*	is read, ignore it.
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	A: the character we read
*
getChar		pshs	x
		ldx	g.currentCDev,pcr
1		jsr	[CDev.Read,x]
		cmpa	#LF
		beq	1B
		puls	x,pc


*******************************************************************
* getChar - read (wait if necessary) a character and convert 
*	uppercase to lower.
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	A: the character we read
*
getLChar	lbsr	getChar
		cmpa	#'A'
		blt	1F
		cmpa	#'Z'
		bgt	1F
		ora	#$60
1		rts


*******************************************************************
* getHexDigit - read (wait if necessary) a character and convert it's
*	ASCII value to it's hexadecimal equivalent
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	A: the character we read
*
getHexDigit	bsr	getLChar
		cmpa	#'0'
		blt	1F
		cmpa	#'9'
		bgt	2F
		suba	#'0'
		bra	3F

2		cmpa	#'a'
		blt	1F
		cmpa	#'f'
		bgt	1F
		suba	#'a'
		adda	#10
3		bra	4F

1		lda	#$ff
4		rts


*******************************************************************
* getHexByte - read (wait if necessary) two characters and treat them
*	as hexadecimal
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	A: the hex value
*
getHexByte	lbsr	getHexDigit
		lsla
		lsla
		lsla
		lsla
		sta	g.upperNibble
		lbsr	getHexDigit
		adda	g.upperNibble
		rts

*******************************************************************
* getHexWord - read (wait if necessary) four characters and treat them
*	as hexadecimal
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	D: the hex value
*
getHexWord	bsr	getHexByte
		tfr	a,b
		bsr	getHexByte
		exg	a,b
		rts




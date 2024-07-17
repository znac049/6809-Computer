		import	g.radix
		
		import 	binToBin
		import 	binToDec
		import 	binToHex
		import	putChar

		section code

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
		export	printNum
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
		lbsr	binToHex

pnOutput	ldb	,y+		; character count
dloop		lda	,y+
		lbsr	putChar
		decb
		bne	dloop

		* mFreeLocals
		leas	18,s		; free up the temporary buffer
		puls	a,b,x,y,pc

		end section
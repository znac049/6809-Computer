;--------------------------------------------------------
;
; io_functions.s - generic input and output io_functions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

putChar		pshs	b
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

pcNoInc		puls	b
		jmp	[putChar_fn]


getChar		jmp	[getChar_fn]



putPrintableChar
		pshs	a
		cmpa	#SPACE
		blt	ppcNope
		cmpa	#127
		blt	ppcOk
ppcNope		lda	#SPACE
ppcOk		lbsr	putChar
		puls	a,pc


putStr		pshs	a,x,cc
1		lda	,x+
		beq	2F
		bsr	putChar
		bra	1B
2		puls	a,x,cc,pc


		
putHexWord	pshs	a,b
		bsr	putHexByte
		exg	a,b
		bsr	putHexByte
		puls	a,b,pc


putHexByte	pshs	cc
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
		puls	cc
		rts

putHexDigit	pshs	a,cc
		anda	#$0f
		adda	#'0'
		cmpa	#'9'
		ble	1F
		adda	#$27
1		bsr	putChar
		puls	a,cc
		rts

putNL		pshs	x
		leax	1F,pcr
		lbsr	putStr
		puls	x,pc

1		fcn	CR,LF


putnStr		pshs	a

		cmpb    #0
		beq     pnStrEnd
            
pnStrNext	lda	,x+

		lbsr	putChar
		decb
		beq     pnStrEnd
		bra	pnStrNext

pnStrEnd 	puls	a,pc


putnpStr	pshs	a,b,x

		tstb
		beq     pnpStrEnd
            
1		lda	,x+
		bsr	putPrintableChar
		decb
		beq     pnpStrEnd
		bra	1B

pnpStrEnd 	puls	x,b,a,pc


getLChar	lbsr	getChar
		cmpa	#'A'
		blt	1F
		cmpa	#'Z'
		bgt	1F
		ora	#$60
1		rts

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

getHexByte	lbsr	getHexDigit
		lsla
		lsla
		lsla
		lsla
		sta	upper_nibble
		lbsr	getHexDigit
		adda	upper_nibble
		rts

getHexWord	bsr	getHexByte
		tfr	a,b
		bsr	getHexByte
		exg	a,b
		rts



padToCol	pshs	a,b
		tfr	a,b
		cmpb	current_column
		bpl	ptcJustPad
		lbsr	putNL			; Gone past the column, so start a new line

ptcJustPad	lda	#SPACE
		lbsr	putChar
		cmpb	current_column
		bne	ptcJustPad

		puls	a,b,pc
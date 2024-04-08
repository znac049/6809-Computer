;--------------------------------------------------------
;
; io_functions.s - generic input and output io_functions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

putChar		pshs	b
		cmpa	#CR
		bne	pcNoCR
		clrb				; Reset column number
		stb	current_column
pcNoCR		ldb	#1
		addb	current_column
		stb	current_column

		puls	b
		jmp	[putChar_fn]

getChar		jmp	[getChar_fn]

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
		blt	ptcJustPad
		lbsr	putNL			; Gone past the column, so start a new line

		lda	#SPACE
		subb	current_column	
ptcJustPad	lbsr	putChar
		decb
		bne	ptcJustPad

		puls	a,b,pc
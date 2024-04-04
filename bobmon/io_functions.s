;--------------------------------------------------------
;
; io_functions.s - generic input and output io_functions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

putChar		jmp	[putChar_fn]

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

putstr		pshs	a,x,cc
putstr_loop	lda	,x+
		beq	putstr_done
		bsr	putchar
		bra	putstr_loop
putstr_done	puls	a,x,cc
		rts

puthexbyte	pshs	cc
		rora
		rora
		rora
		rora
		bsr	puthexdigit
		rora
		rora
		rora
		rora
		rora	; rotate through carry bit
		bsr	puthexdigit
		puls	cc
		rts

puthexdigit	pshs	a,cc
		anda	#$0f
		adda	#'0'
		cmpa	#'9'
		ble	_puthexdigit1
		adda	#$27
_puthexdigit1	bsr	putchar
		puls	a,cc
		rts

putchar		pshs	a
_putchar1	lda	uart
		bita	#$02
		beq	_putchar1
		puls	a
		sta	uart+1
		rts

putnl		pshs	x
		leax	1F,pcr
		lbsr	putstr
		puls	x,pc

1		fcn	13,10

getchar		lda	uart
		bita	#$01
		beq	getchar
		lda	uart+1
		rts

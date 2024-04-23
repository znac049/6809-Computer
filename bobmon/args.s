;
; makeArgs
;
; Called with:
;	X - the string to search
;
; Modifies:
;	argc - set to the number of arguments
;	argv - populated with pointers to the args (up to MAX_ARGS)
;
; Returns:
;	A - the number of args
;
makeArgs	pshs	x,y,b
		clra
		sta	g.argc
		leay	g.argv,pcr


; Skip any whitespace before the arg
maSkipWhite	lbsr	skipWhite
		lda	,x		; At EOS?
		beq	maDone

; Now we're pointing at a non-white
maNonWhite	stx	,y++		; Save ptr to arvc[n]	
		lda	g.argc		; Bump argc
		inca
		sta	g.argc

; skip over the arg
maSkipArg	ldb	,x+
		beq	maDone
		cmpb	#CR
		beq	maEndArg
		cmpb	#SPACE
		beq	maEndArg
		cmpb	#TAB
		beq	maEndArg
		bra	maSkipArg

maEndArg	clra
		sta	-1,x
		bra	maSkipWhite	; Look for the next arg

maDone		lda	g.argc
		puls	x,y,b,pc

;
; dumpArgs
;
dumpArgs	pshs	a,x,y
		lbsr	putNL
		leax	da_msg_1,pcr
		lbsr	putStr
		lda	g.argc
		lbsr	putHexByte
		lbsr	putNL
		
		leay	g.argv,pcr
		
daPrNextArg	ldx	,y++
		lbsr	putStr
		lbsr	putNL
		deca
		bne	daPrNextArg
	
		puls	a,x,y,pc


da_msg_1	fcn	"ARGC="


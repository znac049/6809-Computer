;--------------------------------------------------------
;
; string_functions.s - string functions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;


;
; isBlankLine
;
; Called with:
;	X - the string to search
;
; Returns:
;	A - 0=not blank, 1=blank
;
isBlankLine	pshs	x
iblNext		lda	,x+
		beq	iblEOL
		cmpa	#SPACE
		beq	iblNext
		cmpa	#TAB
		beq	iblNext
		cmpa	#CR
		beq	iblNext
		lda	#0
		bra	iblDone
iblEOL		lda	#1
iblDone		puls	x,pc

;
; skipWhite
;
; Called with:
;	X - String
;
; Returns
;	X - Ptr to first non-white (or EOS)
;
skipWhite	pshs	a
swLoop		lda	,x
		beq	swEOS
		cmpa	#CR
		beq	swEOL
		cmpa	#LF
		beq	swEOL
		cmpa	#SPACE
		beq	swNext
		cmpa	#TAB
		beq	swNext
		bra	swEOS

swNext		leax	1,x
		bra	swLoop

swEOL
swEOS		puls	a,pc

;
; charToHex
;
; Call with:
; 	A - character to convert
;
; Returns:
;	A - converted character
;
charToHex	cmpa	#'0'
		blt	cthErr
		cmpa	#'9'
		bgt	cthNotNum
		suba	#'0'
		bra	cthDone

cthNotNum 	cmpa	#'A'
		blt	cthErr
		cmpa	#'F'
		bgt	cthNotUpper
		suba	#'A'
		adda	#10
		bra	cthDone

cthNotUpper	cmpa	#'a'
		blt	cthErr
		cmpa	#'f'
		bgt	cthErr
		suba	#'a'
		adda	#10

cthErr		lda	#$ff
cthDone		rts

;
; strToHexByte
;
; Call with:
; 	X - pointer to string
;
; Returns:
;	A - converted string
;	X - pointer to string after conversion
;
strToHexByte	pshs	b

		lda	,x+
		lbsr	charToHex
		tfr	a,b

		lda	,x+
		beq	sthbSingleDigit
		lbsr	charToHex
		pshs	a

		tfr	b,a
		lsla
		lsla
		lsla
		lsla
		ora	1,s
		puls	b
		bra	sthbDone

sthbSingleDigit	leax	-1,x

sthbDone	puls	b,pc
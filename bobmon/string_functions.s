*****************************************************
;
; string_functions.s - string functions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

		include	"3rdParty/lance.s"

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
; 	B - character to convert
;
; Returns:
;	B - converted character
;	CC - Carry set on error
;
charToHex	cmpb	#'0'
		blt	cthErr
		cmpb	#'9'
		bgt	cthNotNum
		subb	#'0'
		bra	cthOk

cthNotNum 	cmpb	#'A'
		blt	cthErr
		cmpb	#'F'
		bgt	cthNotUpper
		subb	#'A'
		addb	#10
		bra	cthOk

cthNotUpper	cmpb	#'a'
		blt	cthErr
		cmpb	#'f'
		bgt	cthErr
		subb	#'a'
		addb	#10
cthOk		andcc	#~1		; Clear Carry
		bra	cthDone

cthErr		orcc	#1		; Set Carry
cthDone		rts


;
; strToHex
;
; Call with:
; 	X - pointer to string
;
; Returns:
;	D - converted string
;	X - pointer to string after conversion
;	CC - Carry set on any error
;
strToHex	ldd	#0
		std	word_value

sthNext		ldb	,x
		beq	sthEnd
		cmpb	#SPACE
		beq	sthEnd
		cmpb	#CR
		beq	sthEnd
		cmpb	#LF
		beq	sthEnd

		lbsr	charToHex
		bcs	sthOverflow

		pshs	b

; We've got a valid hex digit
		ldd	word_value
		lslb
		rola
		bcs	sthOverflow
		lslb
		rola
		bcs	sthOverflow
		lslb
		rola
		bcs	sthOverflow
		lslb
		rola
		bcs	sthOverflow
		std	word_value

		puls	b
		sex

		addd	word_value
		std	word_value

		leax	1,x
		bra	sthNext

sthEnd		ldd	word_value
		andcc	#~1
		bra	sthDone

sthOverflow	ldd	word_value
		orcc	#1

sthDone		rts
;--------------------------------------------------------
;
; string_functions.s - string functions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

countArgs	pshs	b
		clra

2		ldb	,x+
		beq	1F
		cmpb	#CR
		beq	1F
		cmpb	#SPACE
		beq	2B
		cmpb	#TAB
		beq	2B

caNextArg	inca

caSkipArg	ldb	,x+
		beq	1F
		cmpb	#CR
		beq	1F
		cmpb	#SPACE
		beq	caSkipBlanks
		cmpb	#TAB
		beq	caSkipBlanks
		bra	caSkipArg

caSkipBlanks	ldb	,x+
		beq	1F
		cmpb	#SPACE
		beq	caSkipBlanks
		cmpb	#TAB
		beq	caSkipBlanks
		cmpb	#CR
		bne	caNextArg

1		sta	argc
		puls	b,pc

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

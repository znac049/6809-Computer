mLocals		macro
		tfr	s,u		; remember the old stack value
		leas	-\1,s
		pshs	u
		leau	2,u
		endm

mFreeLocals	macro
		lds	-2,u
		endm

mReturns	macro
		lds	-2,u
		rts
		endm

DbgS		macro
		pshs	a
		lda	#SPACE
		lbsr	putChar
		lda	#\1
		lbsr	putChar
		lda	#'='
		lbsr	putChar
		lda	,s
		lbsr	putHexByte
		lda	#SPACE
		lbsr	putChar
		puls	a
		endm

DbgL		macro
		pshs	d
		lda	#SPACE
		lbsr	putChar
		lda	#\1
		lbsr	putChar
		lda	#'='
		lbsr	putChar
		ldd	,s
		lbsr	putHexWord
		lda	#SPACE
		lbsr	putChar
		puls	d
		endm

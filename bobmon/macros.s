mLocals		macro
		leas	-\1,s
		pshs	s
		endm

mReturns	macro
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

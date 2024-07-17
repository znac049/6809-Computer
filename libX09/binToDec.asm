*******************************************************************
* binToDec 	Convert 16-bit signed number to ascii string
*
* on entry:
*	D: Value to convert
*	X: Output buffer address
*
*  trashes: nothing
*
*  returns: nothing
*
;	Exit:		The first byte of the buffer is the length,
;			followed by the characters
;
;	Registers Used: CC, D, X, Y
;
		section code

		export	binToDec
binToDec	pshs	d,x,y

		std	1,x		; Save data in buffer
		bpl	btdConvert	; Branch if data positive
		ldd	#0		; Else take absolute value
		subd	1,x

;
; INITIALIZE STRING LENGTH TO ZERO
;
btdConvert	clr	,x		; STRING LENGTH = 0

; Divide binary data by ten by
; subtracting powers of ten
btdDiv10	ldy	#-1000		; Start quotient at -1000

; Find number of thousands in quotient
btdThousand	leay	1000,y		; Add 1000 to quotient
		subd	#10000		; Subtract 10000 from dividend
		bcc	btdThousand	; Branch if difference still positive
		addd	#10000		; Else add back last 10000

; Find number of hundres in quotient
		leay	-100,y		; Start number of hundreds at -1
btdHundred	leay	100,y		; Add 100 to quotient
		subd	#1000		; Subtract 1000 from dividend
		bcc	btdHundred	; Branch if difference still positive
		addd	#1000		; Else add back last 1000

; Find number of tens in quotient
		leay	-10,y		; Start number of tens at -1
btdTens		leay	10,y		; Add 10 to quotient
		subd	#100		; Subtract 100 from dividend
		bcc	btdTens		; Branch if difference still positive
		addd	#100		; Else add back last 100

; Find number of ones in quotient
		leay	-1,y		; Start number of ones at -1
btdOnes		leay	1,y		; Add 1 to quotient
		subd	#10		; Subtract 10 from dividend
		bcc	btdOnes		; Branch if difference still positive
		addd	#10		; Else add back last 10
		stb	,-s		; Save the remainder in stack (BG: why not use pshs??)
					; THIS IS NEXT DIGIT, MOVING LEFT
					; LEAST SIGNIFICANT DIGIT GOES INTO STACK
					; FIRST
		inc	,x		; Add 1 to length byte

		tfr	y,d		; Make quotient into new dividend
		cmpd	#0		; Check if Dividend zero
		bne	btdDiv10	; Branch if not divide by 10 again

; Check if original binary data was negative
; If so, put ascii at front of buffer
		lda	,x+		; Get length byte (not including sign)
		ldb	,x		; Get high byte of data
		bpl	btdBufferLoad	; Branch if data positive
		ldb	#'-'		; Otherwise, get ascii minus sign
		stb	,x+		; Store minus sign in buffer
		inc	-2,x		; Add 1 to length byte for sign

; Move string of digits from stack to buffer
; most significant digit is at the top of stack
; Convert digits to ascii by adding ascii 0
btdBufferLoad	ldb	,s+		; Get next digit from stack, moving right
		addb	#'0'		; Convert digit to ascii
		stb	,x+		; Save digit in buffer
		deca			; Decrement byte counter
		bne	btdBufferLoad	; Loop if more bytes left
	
		puls	d,x,y,pc

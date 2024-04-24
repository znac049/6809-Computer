;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; Character device for the Motorola mc6850 uart
;

; mc6850 Uart registers
MC6850.StatusReg equ	0
MC6850.DataReg	equ	1


; divide by 16 yields 115200 with system clock of 7.37280MHz. Master Reset.
MC6850.InitialCR equ	$95			

		code
SerialDCB0	fdb	Uart0Base
		fdb	serialInit
		fdb	serialCanRead
		fdb	serialCanWrite
		fdb	serialGetChar
		fdb	serialPutChar

SerialDCB1	fdb	Uart1Base
		fdb	serialInit
		fdb	serialCanRead
		fdb	serialCanWrite
		fdb	serialGetChar
		fdb	serialPutChar


*******************************************************************
* serialInit - inititialise the device
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns: nothing
*
serialInit	pshs	a
		ldx	CDev.BaseAddr,x	
		lda	#$03			; Master reset
		sta	MC6850.StatusReg,x	
		lda	#MC6850.InitialCR
		sta	MC6850.StatusReg,x
		puls	a,pc

*******************************************************************
* serialCanRead - test to see i a character is ready to read
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns:
*	A: 0->No, 1->Yes, can read
*
serialCanRead	ldx	CDev.BaseAddr,x		
		lda	MC6850.StatusReg,x
		anda	#1			; rx register full?
		beq	scrNo
		lda	#YES
scrNo		rts


*******************************************************************
* serialCanWrite - test to see if we can safely write a character
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns:
*	A: 0->No, 1->Yes, can write
*
serialCanWrite	ldx	CDev.BaseAddr,x		
		lda	MC6850.StatusReg,x
		anda	#2			; tx register empty?
		beq	scwNo
		lda	#YES
scwNo		rts


*******************************************************************
* serialPutChar - write a character
*
* on entry: 
*	X: points to the DCB
*	A: the character to write
*
*  trashes: nothing
*
*  returns: nothing
*
serialPutChar	pshs	b
		ldx	CDev.BaseAddr,x		
1		ldb	MC6850.StatusReg,x
		bitb	#2			; tx register empty?
		beq	1B
		
		sta	MC6850.DataReg,x	; send the char

		puls	b,pc


*******************************************************************
* serialInit - inititialise the device
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns: nothing
*
serialGetChar	pshs	x
		ldx	CDev.BaseAddr,x		
1		lda	MC6850.StatusReg,x
		bita	#1			; rx register full?
		beq	1B

		lda	MC6850.DataReg,x	; grab the character

		puls	x,pc


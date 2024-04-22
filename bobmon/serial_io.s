;--------------------------------------------------------
;
; serial_io.s - i/o functions specific to the uart
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

serialInit	pshs	a,x

		ldx	#Uart0Base

		lda	#$03		; Master reset
		sta	StatusReg,x

		puls	x,a,pc

		rts

serialPutChar	pshs	b,x

		ldx	#Uart0Base

1		ldb	StatusReg,x
		bitb	#2		; tx register empty?
		beq	1B
		
		sta	DataReg,x	; send the char

		puls	x,b,pc

serialGetChar	pshs	x

		ldx	#Uart0Base

1		lda	StatusReg,x
		bita	#1		; rx register full?
		beq	1B

		lda	DataReg,x	; grab the character

		puls	x,pc


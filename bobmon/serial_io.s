;--------------------------------------------------------
;
; serial_io.s - i/o functions specific to the uart
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

serialPutChar	pshs	a
1		lda	uart
		bita	#$02
		beq	1B
		puls	a
		sta	uart+1
		rts

serialGetChar	lda	uart
		bita	#$01
		beq	serialGetChar
		lda	uart+1
		rts

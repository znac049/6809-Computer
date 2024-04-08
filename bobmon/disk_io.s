;--------------------------------------------------------
;
; disk_io.s - simulated disk interface
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

fdc_SR		equ	fdc
fdc_CR		equ	fdc_SR
fdc_DR		equ	fdc+1
fdc_SEC2	equ	fdc+2
fdc_SEC1	equ	fdc+3
fdc_SEC0	equ	fdc+4

fdcSR_RDY 	equ	$80
fdcSR_ERR	equ	$01

dkinfo		leax	1F,pcr
		lbsr	putStr

		lda	fdc_SR
		lbsr	putHexByte

		lbsr	putNL
		
; Query each disk status
dki_wait_1	lda 	fdc_SR
		anda	#fdcSR_RDY	; Is it ready?
		beq	dki_wait_1

		lda	#$03		; Query disk 0
		sta	fdc_CR
		
dki_wait_2	lda	fdc_SR
		anda	#fdcSR_RDY
		beq	dki_wait_2

		lda	fdc_SR
		anda	#fdcSR_ERR	; Error bit set means no disk present
		lbne	dki_no_disk

		leax	3F,pcr
		lbsr	putStr

		lda	fdc_SEC2
		lbsr	putHexByte
		lda	fdc_SEC1
		lbsr	putHexByte
		lda	fdc_SEC0
		lbsr	putHexByte
		lbsr	putNL


		bra	dki_done
dki_no_disk	leax	2F,pcr
		lbsr	putStr

dki_done	rts

1		fcn	"Disk subsystem info:",CR,LF
2		fcn	"disk not present",CR,LF
3		fcc	"disk present",CR,LF
		fcn	"number of sectors: "
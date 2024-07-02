
;
; Simple 6809 Monitor
;
; Copyright(c) 2016, Bob Green
;
	
*******************************************************************
* cfWait - wait for CF to be ready
*
* on entry: X - base of CF 
*
*  trashes: A
*
*  returns: nothing
*

cfWait		lda	CF.Status,x
		anda	#$80	; Check BUSY flag
		bne	cfWait
		rts


	
*******************************************************************
* cfInit - initialise the CF subsystem
*
* on entry: none
*
*  trashes: nothing
*
*  returns: nothing
*

cfInit		pshs	a,x
		leax	CFBase,pcr
		lda	#CMD.DIAG       ; The device won't accept any other commands
					; until DIAG has been run
		sta	CF.Command,x

		lda	CF.Error,x	; Read diag status code
		cmpa	#$80		; No CF devices
		beq	noCF
		cmpa	#$01
		bne	secPres
		leax	priCFMsg,pcr
		lbsr	putStr
		bra	cfiCont

secPres		leax	secCFMsg,pcr
		lbsr	putStr
		bra	cfiCont

noCF		leax	noCFMsg,pcr
		lbsr	putStr
	
cfiCont		leax	CFBase,pcr
		bsr	cfWait

*		lda	#CMD.RESET 	; Reset
*		sta	CF.Command,x
*		bsr	cfWait

		lda	#$E0		; LBA mode, Not sure why $E0 instead of $40
		sta	CF.LSN3,x

		lda	#$01		; 8-bit transfers
		sta	CF.Features,x
		lda	#CMD.SETFEATURES
		sta	CF.Command,x
		bsr	cfWait
	
		puls	x,a,pc

	
noCFMsg		fcn	"No CF devices present\r\n"
priCFMsg	fcn	"CF #0 present\r\n"
secCFMsg	fcn	"CF #1 present\r\n"


	
*******************************************************************
* cfRead - read a single sector from disk
*
* on entry: X - Read buffer address
*
*  trashes: nothing
* 
*  returns: nothing
*

cfRead		pshs	a,x,y

		leay	CFBase,pcr

		lda	#$20	; Read sector with retry command
		sta	CF.Command,y

		bsr	cfReadBuff

		puls	y,x,a,pc


	
*******************************************************************
* cfReadBuff - read block of data from the CF device
*
* on entry: X - Read buffer address
*	    Y - Address of CF device
*
*  trashes: nothing
*
*  returns: nothing
*

cfReadBuff	pshs	a,b,x
		ldb	#0
	
cfRdNext
cfRdWait	lda	CF.Status,y
		anda	#SR.DRQMask
		beq	cfRdWait

		lda	CF.Data,y
		sta	,x+

		decb
		bne	cfRdNext

		puls	x,b,a,pc

	
	
*******************************************************************
* cfWrite - write a block of data to disk
*
* on entry: X - Write buffer address
*
*  trashes: nothing
*
*  returns: nothing
*

cfWrite		pshs	a,b,x,y

		leay	CFBase,PCR

		lda	#$30	; Write sector with retry command
		sta	CF.Command,Y

cfWrNext
cfWrWait	lda	CF.Status,Y
		anda	#$04	; DRQ -
		beq	cfWrWait

		ldb	#0	; loop counter - 256 bytes
		lda	,X+
		sta	CF.Data,Y

		decb
		bne	cfWrNext

		puls	y,x,b,a,pc

	
	
*******************************************************************
* cfSetLSN - 
*
* on entry: X - address of LSN (4 bytes)
*
*  trashes: nothing
*
*  returns: nothing
*

cfSetLSN	pshs	a,b,y

		leay	CFBase,PCR
		ldd	2,x
		stb	CF.LSN0,y
		sta	CF.LSN1,y
		ldd	,x
		stb	CF.LSN2,y
		anda	#$0f
		ora	#$40		; LBA mode, drive 0
		sta	CF.LSN3,y

		puls	y,b,a,pc

	
	
*******************************************************************
* cfInfo - get CF device info and display it
*
* on entry: none
*
*  trashes: nothing
*
*  returns: nothing
*

cfInfo		pshs	a,b,x,y
	
		ldx	#CFBase
		lbsr	cfWait
		lda	#CMD.IDENTIFY
		sta	CF.Command,x
		tfr	x,y
		ldx	#secBuff
		lbsr	cfReadBuff
		ldy	#secBuff
* Serial #
		leax	cfiSerMsg,pcr
		lbsr	putStr
		leax	20,y
		ldb	#20
		lbsr	putnpStr
		lbsr	putNL

* Firmware
		leax	cfiFWMsg,pcr
		lbsr	putStr
		leax	46,y
		ldb	#8
		lbsr	putnpStr
		lbsr	putNL

* Model #
		leax	cfiModelMsg,pcr
		lbsr	putStr
		leax	54,y
		ldb	#40
		lbsr	putnpStr
		lbsr	putNL

		puls	y,x,b,a,pc

	
	
cfiSerMsg	fcn	"  Serial: "
cfiFWMsg	fcn	"Firmware: "
cfiModelMsg	fcn	"   Model: "

















;
; Simple 6809 Monitor
;
; Copyright(c) 2016, Bob Green
;
	

;--------------------------------------------------------------------------------
; sdRdBlock - read block from the SD card
;
; on entry:
;	X - byte *buff - read buffer
;	Y - byte *LBA
;
sdRdBlock	pshs	a,x,u,y,b
	
		leau	SDBase,pcr		; base of sd controller

rdWtRdy 	ldb	SD.Status,u		; Wait for SD card to be ready
		cmpb	#128
		bne	rdWtRdy

		bsr    	setLBA
            
		lda	#00			; $00 = read block command
		sta	SD.Ctrl,u		;

		ldy	#512			; number of bytes to read

rdWait 		ldb	SD.Status,u		; Wait for byte to be available
		cmpb	#224			; Byte ready
		bne	rdWait

		lda	SD.Data,u		; read the byte

		sta	,x+			; save byte to buffer
		leay	-1,y			; y--
		bne	rdWait			; loop until 512 bytes read

		puls	b,y,u,x,a,pc		; restore regs...and return



;--------------------------------------------------------------------------------
; sdWrBlock - read block from the SD card
;
; on entry:
;	X - byte *buff - write buffer
;	Y - byte *LBA
;
; returns:
;
sdWrBlock	pshs	u,x,y,a,b

		leau	SDBase,pcr		; base of sd controller

wrWtRdy 	ldb	SD.Status,u		; Wait for SD card to be ready
		cmpb	#128
		bne	wrWtRdy

		bsr     setLBA			; specify the sector to write
		lda	#01			; $01 = write block command
		sta	SD.Ctrl,u		;

		ldy	#512			; number of bytes to read

wrWait 		ldb	SD.Status,u		; Wait for byte to be available
		cmpb	#160			; Write buffer empty
		bne	wrWait

		lda	,x+			; read the byte
		sta	SD.Data,u		; Write it

		leay	-1,y			; y--
		bne	wrWait			; loop until 512 bytes written

		puls	b,a,y,x,u,pc		; restore regs...and return


;--------------------------------------------------------------------------------
; clearLBA - reset the LBA
;
; on entry:
;	X - LBA_t*
;
; trashes: nothing
;
; returns: nothing
;
clearLBA	pshs    a

		lda     #0
		sta     ,x
		sta     1,x
		sta     2,x
		sta     3,x
                        
		puls    a,pc			; restore...and return


;--------------------------------------------------------------------------------
; setLBA - set the LBA to read/write
;
; on entry:
;	Y - byte *LBA
;
; trashes: nothing
;
; returns: nothing
;
setLBA		pshs    x,a

		leax    SDBase,pcr
		lda     3,y
		sta     SD.LBA0,x
            
		lda	2,y
		sta     SD.LBA1,x
            
		lda     1,y
		sta     SD.LBA2,x
            
		lda     #00			; SD card only uses 3 bytes of LBA
		sta     SD.LBA3,x
            
		puls    x,a,pc			; restore...and return



;--------------------------------------------------------------------------------
; LSN2LBA - convert LSN to LBA
;
; on entry:
;	X - byte *LSN
;	Y - byte *LBA
;
; trashes: nothing
;
; returns: nothing
;
LSN2LBA		pshs	a

		lda	,x
		lsra
		sta	,y

		lda	1,x
		rora
		sta	1,y

		lda	2,x
		rora
		sta	2,y

		lda	3,x
		rora
		sta	3,y		

		puls	a,pc



















;
; Simple 6809 Monitor
;
; Copyright(c) 2016, Bob Green
;
	

*******************************************************************
* dkInit - initialise the disk subsystem
*
* on entry: none
*
*  trashes: nothing
*
*  returns: nothing
*

dkInit
		rts


	
*******************************************************************
* dkReadLSN - read block of data from the CF device
*
* on entry: X - byte *rdBuff - Read buffer address
*	    Y - byte *LSN
*
*  returns: X - byte *buff
*

dkReadLSN	pshs	a,y

* Local vars
		pshs	y
		pshs	x

		tfr	y,x	; X -> LSN

		ldy	#lba.p
		lbsr	LSN2LBA

		ldx	2,s
		lbsr	putLSN
		lda	#'>'
		lbsr	putChar
		ldx	#lba.p
		lbsr	putLSN
		lbsr	putNL
		
		ldx	,s	
		ldy	#lba.p
		lbsr	sdRdBlock

* We only want half of it - os9 LSNs are 256 bytes and SD
* blocks are 512.

		ldx	,s	; X -> *buff
		ldy	2,s	; y -> LSN
		lda	3,y	; check lowest byte of LSN for odd/even
		anda	#$01
		beq	evenLSN
		leax	256,x
		andcc	#$fe	; Clear carry
evenLSN
		leas	4,s	; Ditch local vars
		puls	y,a,pc

	
	
*******************************************************************
* dkWriteLSN - write a block of data to disk
*
* on entry: X - byte *wrBuff -  Write buffer address
*    	    Y - byte *LSN
*
*  trashes: nothing
*
*  returns: nothing
*

dkWriteLSN
		rts

	
	
*******************************************************************
* dkIncLSN - Increment the LSN by 1
*
* on entry: Y - byte *LSN
*
*  trashes: nothing
*
*  returns: nothing
*

dkIncLSN	pshs	d
		ldd	2,x
		addd	#1
		std	2,x
		bne	noLSNWrap
		ldd	,x
		addd	#1
		std	,x
noLSNWrap	puls	d,pc

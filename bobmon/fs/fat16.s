;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;


		globals

g.fatBase	rmb	2
g.sectorsPerFat	rmb	2
g.RootDir	rmb	2
g.currentDir	rmb	2

		code

*******************************************************************
* fatValidDisk - check if the disk contains a valid (and
*     		compatible) filesystem
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns:
*	A: 0=Valid, 1=No device, 2=Incompatible, 3-Not a FAT16 disk
*
fatValidDisk	leax	g.LSN,pcr	; Read root block and peek inside it
		lbsr	clearLSN
		leax	g.blockBuff,pcr
		lbsr	cfRead

		ldx	#CFBase
		lda	CF.Status,x	; DRQ should be low

; Check it's FAT-16 formatted
		leax	g.blockBuff,pcr
		ldd	$1fe,x		; Boot block signature should be $55AA
		cmpd	#$55aa
		bne	fvdInvalid

		lda	$0c,x		; Bytes per sector
		cmpa	#2		; Must be 02 (512 bytes)
		bne	fvdIncompatible

		ldb	$0e,x		; Reserved sectors
		lda	$0f,x		;
		std	g.fatBase,pcr

		ldb	$16,x		; Sectors per FAT
		lda	$17,x		;	
		std	g.sectorsPerFat,pcr

; Calculate the starting block of the various areas
		clra
		ldb	$10,x		; Number of FATs
		tfr	d,y		; Y is our counter

		ldd	g.fatBase,pcr
1		addd	g.sectorsPerFat,pcr
		leay	-1,y
		bne	1B
		std	g.RootDir,pcr
		std	g.currentDir,pcr

		bra	fvdOK

fvdInvalid	lda	#3		; Not FAT16
		bra	fvdDone

fvdIncompatible	lda	#2		; Incompatible FAT16
		bra	fvdDone

fvdNoDev	lda	#1		; No disk
		bra	fvdDone

fvdOK		clra

fvdDone		rts


*******************************************************************
* fatRewindDir - 
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns:
*	A: 0=Valid, 1=No device, 2=Incompatible, 3-Not a FAT16 disk
*




*******************************************************************
* fatNextDirEnt -
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns:
*	A: 0=Valid, 1=No device, 2=Incompatible, 3-Not a FAT16 disk
*

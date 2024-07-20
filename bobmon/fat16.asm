;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;

		include "constants.s"
		include "devices.s"

		import	g.blockBuff
		import	g.LSN

		import	putChar
		import	putStr
		import	putNL
		import	putHexWord
		import	strToUpper
		import	cfRead
		import 	clearLSN
		import 	copyLSN
		import	incLSN
		import 	cfSetLSN

		section globals

g.fatBase	rmb	2
g.sectorsPerFat	rmb	2
g.rootDir	rmb	4
g.currentDir	rmb	4
g.dirBlock	rmb	4

		export	g.currentDirEnt
g.currentDirEnt	rmb	2

		section code

*******************************************************************
* fatValidDisk - check if the disk contains a valid (and
*     		compatible) filesystem
*
* on entry: 
*
*  trashes: nothing
*
*  returns:
*	A: 0=Valid, 1=No device, 2=Incompatible, 3-Not a FAT16 disk
*
		export	fatValidDisk
fatValidDisk	pshs	x,y,u,b

		leax	g.LSN,pcr	; Read root block and peek inside it
		lbsr	clearLSN
		leax	g.currentDir,pcr
		lbsr	clearLSN
		leax	g.rootDir,pcr
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
addFATLen	addd	g.sectorsPerFat,pcr
		leay	-1,y
		bne	addFATLen
		leax	g.currentDir,pcr
		leau	g.rootDir,pcr
		std	2,u
		std	2,x
		clra
		clrb
		std	,u
		std	,x

		bra	fvdOK

fvdInvalid	lda	#3		; Not FAT16
		bra	fvdDone

fvdIncompatible	lda	#2		; Incompatible FAT16
		bra	fvdDone

fvdNoDev	lda	#1		; No disk
		bra	fvdDone

fvdOK		clra

fvdDone		puls	x,y,u,b,pc


*******************************************************************
* fatRewindDir - 
*
* on entry: 
*
*  trashes: nothing
*
*  returns:
*	A: 0=OK, 1=Error
*
		export	fatRewindDir
fatRewindDir	pshs	x
		ldx	#g.currentDir
		ldy	#g.dirBlock
		lbsr	copyLSN
		tfr	y,x
		lbsr	cfSetLSN

		ldx	#g.blockBuff
		stx	g.currentDirEnt
		lbsr	cfRead

		tsta			; Has anything gone wrong?
		beq	frdOK

; something went wrong
		lda	#1

frdOK		puls	x,pc


*******************************************************************
* fatNextDirEnt -
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns:
*	A: 0=OK, 1=No more entries
*
		export	fatNextDirEnt
fatNextDirEnt	pshs	x

		* lbsr	fatDumpInfo

		ldx	g.currentDirEnt
		leax	32,x		; Dir entry is 32 bytes long
		cmpx	#g.blockBuff+512
		bne	fndSame
; We've hit the end of that block, need to read the next
		ldx	#g.dirBlock
		lbsr	incLSN
		lbsr	cfSetLSN

		ldx	#g.blockBuff
		lbsr	cfRead

		tsta
		bne	fndNoMore
fndSame		stx	g.currentDirEnt

		lda	,x
		beq	fndNoMore
		clra
		bra	fndDone
fndNoMore	lda	#1

fndDone		puls	x,pc


*******************************************************************
* fatPrintDirEnt -
*
* on entry: 
*
*  trashes: nothing
*
*  returns:
*	A: 0=Valid, 1=No device, 2=Incompatible, 3-Not a FAT16 disk
*
		export fatPrintDirEnt
fatPrintDirEnt	pshs	a,b,x

		ldx	g.currentDirEnt
		lda	11,x		; Attribute byte
		cmpa	#$0f		; Extended filename? Ignore
		beq	fpdDone
		anda	#$08		; Volume label? Ignore
		bne	fpdDone

		ldb	#11		; 8.3
fpd1		lda	,x+
		cmpa	#SPACE
		beq	fpdSuffix
; Do we need to print a dot?
		cmpb	#3
		bne	fpdNoDot

		pshs	a
		lda	#'.'
		lbsr	putChar
		puls	a
fpdNoDot	lbsr	putChar	
fpdSuffix	decb
		bne	fpd1

		lda	,x		; Attribute byte
		anda	#$10
		beq	fpdNotDir

		lda	#'/'
		lbsr	putChar
		
fpdNotDir	lbsr	putNL

fpdDone		puls	a,b,x,pc


*******************************************************************
* fatDumpInfo
*
* on entry: 
*
*  trashes: nothing
*
*  returns: nothing
*
		export	fatDumpInfo
fatDumpInfo	pshs	a,b,x
		leax	fdi_msg_1,pcr
		lbsr	putStr
		ldd	g.fatBase
		lbsr	putHexWord

		leax	fdi_msg_2,pcr
		lbsr	putStr
		ldx	#g.rootDir
		ldd	,x
		lbsr	putHexWord
		ldd	2,x
		lbsr	putHexWord

		leax	fdi_msg_3,pcr
		lbsr	putStr
		ldx	#g.currentDir
		ldd	,x
		lbsr	putHexWord
		ldd	2,x
		lbsr	putHexWord

		leax	fdi_msg_4,pcr
		lbsr	putStr
		ldx	#g.dirBlock
		ldd	,x
		lbsr	putHexWord
		ldd	2,x
		lbsr	putHexWord

		leax	fdi_msg_5,pcr
		lbsr	putStr
		ldd	g.currentDirEnt
		lbsr	putHexWord

		lbsr	putNL
		puls	a,b,x,pc

fdi_msg_1	fcn	"FAT Base:"
fdi_msg_2	fcn	"\r\nRoot LSN:"
fdi_msg_3	fcn	"\r\nCurrent dir LSN:"
fdi_msg_4	fcn	"\r\nDir block LSN:"
fdi_msg_5	fcn	"\r\nCurrent DirEnt:"


*******************************************************************
* fatPackFileName - convert a file name string to 8.3 format
*
* on entry: 
*	X - address of the string
*
*  trashes: nothing
*
*  returns: nothing
*

		section globals

g.fatFileName	rmb	11		; Space to hold an 8.3 filename

		section code

		export	fatPackFileName
fatPackFileName	pshs	a,b,x,y
		lbsr	strToUpper
		ldy	#g.fatFileName
		lda	#SPACE
		ldb	#11
blankNext	sta	,y+		; Initialise to all spaces
		decb
		bne	blankNext
		
		ldy	#g.fatFileName
		ldb	#8

packNextName	lda	,x+
		tsta
		beq	fpfDone
		cmpa	#'.'
		beq	fpfDot
		sta	,y+
		decb
		bne	packNextName
		
fpfDot		ldy	#g.fatFileName+8
		ldb	#3
		
packNextSuff	lda	,x+
		tsta
		beq	fpfDone
		sta	,y+
		decb
		bne	packNextSuff
		

fpfDone		puls	a,b,x,y,pc

		end section
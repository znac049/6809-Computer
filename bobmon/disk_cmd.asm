;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; disk_cmds.s - 
;
		include "constants.s"
		include "devices.s"

		import	g.currentDirEnt

		import	fatNextDirEnt
		import	fatValidDisk
		import	fatRewindDir
		import	fatPrintDirEnt
		import	cfInit
		import	putStr
		import	putNL
		import	putHexWord

		section code

		export	diskCommand
		export  diskHelp
diskCommand	fcn	"disk"
diskHelp	fcn	"\tDisk stuff!"


*******************************************************************
* diskFn - called by the command processor when the "disk" 
*	command is entered.
*
* on entry: nothing:
*
*  trashes: potentially everything (the command processor asumes this)
*
*  returns: nothing
*
		export	diskFn
diskFn		ldx	#CFBase
		lbsr	cfInit			; Initialise CF subsystem
		lbsr	fatValidDisk		; do we have a valid FAT16 disk in drive 0?

		cmpa	#1
		beq	ddiNoDisk
		cmpa	#3
		beq	ddiNotFat
		tsta
		bne	ddiIncompatible

; We have a valid FAT16 disk
		leax	ddiValid_msg,pcr
		bra	ddiMsg

ddiNoDisk	leax	ddiNoDisk_msg,pcr
		bra	ddiMsg

ddiIncompatible	leax	ddiBadRoot_msg,pcr
		bra	ddiMsg

ddiNotFat	leax	ddiNotFat_msg,pcr

ddiMsg		lbsr	putStr
		lbsr	putNL

		lbsr	fatRewindDir
		tsta
		bne	ddiDone

ddiPrEnt	lbsr	fatPrintDirEnt

		leay	ddiBootName,pcr
		ldx	g.currentDirEnt
; Look for the boot file
		ldb	#11
		
cmpNextChar	lda	,x+
		cmpa	,y+
		bne	noMatch
		decb
		bne	cmpNextChar

; File name matches
		leax	ddiFound_msg,pcr
		lbsr	putStr

		ldx	g.currentDirEnt
		ldd	30,x
		beq	bfSizeOK

		leax	ddiSize_msg,pcr
		lbsr	putStr
		bra	ddiDone
		
bfSizeOK	tfr	x,u
		leax	ddiFileSize_msg,pcr
		lbsr	putStr
		ldd	28,u
		exg	a,b
		lbsr	putHexWord
		leax	ddiFileSize_msg2,pcr
		lbsr	putStr
		
		leax	ddiCluster_msg,pcr
		lbsr	putStr
		ldd	26,u
		exg	a,b
		lbsr	putHexWord
		lbsr	putNL

		bra	ddiDone
noMatch		lbsr	fatNextDirEnt
		tsta
		beq	ddiPrEnt

ddiDone		rts

ddiValid_msg	fcn	"Valid FAT-16 disk#0 present"
ddiBadRoot_msg	fcn	"Disk#0 is FAT-16 but not a compatible flavour"
ddiNoDisk_msg	fcn	"No disk#0 found"
ddiNotFat_msg	fcn	"Disk#0 does not contain a FAT-16 filesystem"
ddiBlockBuff_msg fcn	"Block buffer address: "
ddiFound_msg	fcn	"Found boot file!\r\n"
ddiSize_msg	fcn	"Boot file is larger than 64k\r\n"
ddiFileSize_msg	fcn	"Loading "
ddiFileSize_msg2 fcn	" bytes from disk\r\n"
ddiCluster_msg	fcn	"Starting cluster: "

ddiBootName	fcc	"HELLO   BIN"

		end section
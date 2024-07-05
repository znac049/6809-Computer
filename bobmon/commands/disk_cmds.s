;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; disk_cmds.s - 
;

diskMinArgs	equ	0
diskMaxArgs	equ	0

diskCommand	fcn	"disk"
diskHelp	fcn	TAB,"Disk stuff!"


*******************************************************************
* doDisk - called by the command processor when the "disk" 
*	command is entered.
*
* on entry: nothing:
*
*  trashes: potentially everything (the command processor asumes this)
*
*  returns: nothing
*
doDisk		ldx	#CFBase
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

ddiDone		rts

ddiValid_msg	fcn	"Valid FAT-16 disk#0 present"
ddiBadRoot_msg	fcn	"Disk#0 is FAT-16 but not a compatible flavour"
ddiNoDisk_msg	fcn	"No disk#0 found"
ddiNotFat_msg	fcn	"Disk#0 does not contain a FAT-16 filesystem"

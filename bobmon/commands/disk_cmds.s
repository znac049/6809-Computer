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

		globals

g.blockBuff	rmb	256


		code

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
doDisk		clra	
		ldy	#VDiskBase
		sta	VD.Sec0,y
		sta	VD.Sec1,y
		sta	VD.Sec2,y
		
		* lbsr	vdWaitBusy	; Wait for controller
		
		lda	#$02		; Read from drive 0
		sta	VD.CMD,y
		* lbsr	vdWaitBusy

		
		leax	g.blockBuff,pcr

1		lda	VD.SR,y
		anda	#$02		; Wait for RDA
		beq	1B
		ldb	#255
		
2		lda	VD.DR,y
		sta	,x+
		decb
		bne	2B
		
		leax	read_msg,pcr
		lbsr	putStr
		ldd	#g.blockBuff
		lbsr	putHexWord
		lbsr	putNL

		rts

read_msg	fcn	"Block read into $"
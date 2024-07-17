;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;

		include "constants.s"
		include "devices.s"

		import 	SerialDCB0

		import 	putChar
		import	putStr
		import	putHexWord
		import 	putNL

; The first character device will be assumed to be the console. Unusual
; things(tm) may happen if it isn't
		section globals

		export	g.currentCDev
g.currentCDev	rmb	2

		section code

CharDevices	fdb	SerialDCB0
		* fdb	SerialDCB1
		fdb	0

BlockDevices	* fdb	VDiskDCB
		fdb	0


*******************************************************************
* preInitConsole 	Initialise *JUST* the first character device
*
* on entry: none
*
*  trashes: nothing
*
*  returns: nothing
*
		export preInitConsole
preInitConsole	pshs	x,y
		leay	CharDevices,pcr

		ldx	,y			; The first char dev becomes the console
		stx	g.currentCDev,pcr

		ldx	,y
		lbsr	initDevice

		puls	x,y,pc


*******************************************************************
* InitDevices 	Initialise all known character and block devices
*		with the exception of the first character device
*		which should have been initialised earlier on
*
* on entry: none
*
*  trashes: nothing
*
*  returns: nothing
*
		export	initDevices
initDevices	pshs	x,y
		leay	CharDevices,pcr

		leay	2,y		; Start with the second char device as 
					; the first has already been dealt with
idCharDevs	ldx	,y
		beq	idCharDevsDone
		
		clrb
		lbsr	initDevice

		leay	2,y
		bra	idCharDevs

idCharDevsDone	leay	BlockDevices,pcr

idBlockDevs	ldx	,y
		beq	idBlockDevsDone

		ldb	#1
		lbsr	initDevice

		leay	2,y
		bra	idBlockDevs
idBlockDevsDone	puls	x,y,pc

found_ok_msg	fcn	"OK"
found_err_msg	fcn	"found but failed to initialise"
not_found_msg	fcn	"missing"



*******************************************************************
* InitDevice - Initialise a character or block device
*
* on entry: 
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns: nothing
*
initDevice	pshs	x
		jsr	[CDev.InitFn,x]
		bsr	putDevName
		cmpa	#NO
		beq	idNoDev
		cmpa	#2
		bge	idErr
		
		leax	found_ok_msg,pcr
		lbsr	putStr
		bra	idNext

idNoDev		leax	not_found_msg,pcr
		lbsr	putStr
		bra	idNext

idErr		leax	found_err_msg,pcr
		lbsr	putStr
		bra	idNext

idNext		lbsr	putNL
		puls	x,pc



*******************************************************************
* putDevName - Print the device name
*
* on entry: 
*	Y: points to the entry in the DCB
*	B: 0=char dev, 1=Block dev
*
*  trashes: nothing
*
*  returns: nothing
*
putDevName	pshs	x,d
		tstb
		beq	pdnChar
		
		leax	block_dev_msg,pcr
		lbsr	putStr
		bra	skip
		
pdnChar		leax	char_dev_msg,pcr
		lbsr	putStr

skip		ldx	,y			; Pointer to CCB
		ldx	CDev.Info,x		; Pointer to ICB
		ldx	CInfo.Name,x		; Pointer to name
		lbsr	putStr
		leax	at_msg,pcr
		lbsr	putStr
		ldx	,y			; Pointer to CCB
		ldd	CDev.BaseAddr,x
		lbsr	putHexWord
		leax	sep_msg,pcr
		lbsr	putStr
		puls	x,d,pc


char_dev_msg	fcn	"\rCharacter device: "
block_dev_msg	fcn	"\rBlock device: "

at_msg		fcn	" @ "
sep_msg		fcn	" - "

		end section

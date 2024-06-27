;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;

; Character Devices
CDev.BaseAddr	equ	0	; Base address of device
CDev.InitFn	equ	2	; Initialisation function
CDev.Info	equ	4	; Info block
CDev.CanRead	equ	6	; Character available
CDev.CanWrite	equ	8	; Data buffer has space for a character
CDev.Read	equ	10	; Read a character
CDev.Write	equ	12	; Write a character
Sizeof.CDev	equ	14

; Character device Info block
CInfo.Name	equ	0
Sizeof.CInfo	equ	2


; Block Devices
BDev.BaseAddr	equ	CDev.BaseAddr	; Base address of device 
BDev.InitFn	equ	CDev.InitFn	; Initialisation function
BDev.Info	equ	CDev.Info	; Static disk information
BDev.ReadBlock	equ	6	; Read a block of data
BDev.WriteBlock	equ	8	; Write a block of data
Sizeof.BDev	equ	10

; Block device info block
BInfo.Name	equ	CInfo.Name	; pointer to string
Sizeof.BInfo	equ	2

		include "devices/character/mc6850.s"
		include "devices/block/virt_disk.s"

; The first character device will be assumed to be the console. Unusual
; things(tm) may happen if it isn't
CharDevices	fdb	SerialDCB0
		* fdb	SerialDCB1
		fdb	0

BlockDevices	* fdb	VDiskDCB
		fdb	0

		globals

g.currentCDev	rmb	2

		code

*******************************************************************
* preInitConsole 	Initialise *JUST* the first character device
*
* on entry: none
*
*  trashes: nothing
*
*  returns: nothing
*
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
		bra	1F
		
pdnChar		leax	char_dev_msg,pcr
		lbsr	putStr

1		ldx	,y			; Pointer to CCB
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


char_dev_msg	fcn	CR,"Character device: "
block_dev_msg	fcn	CR,"Block device: "

at_msg		fcn	" @ "
sep_msg		fcn	" - "

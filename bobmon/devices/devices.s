;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;

CDev.BaseAddr	equ	0	; Base address of device
CDev.InitFn	equ	2	; Initialisation io_function
CDev.CanRead	equ	4	; Character available
CDev.CanWrite	equ	6	; Data buffer has space for a character
CDev.Read	equ	8	; Read a character
CDev.Write	equ	10	; Write a character
Sizeof.CDev	equ	10

BDev.InitFn	equ	0
Sizeof.BDev	equ	2

		include "devices/mc6850.s"

CharDevices	fdb	SerialDCB0
		fdb	SerialDCB1
		fdb	0

BlockDevices	fdb	0

		globals

g.currentCDev	rmb	2

		code

*******************************************************************
* InitDevices 	Initialise all known character and block devices
*
* on entry: none
*
*  trashes: nothing
*
*  returns: nothing
*
initDevices	pshs	x,y
		leay	CharDevices,pcr

		ldx	,y			; The first char dev becomes the console
		stx	g.currentCDev,pcr

idCharDevs	ldx	,y++
		beq	idCharDevsDone
		jsr	[CDev.InitFn,x]
		bra	idCharDevs

idCharDevsDone	leax	BlockDevices,pcr
idBlockDevs	ldx	,y++
		beq	idBlockDevsDone
		jsr	[BDev.InitFn,x]
		bra	idBlockDevs
idBlockDevsDone	puls	x,y,pc

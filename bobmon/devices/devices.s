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
CDev.Info	equ	12	; Info block
Sizeof.CDev	equ	14

; Character device Info block
CInfo.Name	equ	0
Sizeof.CInfo	equ	2


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

idCharDevs	ldx	,y
		beq	idCharDevsDone
		jsr	[CDev.InitFn,x]
		bsr	putCharDevName
		cmpa	#NO
		beq	idcNoDev
		cmpa	#2
		bge	idcErr
		
		leax	found_ok_msg,pcr
		lbsr	putStr
		bra	idcNext

idcNoDev	leax	not_found_msg,pcr
		lbsr	putStr
		bra	idcNext

idcErr		leax	found_err_msg,pcr
		lbsr	putStr
		bra	idcNext

idcNext		lbsr	putNL
		leay	2,y
		bra	idCharDevs

idCharDevsDone	leax	BlockDevices,pcr
idBlockDevs	ldx	,y++
		beq	idBlockDevsDone
		jsr	[BDev.InitFn,x]
		bra	idBlockDevs
idBlockDevsDone	puls	x,y,pc

putCharDevName	pshs	x,d
		ldx	,y			; Pointer to CCB
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

at_msg		fcn	" @ "
sep_msg		fcn	" - "
found_ok_msg	fcn	"OK"
found_err_msg	fcn	"found but failed to initialise"
not_found_msg	fcn	"missing"
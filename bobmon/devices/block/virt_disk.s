
;
; Simple 6809 Monitor
;
; Copyright(c) 2016, Bob Green
;

; Virtual disk controller registers
VD.SR		equ	0
VD.CMD		equ	0
VD.DR		equ	1
VD.Sec2		equ	2
VD.Sec1		equ	3
VD.Sec0		equ	4


vdisk_max_drives equ	2	; Max # drives supported

; Device control block
VDiskDCB	fdb	VDiskBase	; Base of controller
		fdb	vdInit
		fdb	VDiskInfo
		fdb	vdReadBlock
		fdb	vdWriteBlock

; Device Control Block
VDiskInfo	fdb	vdisk_device_name
		fcb	vdisk_max_drives	; # units (disks) this device supports

vdisk_device_name
		fcn	"Virt disk controller"

		
		globals

vdisk.Drives	rmb	vdisk_max_drives


		code

*******************************************************************
* vdInit - initialise the disk subsystem
*
* on entry:
*	X: points to the DCB
*
*  trashes: nothing
*
*  returns: nothing
*	A: 0=No device, 1=OK, 2=Init error
*

vdInit		pshs	b,x,y
		tfr	x,y
		ldy	BDev.BaseAddr,y

		lda	#$0F		; Reset controller
		sta	VD.CMD,y
		lbsr	vdWaitBusy

; Query both disks
		lda	#$03		; Query drive 0
		lbsr	vdWaitBusy
		sta	VD.CMD,y
		lbsr	vdWaitBusy

		leax	vdi_unit_msg,pcr
		lbsr	putStr
		lda	#'0'
		lbsr	putChar
		leax	vdi_sep_msg,pcr
		lbsr	putStr

		lda	VD.SR,y
		anda	#$02		; Disk present bit
		beq	vdiNoDisk0

		lda	VD.Sec2,y
		lbsr	putHexByte
		lda	VD.Sec1,y
		lbsr	putHexByte
		lda	VD.Sec0,y
		lbsr	putHexByte
		bra	1F
		
vdiNoDisk0	leax	vdi_no_disk_msg,pcr
		lbsr	putStr
1		lbsr	putNL
		
		lda	#$43		; Query drive 1
		tfr	y,x
		sta	VD.CMD,y
		lbsr	vdWaitBusy

		leax	vdi_unit_msg,pcr
		lbsr	putStr
		lda	#'1'
		lbsr	putChar
		leax	vdi_sep_msg,pcr
		lbsr	putStr

		lda	VD.SR,y
		anda	#$02		; Disk present bit
		beq	vdiNoDisk1

		lda	VD.Sec2,y
		lbsr	putHexByte
		lda	VD.Sec1,y
		lbsr	putHexByte
		lda	VD.Sec0,y
		lbsr	putHexByte
		bra	2F

vdiNoDisk1	leax	vdi_no_disk_msg,pcr
		lbsr	putStr
2		lbsr	putNL
		
		lda	#OK

		puls	b,x,y,pc

vdi_unit_msg	fcn	"  Unit #"
vdi_sep_msg	fcn	": "
vdi_no_disk_msg	fcn	"not present"


	
*******************************************************************
* vdReadBlock - read block of data
*
* on entry: X - byte *rdBuff - Read buffer address
*	    Y - byte *LSN
*
*  returns: X - byte *buff
*

vdReadBlock	pshs	a,y

		puls	y,a,pc

	
	
*******************************************************************
* vdWriteBlock - write a block of data to disk
*
* on entry: X - byte *wrBuff -  Write buffer address
*    	    Y - byte *LSN
*
*  trashes: nothing
*
*  returns: nothing
*
vdWriteBlock
		rts



*******************************************************************
* vdWaitBusy - wait for the controller to be ready
*
* on entry: 
*	X - Address of controller
*
*  trashes: nothing
*
*  returns: nothing
*
vdWaitBusy	pshs	a
1		lda	VD.SR,x
		anda	#$40
		bne	1B

		puls	a,pc
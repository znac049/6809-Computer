bootMinArgs	equ	0
bootMaxArgs	equ	0
bootCommand	fcn	"boot"
bootHelp	fcn	TAB,"Attempt to boot from disk"

DD.totSectors		equ 	0	;rmb	3
DD.numTracks		equ	3	;rmb	1
DD.map			equ	4	;rmb	2
DD.sectorsPerCluster	equ	6	;rmb	2
DD.rootLSN		equ	8	;rmb	3
DD.owner		equ	11	;rmb	2
DD.attribs		equ	13	;rmb	1
DD.id			equ	14	;rmb	2
DD.format		equ	16	;rmb	1
DD.spt			equ	17	;rmb	2
DD.unused1		equ	19	;rmb	2
DD.bootLSN		equ	21	;rmb	3
DD.bootSize		equ	24	;rmb	2
DD.created		equ	26	;rmb	5
DD.volName		equ	31	;rmb	32
DD.options		equ	63	rmb	32
			

doBoot		leax	bootMsg,pcr
		lbsr	putStr

		ldx	#lsn.p
		lbsr	clearLSN
		tfr	x,y

		ldx	#secBuff

		lbsr	dkReadLSN
		lbcs	badRead

		tfr	x,u	; u = LSN buffer

		leax	boot1Msg,pcr
		lbsr	putStr

* Copy the root LSN
		ldy	#rootLSN.p
		leax	DD.rootLSN,u
		clra
		ldb	,x
		std	,y
		ldd	1,x
		std	2,y

		leax	rootLSNMsg,pcr
		lbsr	putStr
		ldx	#rootLSN.p
		lbsr	putLSN
		lbsr	putNL

* Copy the boot LSN
		ldy	#bootLSN.p
		leax	DD.bootLSN,u
		clra
		ldb	,x
		std	,y
		ldd	1,x
		std	2,y

		leax	bootLSNMsg,pcr
		lbsr	putStr
		ldx	#bootLSN.p
		lbsr	putLSN
		lbsr	putNL

* Grab the boot size
       	   	ldd	DD.bootSize,u
		std	bootSize

		leax	bootSizeMsg,pcr
		lbsr	putStr
		lbsr	putHexWord
		lbsr	putNL

* If boot size is zero, can't boot
     	        cmpd	#0
	       	beq	nonBoot

* Looking good. Read LSNs sequentially until 
* 'bootSize' bytes have been read. Load into
* memory at $2800.
		ldu	#$2800
bootLoop
		lda	#'.'
		lbsr	putChar

* read the next LSN..		
		ldx	#secBuff
		ldy	#bootLSN.p
		lbsr	dkReadLSN

* copy from buffer to real memory
       	    	ldy     #256
bootCopy	lda	,x+
		sta	,u+
		leay	-1,y
		bne	bootCopy

		lbsr	dkIncLSN

		ldd	bootSize
		cmpa	#0
		beq	bootLoaded
		subd	#256
		std	bootSize
		bra	bootLoop

bootLoaded	leax	bootLoadedMsg,pcr
		lbsr	putStr

		lbsr	$2800
		
		bra	bootDone


nonBoot		leax	nonBootMsg,pcr
		lbsr	putStr
		bra	bootDone


badRead		leax	badBootMsg,pcr
		lbsr	putStr


bootDone	rts

	
	
bootMsg		fcn	"Attempting to boot from CF/SD\r\n"
boot1Msg	fcn	"LSN0 read ok.\r\nBoot LSN:"
nonBootMsg	fcn	"Non bootable disk (bootSize=0)\r\n"
badBootMsg	fcn	"Couldn't read LSN0.\r\n"
rootLSNMsg	fcn	"Root LSN: "
bootLSNMsg	fcn	"Boot LSN: "
bootSizeMsg	fcn	"Boot size: "
bootLoadedMsg	fcn	"Boot code loaded into memory at $2800\r\n"
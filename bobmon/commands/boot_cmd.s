bootMinArgs	equ	0
bootMaxArgs	equ	0
bootCommand	fcn	"boot"
bootHelp	fcn	TAB,"Attempt to boot from disk"

			

doBoot		leax	bootMsg,pcr
		lbsr	putStr

		ldx	#lsn.p
		lbsr	clearLSN
		tfr	x,y

		ldx	#secBuff


bootDone	rts

	
	
bootMsg		fcn	"Attempting to boot from CF/SD\r\n"
rootLSNMsg	fcn	"Root LSN: "

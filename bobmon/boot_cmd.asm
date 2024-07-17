;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; boot.asm - the "boot" command
;

		include "constants.s"

		import	putStr

		export	bootMinArgs
		export	bootMaxArgs
		export	bootCommand
		export	bootHelp

		section code
bootMinArgs	equ	0
bootMaxArgs	equ	0
bootCommand	fcn	"boot"
bootHelp	fcb	TAB
		fcn	"\tAttempt to boot from disk"

			
		export bootFn
bootFn		leax	bootMsg,pcr
		lbsr	putStr

		rts

	
	
bootMsg		fcn	"Attempting to boot from CF/SD\r\n"
rootLSNMsg	fcn	"Root LSN: "

		end section
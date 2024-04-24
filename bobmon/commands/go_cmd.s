;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; go_cmd.s - implements the "Go" command.
;

goMinArgs	equ	0
goMaxArgs	equ	1
goCommand	fcn	"go"
goHelp		fcn	"<address>",TAB,"Run code starting at <address>"


*******************************************************************
* doGo - called by the command processor when the "go" command is
*	entered.
*
* on entry: nothing:
*
*  trashes: potentially everything (the command processor asumes this)
*
*  returns: nothing
*
doGo		lda	g.argc
		cmpa	#2
		bne	dgProceed

; the address to run from was supplied, convert argv[1] to address
		leax	g.argv,pcr
		ldx	2,x
		lbsr	strToHex
		bcs	dgBadArgs
		std	g.memoryAddress

dgProceed	leax	dg_running_msg,pcr
		lbsr	putStr
		ldd	g.memoryAddress
		lbsr	putHexWord
		lbsr	putNL
		leax	g.memoryAddress,pcr
		jsr	[,x]
		bra	dgDone

dgBadArgs	leax	dg_bad_args_msg,pcr
		lbsr	putStr

dgDone		rts

dg_running_msg	fcn	"Transferring control to "
dg_bad_args_msg	fcn	"Address expected on command line",CR,LF
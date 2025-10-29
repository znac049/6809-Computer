;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; go_cmd.s - implements the "Go" command.
;
		include "constants.s"

		import	cmd_table

		import	putChar
		import	putStr
		import	putNL
		import	padToCol

		section code

		export	helpCommand
		export	helpHelp
helpCommand	fcn	"help"
helpHelp	fcn	"\tDisplay this help"

*******************************************************************
* helpFn - called by the command processor when the "help" 
*	command is entered.
*
* on entry: nothing:
*
*  trashes: potentially everything (the command processor asumes this)
*
*  returns: nothing
*
		export	helpFn
helpFn		leax	dh_msg_1,pcr
		lbsr	putStr
		leay	cmd_table,pcr
		
dhNext		ldd	,y
		beq	dhDone
		lda	#SPACE
		lbsr	putChar
		lbsr	putChar
		ldx	4,y		; The command string
		lbsr	putStr

		lda	#SPACE
		lbsr	putChar

		ldx	6,y		; The help string
dhPrNext	lda	,x+
		beq	dhCmdDone
		cmpa	#TAB
		bne	dhPrChar
		lda	#24
		lbsr	padToCol
		bra	dhPrNext
		
dhPrChar	lbsr	putChar
		bra	dhPrNext
dhCmdDone	lbsr	putNL
		lbsr	putNL

		leay	8,y
		bra	dhNext

dhDone		rts

dh_msg_1	fcn	"Commands I understand:\r\n"

		end section


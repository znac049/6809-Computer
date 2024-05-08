;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; commands.s - command processing
;

		globals

g.matchedCCB	rmb	2
g.matchCount	rmb	1


		code

; Main command table
cmd_table	fdb	doBinary
		fcb	radixMinArgs,radixMaxArgs
		fdb	binaryCommand
		fdb	binaryHelp

		fdb	doBoot
		fcb	bootMinArgs,bootMaxArgs
		fdb	bootCommand
		fdb	bootHelp

		fdb	doDecimal
		fcb	radixMinArgs,radixMaxArgs
		fdb	decimalCommand
		fdb	decimalHelp

		fdb	doDisassemble
		fcb	disassMinArgs,disassMaxArgs
		fdb	disassembleCommand
		fdb	disassembleHelp

		fdb	doDump
		fcb	dumpMinArgs,dumpMaxArgs
		fdb	dumpCommand
		fdb	dumpHelp

		fdb	doGo
		fcb	goMinArgs,goMaxArgs
		fdb	goCommand
		fdb	goHelp

		fdb	doHexadecimal
		fcb	radixMinArgs,radixMaxArgs
		fdb	hexadecimalCommand
		fdb	hexadecimalHelp

		fdb	doLoad
		fcb	loadMinArgs,loadMaxArgs
		fdb	loadCommand
		fdb	loadHelp

		fdb	doRadix
		fcb	radixMinArgs,radixMaxArgs
		fdb	radixCommand
		fdb	radixHelp

		fdb	doRegisters
		fcb	registersMinArgs,registersMaxArgs
		fdb	registersCommand
		fdb	registersHelp

		fdb	doWindow
		fcb	windowMinArgs,windowMaxArgs
		fdb	windowCommand
		fdb	windowHelp

		fdb	doHelp
		fcb	helpMinArgs,helpMaxArgs
		fdb	helpCommand
		fdb	helpHelp

		fdb	0

*******************************************************************
* matchCommand -
*
* on entry: 
*	X: address of string (command) to look up
*
*  trashes: nothing
*
*  returns:
*	A: count of possible matches
*
matchCommand	pshs	y,b

		leay	cmd_table,pcr
		ldd	#0
		sta	g.matchCount
		std	g.matchedCCB

mcTryNext	ldd	,y		; Handler addres
		beq	mcDone

		bsr	singleMatch
		tsta
		beq	mcNoMatch

; We found a match
		adda	g.matchCount	; Bump the match count
		sta	g.matchCount	;
		sty	g.matchedCCB	; Stash address of command block

mcNoMatch	leay	8,y		; next CCB
		bra	mcTryNext

mcDone		lda	g.matchCount
		puls	y,b,pc

*******************************************************************
* singleMatch -
*
* on entry: 
*	X: address of command line
*	Y: address of command block (CCB)
*
*  trashes: nothing
*
*  returns:
*	A: 0=no match, 1=match
*
singleMatch	pshs	x,y
		ldy	4,y		; point at the start of the command string

smNext		lda	,x+
		beq	smEndCmd	; hit end of command line
		cmpa	#SPACE
		beq	smEndCmd
		cmpa	#TAB
		beq	smEndCmd
		cmpa	#CR
		beq	smEndCmd
		cmpa	,y+
		beq	smNext		; matching so far
; Strings don't match.
		clra			; signal no match and return
		bra	smDone

; We've hit the end of the command line or first arg, so it's a match
smEndCmd	lda	#1

smDone		puls	x,y,pc

*******************************************************************
* readCommandLine -
*
* on entry: 
*	X: address of buffer to read into
*	A: buffer size
*
*  trashes: nothing
*
*  returns: nothing
*
readCommandLine	pshs	a,x
		clr	,x	; Clear the string

rclNextChar	lbsr	getLChar
		cmpa	#SPACE
		blt	rclNonPrintable
		cmpa	#DEL
		beq	rclDelete
		bra	rclPrintable

; Non printable char
rclNonPrintable	cmpa	#CR
		beq	rclEOL

		cmpa	#DEL
		beq	rclDelete

; Complain and then ignore it
		lda	#BELL
		lbsr	putChar
		bra	rclNextChar

; Handle delete
rclDelete	cmpx	#g.commandLine	; Ignore if nothing to delete
		beq	rclNextChar
		
		leax	-1,x		; Back up one space
		clr	,x
		lda	#BS
		lbsr	putChar
		lda	#SPACE
		lbsr	putChar
		lda	#BS
		lbsr	putChar
		bra	rclNextChar

; It's a printable character
rclPrintable	lbsr	putChar

		sta	,x+
		clr	,x
		bra	rclNextChar	

rclEOL		lbsr	putNL
		puls	a,x,pc

;
; Command handlers
;
		include "commands/boot_cmd.s"
		include "commands/disassemble.s"
		include "commands/dump_cmd.s"
		include "commands/go_cmd.s"
		include "commands/help_cmd.s"
		include "commands/load_cmd.s"
		include "commands/radix_cmds.s"
		include "commands/register_cmd.s"
		include "commands/window_cmd.s"


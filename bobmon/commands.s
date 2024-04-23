;--------------------------------------------------------
;
; commands.s - command processing
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

		globals

g.matchedCCB	rmb	2
g.matchCount	rmb	1


		code

; Main command table
cmd_table	fdb	doBoot
		fcb	bootMinArgs,bootMaxArgs
		fdb	bootCommand
		fdb	bootHelp

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

		fdb	doLoad
		fcb	loadMinArgs,loadMaxArgs
		fdb	loadCommand
		fdb	loadHelp

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

;
; matchCommand -
;
; Call with:
;	X - address of string (command) to look up
;
; Returns:
;	A - count of matches
;
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

;
; singleMatch -
;
; Call with:
;	X - address of command line
;	Y - address of command block (CCB)
;
; Returns:
;	A - 0=no match, 1=match
;
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

;
; readCommandLine -
;
; Call with:
;	X - Address of buffer to read into
;	A - buffer size
;
; Returns:
;
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

		* lbsr	putNL
		* lbsr	putHexByte
		* lbsr	putNL
		
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
		include "boot_cmd.s"
		include "disassemble.s"
		include "dump_cmd.s"
		include "go_cmd.s"
		include "help_cmd.s"
		include "load_cmd.s"
		include "register_cmd.s"
		include "window_cmd.s"


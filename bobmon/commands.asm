;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; commands.s - command processing
;

		include "constants.s"

command		macro
		import	{1}Fn
		import  {1}Command
		import	{1}Help
		endm

		import	putChar
		import  putStr
		import	putNL
		import	printNum
		import	getChar
		import	getLChar

zobMinArgs	equ	0
zobMaxArgs 	equ	0

		command binary
		command	boot
		command	cpu
		command	decimal
		command disk
		command	dump
		command	dump
		command go
		command	hexadecimal
		command load
		command radix
		command registers
		command unassemble
		command window
		command zob
		command	help

		section globals

		export	g.matchedCCB
g.matchedCCB	rmb	2
		export	g.matchCount
g.matchCount	rmb	1
		export	g.commandLine
g.commandLine	rmb	MAX_LINE


		section code

		export	cmd_table
; Main command table
cmd_table	fdb	binaryFn
		fcb	0,0
		fdb	binaryCommand
		fdb	binaryHelp

		fdb	bootFn
		fcb	0,0
		fdb	bootCommand
		fdb	bootHelp

		fdb	cpuFn
		fcb	0,0
		fdb	cpuCommand
		fdb	cpuHelp

		fdb	decimalFn
		fcb	0,0
		fdb	decimalCommand
		fdb	decimalHelp

		fdb	diskFn
		fcb	0,0
		fdb	diskCommand
		fdb	diskHelp

		fdb	dumpFn
		fcb	0,2
		fdb	dumpCommand
		fdb	dumpHelp

		fdb	goFn
		fcb	0,1
		fdb	goCommand
		fdb	goHelp

		fdb	hexadecimalFn
		fcb	0,0
		fdb	hexadecimalCommand
		fdb	hexadecimalHelp

		fdb	loadFn
		fcb	0,1
		fdb	loadCommand
		fdb	loadHelp

		fdb	radixFn
		fcb	0,1
		fdb	radixCommand
		fdb	radixHelp

		fdb	registersFn
		fcb	0,0
		fdb	registersCommand
		fdb	registersHelp

		fdb	unassembleFn
		fcb	0,1
		fdb	unassembleCommand
		fdb	unassembleHelp

		fdb	windowFn
		fcb	0,1
		fdb	windowCommand
		fdb	windowHelp

		fdb	zobFn
		fcb	0,0
		fdb	zobCommand
		fdb	zobHelp

		fdb	helpFn
		fcb	0,0
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
matchCommand	export

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

readCommandLine	export

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

rclEOL		
		lbsr	putNL
		puls	a,x,pc


		ifdef	DEBUGGING

*******************************************************************
* dumpCommandTable -
*
* on entry: 
*
*  trashes: nothing
*
*  returns: nothing
*
		export dumpCommandTable
dumpCommandTable
		pshs	x,y,a,b

		leax	dtIntro,pcr
		lbsr	putStr

		leay	cmd_table,pcr

dctNext		tst	,y
		beq	dctDone

		ldx	4,y
		lbsr	putStr

		lda	#SPACE
		lbsr	putChar

		ldb	2,y
		sex
		lbsr	printNum

		lda	#','
		lbsr	putChar

		ldb	3,y
		sex
		lbsr	printNum

		lbsr	putNL

		leay	8,y
		bra	dctNext

dctDone		lbsr	putNL
		
		puls	x,y,a,b,pc

dtIntro		fcn	"\r\nCommand table:\r\n"

		endc

		end section

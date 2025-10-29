;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; The main monitor code. Everything else is pulled in from
; here.
;
		include "sysdefs.s"
		include "macros.s"

		import	s_globals
		import	l_globals

		import	g.matchedCCB
		import	g.regA
		import	g.regB
		import	g.regX
		import	g.regY
		import	g.regU
		import	g.regS
		import	g.unprintable
		import	g.radix
		import	g.prevChar
		import	g.echo
		import	g.commandLine

		import	putStr
		import	putChar
		import	putNL
		import	readCommandLine
		import	isBlankLine
		import	makeArgs
		import  dumpArgs
		import  matchCommand
		import  dumpCommandTable
		import	preInitConsole
		import	initDevices
		import	printNum
		import	registersFn

cpu.6809	equ	0
cpu.6309	equ	1

		section globals

g.cpuType	rmb	1
g.ramEnd	rmb    	2

		export	g.argc
g.argc		rmb	1
		export	g.argv
g.argv		rmb	MAX_ARGS*2

		export	g.memoryAddress
g.memoryAddress	rmb	2
		export	g.linesPerPage
g.linesPerPage	rmb	1	; the number of terminal lines to display at a time

		include "constants.s"


		section code

		export	handle_reset
handle_reset	lds	#system_stack
		ldu	#user_stack
		orcc	#$50		; disable interrupts

		lbsr	initBSS

; Bit of a bodge. We need to initialise the console device so we can start printing
; stuff. 	
		lbsr	preInitConsole

		lbsr	initVars

is6809		leax    system_ready_msg,pcr
		lbsr    putStr
		lda	g.cpuType
		cmpa	#cpu.6309
		* beq	is6309

		leax	cpu_6809_msg,pcr
		lbsr	putStr

		lbsr	initDevices

		lbra	loop

cpu_6809_msg	fcn	"CPU: 6809\r\n"

		export	appTerminated
appTerminated	lds	#system_stack
		pshs	a,b,x,y,cc
		tstb
		beq	terminatedOK
		leax	app_terminated_with_error_msg,pcr
		lbsr	putStr
		lbsr	printNum
		lbsr	putNL
		puls	a,b,x,y,cc
		sta	g.regA
		stb	g.regB
		stx	g.regX
		sty	g.regY
		stu	g.regU
		sts	g.regS
		lbsr	registersFn
		bra	loop

terminatedOK	leax	app_terminated_ok_msg,pcr
		lbsr	putStr
		bra	loop

app_terminated_with_error_msg
		fcn	"\r\n***\r\nApp terminated with code "

app_terminated_ok_msg
		fcn	"\r\n***\r\nApp exited successfully\r\n"

loop		lds	#system_stack

		ifdef	DEBUGGING
		lbsr	dumpCommandTable
		endc

		leax	prompt_msg,pcr
		lbsr	putStr

		leax	g.commandLine,pcr
		lbsr	readCommandLine	; Grab a line from the console
		lbsr	isBlankLine
		tsta
		bne	loop		; It was an empty line

		leax	g.commandLine,pcr
		lbsr	makeArgs
		
		ifdef	DEBUGGING
		lbsr	dumpArgs
		endc

		lda	g.argc
		beq	loop		; No command

		ldx	g.argv		; X points at argv[0]

		lbsr	matchCommand
		cmpa	#1		; did we find any matches?
		blt	clUnknownCommand ; No matches - unknown command
		bgt	clAmbiguousCommand ; Multiple matches - ambiguous command

; It's a single match - does it have the right number of args
		ldy	g.matchedCCB
		* lbsr	countArgs
		* deca			; Don't include the command itself
		lda	g.argc
		deca		

		cmpa	2,y		; min args
		blt	clTooFewArgs
		cmpa	3,y		; max args
		bgt	clTooManyArgs

		ldx	g.matchedCCB
		jsr	[,x]
		bra	loop

clTooManyArgs	leax	cl_too_many_msg,pcr
		lbsr	putStr
		bra	loop

clTooFewArgs	leax	cl_too_few_msg,pcr
		lbsr	putStr
		bra	loop
clAmbiguousCommand
		leax	cl_ambiguous_msg,pcr
		lbsr	putStr
		lbra	loop

clUnknownCommand
		leax	cl_unknown_msg,pcr
		lbsr	putStr
		lbra	loop


* Non-destructive memory check. Doesn't do the full works, just
* tests for simple write-read. If this monitor is running in RAM,
* make sure we don't overwrite!
quickMemCheck	pshs	a,b

		ldx	#0	; Address to start testing from

		orcc	#$ff	; no interrupts while we test, in case
				; any of the interrupt handlers use RAM
				; that we are temporarily changing.


		lda	#$55
doQuickByte	
		ldb	,x	; Take copy of ram at X
	
		lda	#$55
		sta	,x	; Write our test pattern
		eora	,x	; result should be 0
		bne	doQuickEnd

		stb	,x+
	
		cmpx	#ram_end
		bne	doQuickByte

doQuickEnd
		stx	g.ramEnd
	
		puls	a,b,pc



prompt_msg	fcn	"> "
system_ready_msg
		fcn	"\r\nBobMon 6x09 Monitor, version 1.04\r\nCopyright (C) Bob Green, 2016-2025\r\n"
cl_ambiguous_msg	
		fcn 	"Command is ambiguous\r\n"
cl_unknown_msg
		fcn	"Unknown Command\r\n"
cl_too_few_msg	fcn	"Not enough arguments supplied.\r\n"
cl_too_many_msg	fcn	"Too many arguments provided.\r\n"


; Initialise variable space to zero
initBSS		pshs	x,y,a
		ldx	#s_globals
		ldy	#l_globals
		clra

iniLoop		sta	,x+
		leay	-1,y
		bne	iniLoop
		puls	x,y,a,pc

; Initialise global variables
initVars	pshs	x,a
		lda	#16
		sta	g.linesPerPage
		
		lda	#cpu.6809
		sta	g.cpuType
		
		lda	#SPACE
		sta	g.unprintable

		ldd	#handle_reset
		std	g.memoryAddress

		lda	#16
		sta	g.radix

		lda	#0
		sta	g.prevChar
		sta	g.echo
		
		puls	x,a,pc

		export	handle_irq
		export	handle_firq
		export	handle_undef
		export	handle_swi2
		export	handle_swi3
		export	handle_nmi
handle_irq
handle_firq
handle_undef
handle_swi2
handle_swi3
handle_nmi	
		rti

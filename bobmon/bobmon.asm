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

cpu.6809	equ	0
cpu.6309	equ	1

		globals
		org	(ram_end-variables_size)+1
variables_start	equ	*

g.cpuType	rmb	1
g.ramEnd	rmb    	2

g.argc		rmb	1
g.argv		rmb	MAX_ARGS*2
g.commandLine	rmb	MAX_LINE


		include "constants.s"
		include "variables.s"


		code
		org	rom_start

		include	"3rdParty/disasm.s"

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

cpu_6809_msg	fcn	"CPU: 6809",CR,LF

appTerminated	lds	#system_stack
		pshs	a,b,x,y,cc
		tsta
		beq	terminatedOK
		leax	app_terminated_with_error_msg,pcr
		lbsr	putStr
		lbsr	putHexByte
		lbsr	putNL
		puls	a,b,x,y,cc
		lbsr	doRegisters
		bra	loop

terminatedOK	leax	app_terminated_ok_msg,pcr
		lbsr	putStr
		bra	loop

app_terminated_with_error_msg
		fcn	CR,LF,"***",CR,LF,"App terminated with code "

app_terminated_ok_msg
		fcn	CR,LF,"***",CR,LF,"App exited successfully",CR,LF

loop		lds	#system_stack

		leax	prompt_msg,pcr
		lbsr	putStr

		leax	g.commandLine,pcr
		lbsr	readCommandLine	; Grab a line from the console
		lbsr	isBlankLine
		tsta
		bne	loop		; It was an empty line

		leax	g.commandLine,pcr
		lbsr	makeArgs
		* lbsr	dumpArgs
		lda	g.argc
		beq	loop		; No command

		ldx	g.argv		; X points at argv[0]

		lbsr	matchCommand
		cmpa	#1		; did we find any matches?
		blt	clUnknownCommand; No matches - unknown command
		bgt	clAmbiguousCommand; Multiple matches - ambiguous command

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
		fcc	CR,LF,"BobMon 6x09 Monitor, version 1.0",CR,LF
		fcn	"Copyright (C) Bob Green, 2016-2024",CR,LF
cl_ambiguous_msg	
		fcn 	"Command is ambiguous",CR,LF
cl_unknown_msg
		fcn	"Unknown Command",CR,LF
cl_too_few_msg	fcn	"Not enough arguments supplied.", CR,LF
cl_too_many_msg	fcn	"Too many arguments provided.",CR,LF


; Initialise variable space to zero
initBSS		pshs	x,y,a
		ldx	#variables_start
		ldy	#variables_size
		clra

1		sta	,x+
		leay	-1,y
		bne	1B
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



handle_irq	rti
handle_firq	rti
handle_undef	rti
handle_swi2	rti
handle_swi3	rti
handle_nmi	rti

		include "args.s"
		include "cf_io.s"
		include "commands/commands.s"
		include "devices/devices.s"
		include "disk_io.s"
		include "fs/fs.s"
		include "devices/block/LSN.s"
		include "radix.s"
		include "sd_io.s"
		include "stdio.s"
		include "string_functions.s"
		include "syscalls.s"

		include	"system_vectors.s"

		globals

; This must be the last item in the Globals segment
;
variables_size	equ	*-variables_start		

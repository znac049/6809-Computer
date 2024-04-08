		include "sysdefs.s"
		include "constants.s"
		include "variables.s"

		org	rom_start

		include "serial_io.s"
		include "io_functions.s"
		include "string_functions.s"
		include "commands.s"
		include "disk_io.s"

;		setdp	$00

handle_reset	lds	#system_stack
		ldu	#user_stack
		orcc	#$50		; disable interrupts

		leax	serialPutChar,pcr
		stx	putChar_fn

		leax	serialGetChar,pcr
		stx	getChar_fn

		leax    system_ready_msg,pcr
		lbsr    putStr

		lbsr	dkinfo
loop		leax	prompt_msg,pcr
		lbsr	putStr

		leax	line_buff,pcr
		lbsr	readCommandLine	; Grab a line from the console
		lbsr	isBlankLine
		tsta
		bne	loop		; It was an empty line

		leax	line_buff,pcr
		lbsr	matchCommand
		cmpa	#1		; did we find any matches?
		blt	clUnknownCommand; No matches - unknown command
		bgt	clAmbiguousCommand; Multiple matches - ambiguous command

; It's a single match - does it have the right number of args
		ldy	matched_ccb
		leax	line_buff,pcr
		lbsr	countArgs

		cmpa	2,y		; min args
		blt	clTooFewArgs
		cmpa	3,y		; max args
		bgt	clTooManyArgs

		ldx	matched_ccb
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

prompt_msg	fcn	"> "
system_ready_msg
		fcc	CR,LF,"BobMon a 6x09 Monitor",CR,LF
		fcc	"Version 1.0",CR,LF
		fcn	"(C) Bob Green, 2024",CR,LF
cl_ambiguous_msg	
		fcn 	"Command is ambiguous",CR,LF
cl_unknown_msg
		fcn	"Unknown Command",CR,LF
cl_too_few_msg	fcn	"Not enough arguments supplied.", CR,LF
cl_too_many_msg	fcn	"Too many arguments provided.",CR,LF

handle_irq	rti
handle_firq	rti
handle_undef	rti
handle_swi	rti
handle_swi2	rti
handle_swi3	rti
handle_nmi	rti

		include	"system_vectors.s"

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

readLine	leax	line_buff,pcr
		clr	,x

1		lbsr	getChar
		cmpa	#SPACE
		blt	6F
		cmpa	#DEL
		blt	5F


; Non printable char
6		cmpa	#CR
		beq	2F

		* lbsr	putNL
		* lbsr	putHexByte
		* lbsr	putNL
		
		cmpa	#DEL
		beq	7F

; Complain and then ignore it
		lda	#BELL
		lbsr	putChar
		bra	1B

; Handle backspace
7		cmpx	#line_buff	; Ignore if already at start of line
		beq	1B
		
		leax	-1,x		; Back up one space
		clr	,x
		lda	#BS
		lbsr	putChar
		lda	#SPACE
		lbsr	putChar
		lda	#BS
		lbsr	putChar
		bra	1B

; It's a printable character
5		lbsr	putChar

		sta	,x+
		clr	,x
		bra	1B		

2		lbsr	putNL

		leax	line_buff,pcr
		lda	,x
		beq	loop		; Empty line

		lbsr	matchCommand

		cmpa	#1		; Just a single match?
		bgt	3F		; Ambiguous command
		bne	4F		; No match

; It's a single match
		* leax	calling_handler_msg,pcr
		* lbsr	putStr
		* ldd	matched_command_ptr	
		* lbsr	putHexWord
		* lbsr	putNL

		* lbsr	[matched_command_ptr]

		leax	loop,pcr	;
		pshs	x		; return address
		ldd	matched_command_ptr
		pshs	a,b		; This is just plain wrong. The trouble is
		puls	pc		; doing it correctly fails (indirect bsr)

		* bra	loop

3		leax	ambiguous_command_msg,pcr
		lbsr	putStr
		lbra	loop

4		leax	unknown_command_msg,pcr
		lbsr	putStr
		lbra	loop

prompt_msg	fcn	"> "
system_ready_msg
		fcc	CR,LF,"BobMon a 6x09 Monitor",CR,LF
		fcc	"Version 1.0",CR,LF
		fcn	"(C) Bob Green, 2024",CR,LF
ambiguous_command_msg	
		fcn 	"Command is ambiguous",CR,LF
unknown_command_msg
		fcn	"Unknown Command",CR,LF
calling_handler_msg	
		fcn	"Calling handler at $"

handle_irq	rti
handle_firq	rti
handle_undef	rti
handle_swi	rti
handle_swi2	rti
handle_swi3	rti
handle_nmi	rti

		include	"system_vectors.s"

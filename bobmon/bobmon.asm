;
;		Start of System ROM 
;
		org	rom_start

		include "io_functions.s"
		include "string_functions.s"
		include "disk_io.s"

uart		equ	$c000
system_stack	equ	$0200
user_stack	equ	$0400
vector_table	equ	$fff0
rom_start	equ	$e000


;		setdp	$00


handle_reset	lds	#system_stack
		ldu	#user_stack
		orcc	#$50		; disable interrupts

		leax    system_ready,pcr
		lbsr    putstr

		lbsr	dkinfo
loop		leax	prompt_str,pcr
		lbsr	putstr

		lbsr	getchar
		;lbsr	puthexbyte
		lbsr	putnl
		bra	loop


prompt_str	fcn	"> "
system_ready	fcc	"System loaded and ready"
		fcn 	13,10

handle_irq	rti
handle_firq	rti
handle_undef	rti
handle_swi	rti
handle_swi2	rti
handle_swi3	rti
handle_nmi	rti

		include	"system_vectors.s"

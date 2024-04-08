;--------------------------------------------------------
;
; sysdefs.s - hardware specific definitions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

;
; I/O devices
;
uart			equ	$a000
fdc			equ	$a008



;
; Ram specific
;
ram_start		equ	0
ram_size		equ	$8000
ram_end			equ	(ram_start+ram_size)-1

;
; Rom specific
;
rom_start		equ	$c000

vectorTable_start	equ	$fff0

;
; Monitor
;
system_stack	equ	$0200
user_stack	equ	$0400

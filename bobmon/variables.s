;--------------------------------------------------------
;
; variables.s - variables used by the monitor
;
; They will be placed at the end of ram
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;


			org	(ram_end-variables_size)+1
variables_start		equ	*

cpu6809			equ	0
cpu6309			equ	1

cpu_type		rmb	1

putChar_fn		rmb	2
getChar_fn		rmb	2

current_column		rmb	1

MAX_LINE		equ	80
MAX_ARGS		equ	5
line_buff		rmb	MAX_LINE
argc			rmb	1
argv			rmb	MAX_ARGS*2

dump_address		rmb	2
dump_window		rmb	1	; the number of terminal lines to display at a time

ihex_length		rmb	1
ihex_address		rmb	2
ihex_type		rmb	1
ihex_xsum		rmb	1

; Used by the command parser
matched_ccb		rmb	2
match_count		rmb	1

; Used by getHexWord
word_value		rmb	2

; Used by getHexByte
upper_nibble		rmb	1

variables_size		equ	*-variables_start
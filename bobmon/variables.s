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

putChar_fn		rmb	2
getChar_fn		rmb	2

MAXLINE			equ	80
line_buff		rmb	MAXLINE
line_ptr		rmb	1
argc			rmb	1
min_args		rmb	1
max_args		rmb	1

ihex_length		rmb	1
ihex_address		rmb	2
ihex_type		rmb	1
ihex_xsum		rmb	1

; Used by the command parser
matched_ccb		rmb	2
match_count		rmb	1

; Used by getHexByte
upper_nibble		rmb	1

variables_size		equ	*-variables_start
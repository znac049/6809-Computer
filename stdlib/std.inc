; Equates.


LBUFMX			EQU	250	number of available bytes in LINBUF buffer

sys			macro	noexpand
			swi
			fcb		\1
			endm

;
; System calls
;
scGetChar	equ	0	; Input character with no parity
scPutChar	equ	1	; Output chaarcter
scPutStr	equ	2	; Print a string (EOS terminated)
scPutNLStr	equ	3	; Put CR/LF and string
scPut2Hex	equ	4	; Output two digit hex and a space
scPut4Hex	equ	5	; Output four digit hex and a space
scPutNL		equ	6
scPutSpace	equ	7
scTerminate	equ	8	; Reenter the monitor
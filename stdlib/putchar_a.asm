		include	std.inc

		section code

_putchar	export
putchar_a	export

CHROUT          import


* void putchar(byte c)
*
* Converts LF ($0A) into CR ($0D) before calling CHROUT.
*
_putchar	lda	3,s

* putchar_a should be called by the other routines (printf, etc.)
* whenever the character to be printed might be a newline.
*
putchar_a	sys	scPutChar
		rts

		endsection

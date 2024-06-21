	SECTION code

_putchar	EXPORT
putchar_a	EXPORT

CHROUT          IMPORT


* void putchar(byte c)
*
* Converts LF ($0A) into CR ($0D) before calling CHROUT.
*
_putchar
	lda	3,s

* putchar_a should be called by the other routines (printf, etc.)
* whenever the character to be printed might be a newline.
*
putchar_a
	ifdef _CMOC_VOID_TARGET_
	swi
	fcb	1
	else
	jmp	[CHROUT,pcr]
	endc

	endsection

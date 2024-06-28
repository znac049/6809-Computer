	section code


; OS-9: Nothing generated. See os9-sbrkmax.c.
	ifndef OS9


_sbrkmax        export
end_of_sbrk_mem import
program_break   import


* size_t sbrkmax(void);
*
* Returns (in D) the maximum number of bytes that can be successfully
* asked of sbrk().
*
_sbrkmax

	ldd	end_of_sbrk_mem,pcr
	subd	program_break,pcr
	bhs     @sbrkmax_non_neg
* The program break is after the stack space. Not supported by sbrk().
	clra
	clrb
@sbrkmax_non_neg
	rts


	endc


	endsection

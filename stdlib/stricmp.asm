        section code

_stricmp	export

convertABToUpperCase    import
strcmpimpl				import


* int strcmp(const char *, const char *);
*
_stricmp
	leax	convertABToUpperCase,PCR
	lbra	strcmpimpl


        endsection

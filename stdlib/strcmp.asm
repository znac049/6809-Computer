		section code

_strcmp		export

strcmpimpl	import


* int strcmp(const char *, const char *);
*
_strcmp
		leax	noTransform,PCR
		lbra	strcmpimpl

noTransform
		rts


		endsection

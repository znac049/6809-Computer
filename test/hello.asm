; Simple test program

		org	$4000
		leax	hello_msg,pcr
		swi
		fcb	3

		lda	#0
		swi
		fcb	8

		*jmp	$c000

hello_msg	fcn	"Hello, world. How are you today? Bob is very clever isn't he :-)"

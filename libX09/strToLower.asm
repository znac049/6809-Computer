;
; LibX09 - a library of useful functions for the 6x09 
;
; Copyright(c) 2024, Bob Green <bob@chippers.org.uk>
;
;

* strToLower - convert string to lowercase
*
* on entry:
*	X - trhe string to lowercase
*
*  trashes: nothing
*
*  returns:
*	X - the converted string
*

		section code

	 	export	strToLower

strToLower	pshs	a,x

Loop		lda	,x
		beq	Done		; EOS terminated
		cmpa	#'A'
		blt	Next
		cmpa	#'Z'
		bgt	Next
		ora	#$20

Next		sta	,x+		
		tsta			; Hit bit terminated
		bpl	Loop
		
Done		puls	a,x,pc

		endsection
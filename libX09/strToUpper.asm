;
; LibX09 - a library of useful functions for the 6x09 
;
; Copyright(c) 2024, Bob Green <bob@chippers.org.uk>
;
;

* strToUpper - convert string to uppercase
*
* on entry:
*	X - trhe string to uppercase
*
*  trashes: nothing
*
*  returns:
*	X - the converted string
*

		section code

	 	export	strToUpper

strToUpper	pshs	a,x

Loop		lda	,x
		beq	Done		; EOS terminated
		cmpa	#'a'
		blt	Next
		cmpa	#'z'
		bgt	Next
		anda	#~32

Next		sta	,x+		
		tsta			; Hit bit terminated
		bpl	Loop
		
Done		puls	a,x,pc

		end section
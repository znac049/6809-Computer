	section code

isDWordZero	export


; Input: X => long.
; Output: Z flag.
; Preserves X and D.
;
isDWordZero
	tst	,x
	bne	@done
	tst	1,x
	bne	@done
	tst	2,x
	bne	@done
	tst	3,x
@done	rts


	endsection

	section code

orDWordWord	export


; Input: Pushed arguments: addresses of left dword, value of right word;
;        X => destination dword (may be same as address of left dword).
; Preserves X. Trashes D.
;
orDWordWord
	pshs	u
	ldu	4,s		; left dword
	ldd	,u		; high word
	std	,x		; unchanged
	ldd	2,u		; low word
	ora	6,s		; right word is at S+6
	orb	7,s
	std	2,x
	puls	u,pc




	endsection

	section code

cmpDWordUnsignedInt	export

cmpDWordDWord           import


cmpDWordUnsignedInt
	pshs	u,x
	ldx	6,s		; address of dword
	ldd	8,s		; unsigned int
	pshs	b,a		; create temp dword in stack
	clr	,-s
	clr	,-s		; pushed dword version of int
	leau	,s		; point to dword (right side)
	pshs	u,x
	lbsr	cmpDWordDWord
	leas	8,s		; clean up pushed U and X, and temp long
	puls	x,u,pc




	endsection

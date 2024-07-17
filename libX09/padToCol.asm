		import	g.currentColumn
		import	g.unprintable

		import	putNL
		import	putChar

		section code

		*******************************************************************
* padToCol - move the cursor to a given column #. If we are beyond
*	that column on the current line, write a newline and then 
*	move to the indicated column
*
* on entry: 
*	A: The column # to move to
*
*  trashes: nothing
*
*  returns: nothing
*
		export padToCol
padToCol	pshs	a,b
		tfr	a,b
		cmpb	g.currentColumn
		bpl	justPad
		lbsr	putNL			; Gone past the column, so start a new line

justPad		lda	g.unprintable
		lbsr	putChar
		cmpb	g.currentColumn
		bne	justPad

		puls	a,b,pc

		end section
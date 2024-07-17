;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; stdio.s - generic input and output io_functions.
;	Note. All functions either read or write from/to the
;	currently selected character device.
;

		include "constants.s"
		include "devices.s"

		import	g.currentCDev

		section globals

		export	g.unprintable
		export	g.upperNibble
		export	g.currentColumn
		export	g.prevChar
		export	g.echo
g.unprintable	rmb	1
g.upperNibble	rmb	1
g.currentColumn	rmb	1
g.prevChar	rmb	1
g.echo		rmb	1

		section code

*******************************************************************
* getChar - read (wait if necessary) a character. If a linefeed
*	is read, either ignore it (if it follows a CR) or
*	convert it to CR.
*
* on entry: none
*
*  trashes: nothing
*
*  returns: 
*	A: the character we read
*
		export	getChar
getChar		pshs	x,b
		ldx	g.currentCDev,pcr
skipCR		jsr	[CDev.Read,x]
; Ignore LF, but only if it follows directly after a CR
		ldb	g.prevChar,pcr
		cmpb	#CR
		bne	notCR
		cmpa	#LF
		beq	skipCR
notCR		cmpa	#LF		; Convert LF on it's own to CR
		bne	notLF
		
		lda	#CR
notLF		sta	g.prevChar,pcr

		tst	g.echo,pcr
		beq	noEcho

		lbsr	putChar
noEcho		puls	b,x,pc


*******************************************************************
* putChar - write a character
*
* on entry: 
*	A: character to write
*
*  trashes: nothing
*
*  returns: nothing
*
		export putChar
putChar		pshs	b,x
		cmpa	#CR
		bne	pcNoCR
		ldb	#1		; Reset column number
		stb	g.currentColumn

pcNoCR		cmpa	#SPACE
		blt	pcNoInc
		cmpa	#DEL
		bge	pcNoInc
		ldb	#1
		addb	g.currentColumn
		stb	g.currentColumn

pcNoInc		ldx	g.currentCDev,pcr
		jsr	[CDev.Write,x]
		puls	b,x,pc

		end section
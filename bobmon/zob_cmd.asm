		import	g.argc
		import	g.argv
		import	g.linesPerPage

		import	putStr
		import	putHexByte
		import	putNL
		import	strToHex

		section code

		export	zobMinArgs
		export	zobMaxArgs
		export	zobCommand
		export	zobHelp
zobCommand	fcn	"zob"
zobHelp		fcn	"\tRun latest test code"

		export	zobFn
zobFn		lda	$8000
		lda	$8400
		lda	$8800
		lda	$8c00
		lda	$9000
		lda	$9400
		lda	$9800
		lda	$9c00

		bra	zobFn

zwDone		rts

		end section
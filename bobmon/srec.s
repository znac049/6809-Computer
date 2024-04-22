loadMoto	leax	loadMsg,pcr
		lbsr	putStr

srNext		lbsr	getChar
		cmpa	#CR
		beq	srNext
		cmpa	#LF
		beq	srNext
		cmpa	#3		; Ctrl-C
		lbeq	srQuit
		cmpa	#'S'
		lbne	srBadChar

* Nrxt byte is record type
       	        lbsr     getChar

		DbgS	'C'
		
		cmpa    #'0'
		lblt     srBadChar
		cmpa    #'9'
		lbgt     srBadChar
		sta	srType

* Next two bytes are count
       	        lbsr    getHexByte
		lbcs	srBadChar
		sta	srCount
		sta	srXSum		; Initialise checksum

* What comes next is record type specific

* ...Some records, we silently ignore
       		lda	srType
		cmpa	#'0'
		lbeq	srIgnore
		cmpa	#'5'
		lbeq	srIgnore
		cmpa	#'9'
		beq	srNine
		cmpa	#'1'
		lbeq	srOne
		lbra	srNotSupported


* S9 record - sets start address and terminates
* next 4 bytes are the start address
srNine
		lbsr	putNL
		lbsr	putNL

		lbsr	getHexWord
		lbcs	srBadChar
		std	srAddr

		DbgL	'A'

		adda	srXSum
		sta	srXSum
		addb	srXSum
		stb	srXSum

* Next byte will be the checksum
       	    	lbsr    getHexByte
		lbcs	srBadChar
		tfr	a,b

		DbgS	'X'

		lda	srXSum
		coma
		sta	srXSum

		cmpb	srXSum
		beq	sr9OK

		leax	srBadXSumMsg,pcr
		lbsr	putStr
		lbsr	srSkip
		lbra	srDone

sr9OK		leax	srLoadedMsg,pcr
		lbsr	putStr

		ldd	srAddr
		lbsr	putHexWord

		lbsr	putNL

		lbsr	srSkip
		lbra	srDone		; S9 record is always the last one, so quit loading

* S1 record - next 4 bytes are the load address
srOne		
		lbsr	getHexWord
		bcs	srBadChar
		std	srAddr

		adda	srXSum
		sta	srXSum
		addb	srXSum
		stb	srXSum

		ldd	srAddr
		lbsr	putHexWord
		lda	#CR
		lbsr	putChar

* prepare to read the data bytes		
		ldy	srAddr
		ldb	srCount
		clra
		subd	#3		; count included address and xsum
		tfr	d,x

* Read loop starts here
sr1Next
		lbsr	getHexByte
		bcs	srBadChar

		tfr	a,b
		addb	srXSum
		stb	srXSum

		sta	,y+		; Deposit byte at correct address

		leax	-1,x		; Count--
		beq	sr1DataDone

		bra	sr1Next		


sr1DataDone
* Next byte will be the checksum
       	    	lbsr    getHexByte
		bcs	srBadChar
		tfr	a,b

		lda	srXSum
		coma
		sta	srXSum

		cmpb	srXSum
		beq	sr1OK

		leax	srBadXSumMsg,pcr
		lbsr	putStr
		bsr	srSkip
		bra	srDone

sr1OK		bsr	srSkip
		lbra	srNext		; wait for the next record


* User wants to quit
srQuit		bsr	srSkip
		bra	srDone


* Ignore this record - it's harmless
srIgnore        bsr    	srSkip
		lbra	srNext		; wait for the next record

* We don't support all S records, in particular the ones that deal with
* a memory space bigger than 64K
srNotSupported	leax	srRecNotSupported,pcr
		lbsr	putStr
		lda	srType
		lbsr	putChar
		lbsr	putNL
		bra	srDone2

srBadChar	leax	srBadFormatMsg,pcr
		lbsr	putStr
srDone2		bsr	srSkip

srDone
		rts

* Skip the rest of the record
srSkip		lbsr	getChar
		cmpa	#CR
		beq	srsDone
		cmpa	#LF
		bne	srSkip
srsDone		rts



	
	
loadMsg		fcn	"Ok, waiting for S records on console..."
loadUsage	fcn	" - load program in S record format via the console"
srBadFormatMsg	fcn	"\r\nUnexpected character while reading S record.\r\n"
srRecNotSupported
		fcn	"\r\nUnsupported S record type: "
srBadXSumMsg	fcn	"\r\nCalculated checksum does not match transmitted checksum!\r\n"
srLoadedMsg	fcn	"\r\nLoaded OK. Start address: "

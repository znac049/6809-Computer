;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; load_cmd.s - Implements the "load" command, which will auto
;	detect intel hex or motorola S-records and load data
;	into memory, until and end record is found. The user changing
;	abort the load by pressing ctrl-C
;
		include "constants.s"

		import	g.argc
		import	g.argv
		import	g.echo

		import	putStr
		import	putNL
		import 	putChar
		import 	putHexWord
		import 	skipLine
		import	strToUpper
		import	fatValidDisk
		import 	getChar
		import	getHexByte
		import	getHexWord

		section globals

; Used by both ihex and srec loading
g.loadLength	rmb	1
g.loadAddress	rmb	2
g.loadType	rmb	1
g.loadXsum	rmb	1


		section code

		export	loadCommand
		export	loadHelp
loadCommand	fcn	"load"
loadHelp	fcc	"[ <filename> ]\tload from either console or disk:\r\n"
		fcc	"\tif filename supplied, load file in DECB format from disk\r\n"
		fcc	"\totherwise load intel hex records (types 0 and 1 only) or Motorola\r\n"
		fcn	"S-records from the terminal"

		export	loadFn
loadFn		lda	g.argc
		cmpa	#2
		bne	dlSerial

dlDisk		leax	attempt_msg,pcr
		lbsr	putStr

		leax	g.argv,pcr
		ldx	2,x
		lbsr	strToUpper
		lbsr	putStr
		lbsr	putNL

		lbsr	fatValidDisk
		tsta
		bne	dlNoDisk


		lbra	dlDone

dlNoDisk	leax	noDisk_msg,pcr
		lbsr	putStr
		lbra	dlDone


attempt_msg	fcn	"Looking for file on disk: "
noDisk_msg	fcn	"No disk or invalid disk\r\n"




dlSerial	leax	loading_msg,pcr
		lbsr	putStr

		lda	#1
		sta	g.echo,pcr

dlNextLine	lbsr	getChar
		cmpa	#CTRLC
		lbeq	dlAbort

		cmpa	#':'
		beq	loadiHex
		cmpa	#'S'
		lbeq	loadMoto
		cmpa	#'s'
		lbeq	loadMoto

; Gobble the rest of the line
dlSkipLine	lbsr	getChar
		cmpa	#CR
		beq	dlNextLine
		bra	dlSkipLine


loadiHex	leax	ihex_msg,pcr
		lbsr	putStr
lihNext		lbsr	loadiHexRecord
		* lbsr	putHexByte
		* lbsr	putNL
		tsta
		beq	dlError
		cmpa	#2
		beq	dlDone
; Read the start of the next record (should be ':')
		lbsr	getChar
		cmpa	#CTRLC
		beq	dlAbort
		cmpa	#':'
		beq	lihNext
		bra	dlError


loadMoto	leax	moto_msg,pcr
		lbsr	putStr
lmNext		lbsr	loadMotoRecord
		tsta
		beq	dlError
		cmpa	#2
		beq	dlDone
		lbsr	getChar
		cmpa	#CTRLC
		beq	dlAbort
		cmpa	#'S'
		beq	lmNext
		cmpa	#'s'
		beq	lmNext

dlError		leax	bad_fmt_msg,pcr
		lbsr	putStr
		bra	dlDone

dlAbort		leax	load_aborted_msg,pcr
		lbsr	putStr
		bra	dlEnd

dlDone		leax	load_ok_msg,pcr
		lbsr	putStr

dlEnd		clr	g.echo,pcr
		rts

loading_msg	fcn	"Waiting for data - press Ctrl-C to abort.\r\n"
ihex_msg	fcn	"Detected intel hex - loading...\r\n"
moto_msg	fcn	"Detected Motorola S-Records - loading...\r\n"
bad_fmt_msg	fcn	"Badly formatted record - aborted\r\n"
load_aborted_msg
		fcn	"\r\nAborted.\r\n"
load_ok_msg	fcn	"Loaded ok.\r\n"


*******************************************************************
* loadiHexRecord - read a single record (the first character of the
*	record has already been read and checked)
*
* on entry: none
*
*  trashes: nothing
*
*  returns:
*	A: 0=Error, 1=OK, 2=End record read
*
loadiHexRecord	pshs	b,x,y
		lbsr	getHexByte		; Length
		sta	g.loadLength
		sta	g.loadXsum

		lbsr	getHexWord		; Address
		std	g.loadAddress
		adda	g.loadXsum
		sta	g.loadXsum
		addb	g.loadXsum
		stb	g.loadXsum

		lbsr	getHexByte		; Type
		sta	g.loadType
		adda	g.loadXsum
		sta	g.loadXsum

; we only need type 00 and 01 records - ignore anything else
		lda	g.loadType
		cmpa	#0		; data record
		beq	lihData
		cmpa	#1
		beq	lihEndRecord
		
; Record type not supported. Whine and then abort.
		leax	load_not_supported_msg,pcr
		lbsr	putStr
		lbsr	skipLine
		lda	#0		; Error
		bra	lihEnd

lihData		ldx	g.loadAddress

		tfr	x,d
		lbsr	putHexWord
		lda	#CR
		lbsr	putChar

		ldb	g.loadLength
		beq	lihNoMoreData	; This would be unusual - a data record of 0 items

lihFetchDataByte lbsr	getHexByte
		
		sta	,x+

		adda	g.loadXsum
		sta	g.loadXsum

		decb
		bne	lihFetchDataByte

lihNoMoreData	bsr	getiHexChecksum
		bne	lihBadXsum	; The checksum didn't match the calculated checksum
; The checksums match, so we expect a CR to follow
		lbsr	getChar
		cmpa	#CR
		bne	lihBadFormat

		lda	#1		; All good
		bra	lihEnd


lihEndRecord	lbsr	putNL
* 		lbsr	skipLine
* 		bsr	getiHexChecksum	
* 		bne	lihBadXsum	; The checksum didn't match the calculated checksum
* ; The checksums match, so we expect a CR to follow
* 		lbsr	getChar
* 		cmpa	#CR
* 		bne	lihBadFormat
		lda	#2		; End record found
		bra	lihEnd

lihBadEOF	leax	load_eof_err_msg,pcr
		lbsr	putStr
		lbsr	skipLine
		clra			; Error
		bra	lihEnd

lihBadXsum	leax	load_xsum_err_msg,pcr
		lbsr	putStr
		clra			; Error
		bra	lihEnd

lihBadFormat	leax	bad_fmt_msg,pcr
		lbsr	putStr
		lda	#0		; Error
		
lihEnd		puls	b,x,y,pc



*******************************************************************
* getLoadCheckSum - read the checksum and compare it to the
*	calculated checksum
*
* on entry: none
*
*  trashes: nothing
*
*  returns:
*	CC: Z set if checksum maches calculated checksum (from g.loadXsum)
*
getiHexChecksum	pshs	a,b
		lbsr	getHexByte
		tfr	a,b
		lda	g.loadXsum
		coma
		adda	#1
		sta	g.loadXsum
		cmpb	g.loadXsum
		puls	a,b,pc

load_eof_err_msg
		fcn	"\r\nBadly formatted End of File record.\r\n"
load_xsum_err_msg
		fcn	"\r\nCalculated checksum does not match expected checksum.\r\n"
load_not_supported_msg
		fcn	"\r\nUnsupported record type found. We only support types 0 and 1.\r\n"



*******************************************************************
* loadMotoRecord - read a single record (the first character of the
*	record has already been read and checked)
*
* on entry: none
*
*  trashes: nothing
*
*  returns:
*	A: 0=Error, 1=OK, 2=End record read
*
loadMotoRecord	pshs	b,x,y

* Nrxt byte is record type
       	        lbsr     getChar

		cmpa    #'0'
		lblt     lmrBadChar
		cmpa    #'9'
		lbgt     lmrBadChar
		sta	g.loadType

* Next two bytes are count
       	        lbsr    getHexByte
		lbcs	lmrBadChar
		sta	g.loadLength
		sta	g.loadXsum		; Initialise checksum

* What comes next is record type specific

* ...Some records, we silently ignore
       		lda	g.loadType
		cmpa	#'0'
		lbeq	lmrIgnore
		cmpa	#'5'
		lbeq	lmrIgnore
		cmpa	#'9'
		beq	lmrNine
		cmpa	#'1'
		lbeq	lmrOne
		lbra	lmrNotSupported


* S9 record - sets start address and terminates
* next 4 bytes are the start address
lmrNine		lbsr	putNL

		lbsr	getHexWord
		lbcs	lmrBadChar
		std	g.loadAddress

		adda	g.loadXsum
		sta	g.loadXsum
		addb	g.loadXsum
		stb	g.loadXsum

* Next byte will be the checksum
       	    	lbsr    getHexByte
		lbcs	lmrBadChar
		tfr	a,b

		lda	g.loadXsum
		coma
		sta	g.loadXsum

		cmpb	g.loadXsum
		beq	lmrS9OK

		leax	lmr_bad_xsum_msg,pcr
		lbsr	putStr
		lbsr	skipLine
		lbra	lmrDone

lmrS9OK		ldd	g.loadAddress
		lda	#2		; End record success
		lbra	lmrDone		; S9 record is always the last one, so quit loading

* S1 record - next 4 bytes are the load address
lmrOne		
		lbsr	getHexWord
		lbcs	lmrBadChar
		std	g.loadAddress

		adda	g.loadXsum
		sta	g.loadXsum
		addb	g.loadXsum
		stb	g.loadXsum

		ldd	g.loadAddress
		lbsr	putHexWord
		lda	#CR
		lbsr	putChar

* prepare to read the data bytes		
		ldy	g.loadAddress
		ldb	g.loadLength
		clra
		subd	#3		; count included address and xsum
		tfr	d,x

* Read loop starts here
lmrS1Next	lbsr	getHexByte
		bcs	lmrBadChar

		tfr	a,b
		addb	g.loadXsum
		stb	g.loadXsum

		sta	,y+		; Deposit byte at correct address

		leax	-1,x		; Count--
		beq	lmrS1DataDone

		bra	lmrS1Next		


* Next byte will be the checksum
lmrS1DataDone  	lbsr    getHexByte
		bcs	lmrBadChar
		tfr	a,b

		lda	g.loadXsum
		coma
		sta	g.loadXsum

		cmpb	g.loadXsum
		beq	lmrS1OK

		leax	lmr_bad_xsum_msg,pcr
		lbsr	putStr
		lbsr	skipLine
		bra	lmrDone

lmrS1OK		lbsr	skipLine
		lda	#1		; Success
		bra	lmrDone


* * User wants to quit
* srQuit		lbsr	skipLine
* 		clra			; Error
* 		bra	lmrDone


* Ignore this record - it's harmless
lmrIgnore       lbsr    skipLine
		lda	#1		; Success
		bra	lmrDone


* We don't support all S records, in particular the ones that deal with
* a memory space bigger than 64K
lmrNotSupported	leax	lmr_record_not_supported,pcr
		lbsr	putStr
		lda	g.loadType
		lbsr	putChar
		lbsr	putNL
		lbsr	skipLine
		lda	#0		; Error
		bra	lmrDone

lmrBadChar	leax	lmr_bad_format_msg,pcr
		lbsr	putStr

lmrDone		puls	b,x,y,pc

	
lmr_bad_format_msg fcn	"\r\nUnexpected character while reading S record.\r\n"
lmr_record_not_supported
		fcn	"\r\nUnsupported S record type: "
lmr_bad_xsum_msg 
		fcn	"\r\nCalculated checksum does not match transmitted checksum!\r\n"

		end section
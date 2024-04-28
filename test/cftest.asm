;
; Found this here:
;	https://www.waveguide.se/?article=8-bit-compact-flash-interface
;

********************************
* COMPACT FLASH TEST PROGRAM
* FOR MC3
* DANIEL TUFVESSON 2013
********************************

********************************
* MONITOR LABLES
********************************
RETURN		EQU	$C000	RETURN TO PROMPT
OUTCHAR		EQU	$C003	OUTPUT CHAR ON CONSOLE
INCHAR		EQU	$C006	INPUT CHAR FROM CONSOLE AND ECHO
PDATA		EQU	$C009	PRINT TEXT STRING @ X ENDED BY $04
OUT2HS		EQU	$C012	PRINT 2 HEX CHARS @ X
OUT4HS		EQU	$C015	PRINT 4 HEX CHARS @ X
INBYTE		EQU	$C01B	INPUT 1 BYTE TO A. CARRY SET = OK

CONSVEC		EQU	$7FE5	CONSOLE STATUS VECTOR
CONOVEC		EQU	$7FE8	CONSOLE OUTPUT VECTOR
CONIVEC		EQU	$7FEB	CONSOLE INPUT VECTOR
	
********************************
* CF REGS
********************************
; ATA CF device registers
; When CS0 is asserted (low)
CF.Data		equ	0	; R/W
CF.Error	equ	1	; Read
CF.Features	equ 	1	; Write
CF.SecCnt	equ	2	; R/W
CF.LSN0		equ	3	; R/W - bits  0-7
CF.LSN1		equ	4	; R/W - bits  8-15
CF.LSN2		equ	5	; R/W - bits 16-23
CF.LSN3		equ	6	; R/W - bits 24-27
CF.Status	equ	7	; Read
CF.Command	equ	7	; Write


********************************
* START OF PROGRAM
********************************
		org	$1000

scGetChar	equ	0	; Input character with no parity
scPutChar	equ	1	; Output chaarcter
scPutStr	equ	2	; Print a string (EOS terminated)
scPutNLStr	equ	3	; Put CR/LF and string
scPut2Hex	equ	4	; Output two digit hex and a space
scPut4Hex	equ	5	; Output four digit hex and a space
scPutNL		equ	6
scPutSpace	equ	7
scTerminate	equ	8	; Reenter the monitor

CFDev		equ	$a100

CR		equ	13
LF		equ	10

		lbra	Main

m.Serial	fcn	CR,LF,"  Serial: "
m.Firmware	fcn	CR,LF,"Firmware: "
m.Model		fcn	CR,LF,"   Model: "
m.LBA		fcn	CR,LF,"LBA Size: "

m.Prompt	fcn	CR,LF,"-> "
m.BadCmd	fcn	"Bad command"

cfLBA3		rmb	1
cfLBA2		rmb	1
cfLBA1		rmb 	1
cfLBA0		rmb	1

cfBuff		rmb	512


Main		clra
		sta	cfLBA3	
		sta	cfLBA2
		sta	cfLBA1	
		sta	cfLBA0

		ldx	#CFDev
		lbsr	CFInit

mainLoop	leax	m.Prompt,pcr
		swi
		fcb	scPutStr
		
		swi
		fcb	scGetChar
		anda	#$DF		; Convert to uc

		cmpa	#'Q'		; Quit
		bne	mlNoQuit

		swi
		fcb	scTerminate

mlNoQuit	cmpa	#'I'		; Print CF Info
		bne	mlNoInfo
		
		swi
		fcb	scPutNL
		bsr	CFInfo
		bra	mainLoop
		
mlNoInfo	cmpa	#'R'		; Read command
		bne	mlBad
		
		bra	mainLoop
	
mlBad		leax	m.BadCmd,pcr
		swi
		fcb	scPutStr
		bra	mainLoop

		lbsr	CFInit
		lbsr	CFInfo


********************************
* INITIALIZE CF
********************************
CFInit		pshs	a
		lda	#$04		; Reset command
		sta	CF.Command,x
		bsr	CFWait

		lda	#$e0		; LBA3=0, MASTER, MODE=LBA
		sta	CF.LSN3,x
	
		lda	#$01		; 8-bit transfers
		sta	CF.Features,x

		lda	#$EF		; Set feature command
		sta	CF.Command,x
		bsr	CFWait
		bsr	CFCheckError

		puls	a,pc


********************************
* WAIT FOR CF READY
********************************
CFWait		pshs	a
		lda	CF.Status,x
		anda	#$80	; Busy flag
		bne	CFWait

		puls	a,pc


********************************
* CHECK FOR CF ERROR
********************************

CFCheckError	pshs	a
		lda	CF.Status,x
		anda	#$1	; Check error bit
		beq	cfceDone

		lda	#'!'
		swi
		fcb	scPutChar
		lda	CF.Status,x
		swi
		fcb	scPut2Hex
cfceDone	puls	a,pc


********************************
* READ DATA FROM CF
********************************

CFRead		pshs	a
		bsr	CFWait
		lda	CF.Status,x
		anda	#$08	; DRQ?
		beq	cfrDone
		lda	CF.Data,x
		sta	,y+
		bra	CFRead

cfrDone		puls	a,pc


********************************
* CF SET LBA
********************************
CFSetLBA	pshs	a
		lda	cfLBA0
		sta	CF.LSN0,x
		lda	cfLBA1
		sta	CF.LSN1,x
		lda	cfLBA2
		sta	CF.LSN2,x
		lda	cfLBA3
		anda	#$0F
		ora	#$E0
		sta	CF.LSN3
		puls	a,pc


********************************
* PRINT CF INFORMATION
********************************
CFInfo		ldx	#CFDev
		bsr	CFWait
		lda	#$EC		; Drive ID command
		sta	CF.Command,x
		leay	cfBuff,pcr
		bsr	CFRead
		swi
		fcb	scPutNL

; Print Serial number
		leax	m.Serial,pcr
		swi
		fcb	scPutStr

		leax	cfBuff,pcr
		leax	20,x
		lda	#20
		bsr	PRTRSN

; Print Firmware Revision
		leax	m.Firmware,pcr
		swi
		fcb	scPutStr
		leax	cfBuff,pcr
		leax	46,x
		lda	#8
		bsr	PRTRN

; Print Model Number
		leax	m.Model,pcr
		swi
		fcb	scPutStr
		leax	cfBuff,pcr
		leax	54,x
		lda	#40
		bsr	PRTRN

; Print LBA Size
		leax	m.Model,pcr
		swi
		fcb	scPutStr
		leax	cfBuff,pcr
		leax	123,x
		ldd	,x--
		swi
		fcb	scPut2Hex
		ldd	,x--
		swi
		fcb	scPut2Hex
		ldd	,x--
		swi
		fcb	scPut2Hex

		swi
		fcb	scPutNL
		rts


********************************
* PRINT BIG ENDIAN STRING OF N CHARS
* IN: X=ADDR, B=NCHARS
********************************
PRTRN		lda	1,x
		swi
		fcb	scPutChar
		lda	0,x
		swi
		fcb	scPutChar
		decb
		cmpb	#0
		beq	PRTRNDone
		decb
		cmpb	#0
		beq	PRTRNDone
		leax	2,x
		bra	PRTRN
PRTRNDone	rts

********************************
* PRINT BIG ENDIAN STRING OF N CHARS
* SKIPPING ALL SPACES
* IN: X=ADDR, B=NCHARS
********************************
PRTRSN		lda	1,x
		cmpa	#' '
		beq	1F
		swi
		fcb	scPutChar
1		lda	0,x
		cmpa	#' '
		beq	2F
		swi
		fcb	scPutChar
2		decb
		cmpb	#0
		beq	PRTRSNDone
		decb
		cmpb	#0
		beq	PRTRSNDone
		leax	2,x
		bra	PRTRSN
PRTRSNDone	rts

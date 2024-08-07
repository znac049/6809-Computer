;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; syscalls.s - System calls which a program can call via thw SWI
;	instruction. . The byte immediately following the SWI 
;	instruction will contain the system call number.
;

		include "constants.s"

		import	getChar
		import	putChar
		import	putStr
		import	putNL
		import	putHexByte
		import	putHexWord

		import	appTerminated

;
; System calls
;
scGetChar	equ	0	; Input character with no parity
scPutChar	equ	1	; Output chaarcter
scPutStr	equ	2	; Print a string (EOS terminated)
scPutNLStr	equ	3	; Put CR/LF and string
scPut2Hex	equ	4	; Output two digit hex and a space
scPut4Hex	equ	5	; Output four digit hex and a space
scPutNL		equ	6
scPutSpace	equ	7
scTerminate	equ	8	; Reenter the monitor

; Top of stack on entry to swi handler
;
; 6809:
swiCC		equ	0
swiAreg		equ	1
swiBreg		equ	2
swiDPreg	equ	3
swiXreg		equ	4
swiYreg		equ	6
swiUreg		equ	8
swiPC		equ	10

		section code

*******************************************************************
* handle_swi - take care of routing the system call to the correct
*	handler.
*
* on entry: Different, depending on the requirements of the specific
*	system call.
*
*  trashes: nothing
*
*  returns: Depends on the system call
*
		export handle_swi
handle_swi	ldu	10,s			; U points at the return address
	
		lda     ,u			; ld fn code
		
		leau	1,u			; Modify the return address to skip over
						; the fn byte following SWI instruction
		stu	10,s			; Put the modified return address back on the stack
            
		cmpa    #0
		blt     SWIDone
		cmpa    #SWIMax
		bge     SWIDone
            
		asla				; Calculate offset into jump table
		leau    SWITable,pcr
		ldd     a,u
		jmp     d,u

	
SWITable	fdb     sysGetChar-SWITable
		fdb     sysPutChar-SWITable
		fdb	sysPutStr-SWITable
		fdb	sysPutNLStr-SWITable
		fdb	sysPut2Hex-SWITable
		fdb	sysPut4Hex-SWITable
		fdb	sysPutNL-SWITable
		fdb	sysPutSpace-SWITable
		fdb	sysTerminate-SWITable
SWIend		equ	*
SWIMax		equ	(SWIend-SWITable)/2
SWIDone		rti				; Function code was out of bounds - just return

sysGetChar	lbsr	getChar
		anda	#$7f			; Strip parity
		cmpa	#CR
		bne	notCR
		lda	#LF
notCR		sta	swiAreg,S
		rti

sysPutChar	lda	swiAreg,s
		lbsr    putChar
		rti

sysPutStr	lbsr	putStr
		rti

sysPutNLStr	lbsr	putNL
		ldx	swiXreg,S
		lbsr	putStr
		rti

sysPut2Hex	lda	swiAreg,s
		lbsr	putHexByte
		lda	#SPACE
		lbsr	putChar
		rti

sysPut4Hex	lda	swiAreg,s
		ldb	swiBreg,s
		lbsr	putHexWord
		lda	#SPACE
		lbsr	putChar
		rti

sysPutNL	lbsr	putNL
		rti

sysPutSpace	lda	#SPACE
		lbsr	putChar
		rti

sysTerminate	ldx	#appTerminated
		* lda	#42
		* sta	swiAreg,s
		* sta	swiBreg,s
		stx	swiPC,s		; tweak the return address
		rti

		end section
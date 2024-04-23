;
; 6809 Disassembler
;
; Copyright (C) 2019 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
;
; Revision History
; Version Date         Comments
; 0.0     29-Jan-2019  First version started, based on 6502 code.
; 0.1     03-Feb-2019  All instructions now supported.
;
; To Do:
; - Other TODOs in code
; - Add option to suppress data bytes in output (for feeding back into assembler)
; - Add option to show invalid opcodes as constants
; - Some unwanted spaces in output due to use of ASSIST09 routines
			
; Character defines
			
PAGELEN		equ	24	; Number of instructions to show before waiting for keypress
			
; ASSIST09 SWI call numbers
			
INCHNP		equ	0	; INPUT CHAR IN A REG - NO PARITY
OUTCH		equ	1	; OUTPUT CHAR FROM A REG
PDATA1		equ	2	; OUTPUT STRING
PDATA		equ	3	; OUTPUT CR/LF THEN STRING
OUT2HS		equ	4	; OUTPUT TWO HEX AND SPACE
OUT4HS		equ	5	; OUTPUT FOUR HEX AND SPACE
PCRLF		equ	6	; OUTPUT CR/LF
SPAAACE		equ	7	; OUTPUT A SPACE
MONITR		equ	8	; ENTER ASSIST09 MONITOR
VCTRSW		equ	9	; VECTOR EXAMINE/SWITCH
BRKPT		equ	10	; USER PROGRAM BREAKPOINT
PAUSE		equ	11	; TASK PAUSE FUNCTION
			
; Instructions. Matches indexes into entries in table MNEMONICS.
			
OP_INV		equ	$00
OP_ABX		equ	$01
OP_ADCA		equ	$02
OP_ADCB		equ	$03
OP_ADDA		equ	$04
OP_ADDB		equ	$05
OP_ADDD		equ	$06
OP_ANDA		equ	$07
OP_ANDB		equ	$08
OP_ANDCC	equ	$09
OP_ASL		equ	$0A
OP_ASLA		equ	$0B
OP_ASLB		equ	$0C
OP_ASR		equ	$0D
OP_ASRA		equ	$0E
OP_ASRB		equ	$0F
OP_BCC		equ	$10
OP_BCS		equ	$11
OP_BEQ		equ	$12
OP_BGE		equ	$13
OP_BGT		equ	$14
OP_BHI		equ	$15
OP_BITA		equ	$16
OP_BITB		equ	$17
OP_BLE		equ	$18
OP_BLS		equ	$19
OP_BLT		equ	$1A
OP_BMI		equ	$1B
OP_BNE		equ	$1C
OP_BPL		equ	$1D
OP_BRA		equ	$1E
OP_BRN		equ	$1F
OP_BSR		equ	$20
OP_BVC		equ	$21
OP_BVS		equ	$22
OP_CLR		equ	$23
OP_CLRA		equ	$24
OP_CLRB		equ	$25
OP_CMPA		equ	$26
OP_CMPB		equ	$27
OP_CMPD		equ	$28
OP_CMPS		equ	$29
OP_CMPU		equ	$2A
OP_CMPX		equ	$2B
OP_CMPY		equ	$2C
OP_COMA		equ	$2D
OP_COMB		equ	$2E
OP_COM		equ	$2F
OP_CWAI		equ	$30
OP_DAA		equ	$31
OP_DEC		equ	$32
OP_DECA		equ	$33
OP_DECB		equ	$34
OP_EORA		equ	$35
OP_EORB		equ	$36
OP_EXG		equ	$37
OP_INC		equ	$38
OP_INCA		equ	$39
OP_INCB		equ	$3A
OP_JMP		equ	$3B
OP_JSR		equ	$3C
OP_LBCC		equ	$3D
OP_LBCS		equ	$3E
OP_LBEQ		equ	$3F
OP_LBGE		equ	$40
OP_LBGT		equ	$41
OP_LBHI		equ	$42
OP_LBLE		equ	$43
OP_LBLS		equ	$44
OP_LBLT		equ	$45
OP_LBMI		equ	$46
OP_LBNE		equ	$47
OP_LBPL		equ	$48
OP_LBRA		equ	$49
OP_LBRN		equ	$4A
OP_LBSR		equ	$4B
OP_LBVC		equ	$4C
OP_LBVS		equ	$4D
OP_LDA		equ	$4E
OP_LDB		equ	$4F
OP_LDD		equ	$50
OP_LDS		equ	$51
OP_LDU		equ	$52
OP_LDX		equ	$53
OP_LDY		equ	$54
OP_LEAS		equ	$55
OP_LEAU		equ	$56
OP_LEAX		equ	$57
OP_LEAY		equ	$58
OP_LSR		equ	$59
OP_LSRA		equ	$5A
OP_LSRB		equ	$5B
OP_MUL		equ	$5C
OP_NEG		equ	$5D
OP_NEGA		equ	$5E
OP_NEGB		equ	$5F
OP_NOP		equ	$60
OP_ORA		equ	$61
OP_ORB		equ	$62
OP_ORCC		equ	$63
OP_PSHS		equ	$64
OP_PSHU		equ	$65
OP_PULS		equ	$66
OP_PULU		equ	$67
OP_ROL		equ	$68
OP_ROLA		equ	$69
OP_ROLB		equ	$6A
OP_ROR		equ	$6B
OP_RORA		equ	$6C
OP_RORB		equ	$6D
OP_RTI		equ	$6E
OP_RTS		equ	$6F
OP_SBCA		equ	$70
OP_SBCB		equ	$71
OP_SEX		equ	$72
OP_STA		equ	$73
OP_STB		equ	$74
OP_STD		equ	$75
OP_STS		equ	$76
OP_STU		equ	$77
OP_STX		equ	$78
OP_STY		equ	$79
OP_SUBA		equ	$7A
OP_SUBB		equ	$7B
OP_SUBD		equ	$7C
OP_SWI		equ	$7D
OP_SWI2		equ	$7E
OP_SWI3		equ	$7F
OP_SYNC		equ	$80
OP_TFR		equ	$81
OP_TST		equ	$82
OP_TSTA		equ	$83
OP_TSTB		equ	$84
			
; Addressing Modes. OPCODES table lists these for each instruction.
; LENGTHS lists the instruction length for each addressing mode.
; Need to distinguish relative modes that are 2 and 3 (long) bytes.
; Some immediate are 2 and some 3 bytes.
; Indexed modes can be longer depending on postbyte.
; Page 2 and 3 opcodes are one byte longer (prefixed by 10 or 11)
			
AM_INVALID	equ	0	; $01 (1)
AM_INHERENT	equ	1	; RTS (1)
AM_IMMEDIATE8	equ	2	; LDA #$12 (2)
AM_IMMEDIATE16	equ	3	; LDD #$1234 (3)
AM_DIRECT	equ	4	; LDA $12 (2)
AM_EXTENDED	equ	5	; LDA $1234 (3)
AM_RELATIVE8	equ	6	; BSR $1234 (2)
AM_RELATIVE16	equ	7	; LBSR $1234 (3)
AM_INDEXED	equ	8	; LDA 0,X (2+)
			
; *** CODE ***
			
; Main program. Disassembles a page at a time.
			
UNASS			
PAGE		lda	#PAGELEN	; Number of instructions to disassemble per page
DIS		pshs	A		; Save A
		lbsr	Disassemble	; Do disassembly of one instruction
		puls	A		; Restore A
		deca			; Decrement count
		bne	DIS		; Go back and repeat until a page has been done
		leax	MSG2,PCR	; Display message to press a key
		lbsr	putStr
BADKEY		bsr	GetChar		; Wait for keyboard input
		lbsr	putNL
		cmpa	#SPACE		; Space key pressed?
		beq	PAGE		; If so, display next page
		cmpa	#'Q		; Q key pressed?
		beq	RETN		; If so, return
		cmpa	#'q		; q key pressed?
		beq	RETN		; If so, return
		lbsr	putStr		; Bad key, prompt and try again
		bra	BADKEY
RETN		rts			; Return to caller
			
; *** Utility Functions ***
; Some of these call ASSIST09 ROM monitor routines.
			
; Print dollar sign to the console.
; Registers changed: none
PrintDollar		
		pshs	A	; Save A
		lda	#'$
		lbsr	putChar
		puls	A	; Restore A
		rts	
			
; Print comma to the console.
; Registers changed: none
PrintComma		
		pshs	A	; Save A
		lda	#',
		lbsr	putChar
		puls	A	; Restore A
		rts	
			
; Print left square bracket to the console.
; Registers changed: none
PrintLBracket		
		pshs	A	; Save A
		lda	#'[
		lbsr	putChar
		puls	A	; Restore A
		rts	
			
; Print right square bracket to the console.
; Registers changed: none
PrintRBracket		
		pshs	A	; Save A
		lda	#']
		lbsr	putChar
		puls	A	; Restore A
		rts	
			
; Print space sign to the console.
; Registers changed: none
PrintSpace		
		lda	#SPACE
		lbsr	putChar
		rts	
			
; Print two spaces to the console.
; Registers changed: none
Print2Spaces		
		pshs	A	; Save A
		lda	#SPACE
		lbsr	putChar
		lbsr	putChar
		puls	A	; Restore A
		rts	
			
; Print several space characters.
; A contains number of spaces to print.
; Registers changed: none
PrintSpaces		
		pshs	A	; Save registers used
PS1		cmpa	#0	; Is count zero?
		beq	PS2	; Is so, done
		bsr	PrintSpace	; Print a space
		deca			; Decrement count
		bra	PS1	; Check again
PS2		puls	A	; Restore registers used
		rts	
			
; Get character from the console
; A contains character read. Blocks until key pressed. Character is
; echoed. Ignores NULL ($00) and RUBOUT ($7F). CR ($OD) is converted
; to LF ($0A).
; Registers changed: none (flags may change). Returns char in A.
GetChar			
		swi			; Call ASSIST09 monitor function
		fcb	INCHNP	; Service code byte
		rts	
			
; Print a byte as two hex digits followed by a space.
; A contains byte to print.
; Registers changed: none
PrintByte		
		pshs	A,B,X	; Save registers used
		sta	TEMP	; Needs to be in memory so we can point to it
		leax	TEMP,PCR	; Get pointer to it
		swi			; Call ASSIST09 monitor function
		fcb	OUT2HS	; Service code byte
		puls	X,B,A	; Restore registers used
		rts	
			
; Print a word as four hex digits followed by a space.
; X contains word to print.
; Registers changed: none
PrintAddress		
		pshs	A,B,X	; Save registers used
		stx	TEMP	; Needs to be in memory so we can point to it
		leax	TEMP,PCR	; Get pointer to it
		swi			; Call ASSIST09 monitor function
		fcb	OUT4HS	; Service code byte
		puls	X,B,A	; Restore registers used
		rts	
			
; Disassemble instruction at address ADDR. On return, ADDR points to
; next instruction so it can be called again.
			
Disassemble	clr	PAGE23	; Clear page2/3 flag
		ldx	dump_address,pcr	; Get address of instruction
		ldb	,X	; Get instruction op code
		cmpb	#$10	; Is it a page 2 16-bit opcode prefix with 10?
		beq	handle10	; If so, do special handling
		cmpb	#$11	; Is it a page 3 16-bit opcode prefix with 11?
		beq	handle11	; If so, do special handling
		lbra	not1011	; If not, handle as normal case
			
handle10				; Handle page 2 instruction
		lda	#1	; Set page2/3 flag
		sta	PAGE23
		ldb	1,X	; Get real opcode
		stb	OPCODE	; Save it.
		leax	PAGE2,PCR	; Pointer to start of table
		clra			; Set index into table to zero
search10		
		cmpb	A,X	; Check for match of opcode in table
		beq	found10	; Branch if found
		adda	#3	; Advance to next entry in table (entries are 3 bytes long)
		tst	A,X	; Check entry
		beq	notfound10	; If zero, then reached end of table
		bra	search10	; If not, keep looking
			
notfound10				; Instruction not found, so is invalid.
		lda	#$10	; Set opcode to 10
		sta	OPCODE
		lda	#OP_INV	; Set as instruction type invalid
		sta	OPTYPE
		lda	#AM_INVALID	; Set as addressing mode invalid
		sta	AM
		lda	#1	; Set length to one
		sta	LEN
		lbra	dism	; Disassemble as normal
			
found10					; Found entry in table
		adda	#1	; Advance to instruction type entry in table
		ldb	A,X	; Get instruction type
		stb	OPTYPE	; Save it
		adda	#1	; Advanced to address mode entry in table
		ldb	A,X	; Get address mode
		stb	AM	; Save it
		clra			; Clear MSB of D, addressing mode is now in A:B (D)
		tfr	D,X	; Put addressing mode in X
		ldb	LENGTHS,X	; Get instruction length from table
		stb	LEN	; Store it
		inc	LEN	; Add one because it is a two byte op code
		bra	dism	; Continue normal disassembly processing.
			
handle11				; Same logic as above, but use table for page 3 opcodes.
		lda	#1	; Set page2/3 flag
		sta	PAGE23
		ldb	1,X	; Get real opcode
		stb	OPCODE	; Save it.
		leax	PAGE3,PCR	; Pointer to start of table
		clra			; Set index into table to zero
search11		
		cmpb	A,X	; Check for match of opcode in table
		beq	found11	; Branch if found
		adda	#3	; Advance to next entry in table (entries are 3 bytes long)
		tst	A,X	; Check entry
		beq	notfound11	; If zero, then reached end of table
		bra	search11	; If not, keep looking
			
notfound11				; Instruction not found, so is invalid.
		lda	#$11	; Set opcode to 10
		sta	OPCODE
		lda	#OP_INV	; Set as instruction type invalid
		sta	OPTYPE
		lda	#AM_INVALID	; Set as addressing mode invalid
		sta	AM
		lda	#1	; Set length to one
		sta	LEN
		bra	dism	; Disassemble as normal
			
found11					; Found entry in table
		adda	#1	; Advance to instruction type entry in table
		ldb	A,X	; Get instruction type
		stb	OPTYPE	; Save it
		adda	#1	; Advanced to address mode entry in table
		ldb	A,X	; Get address mode
		stb	AM	; Save it
		clra			; Clear MSB of D, addressing mode is now in A:B (D)
		tfr	D,X	; Put addressing mode in X
		ldb	LENGTHS,X	; Get instruction length from table
		stb	LEN	; Store it
		inc	LEN	; Add one because it is a two byte op code
		bra	dism	; Continue normal disassembly processing.
			
not1011			
		stb	OPCODE	; Save the op code
		clra			; Clear MSB of D
		tfr	D,X	; Put op code in X
		ldb	OPCODES,X	; Get opcode type from table
		stb	OPTYPE	; Store it
		ldb	OPCODE	; Get op code again
		tfr	D,X	; Put opcode in X
		ldb	MODES,X	; Get addressing mode type from table
		stb	AM	; Store it
		tfr	D,X	; Put addressing mode in X
		ldb	LENGTHS,X	; Get instruction length from table
		stb	LEN	; Store it
			
; If addressing mode is indexed, get and save the indexed addressing
; post byte.
			
dism		lda	AM	; Get addressing mode
		cmpa	#AM_INDEXED	; Is it indexed mode?
		bne	NotIndexed	; Branch if not
		ldx	dump_address,PCR	; Get address of op code
					; If it is a page2/3 instruction, op code is the next byte after ADDR
		tst	PAGE23	; Page2/3 instruction?
		beq	norm	; Branch if not
		lda	2,X	; Post byte is two past ADDR
		bra	getpb
norm		lda	1,X	; Get next byte (the post byte)
getpb		sta	POSTBYT	; Save it
			
; Determine number of additional bytes for indexed addressing based on
; postbyte. If most significant bit is 0, there are no additional
; bytes and we can skip the rest of the check.
			
		bpl	NotIndexed	; Branch of MSB is zero
			
; Else if most significant bit is 1, mask off all but low order 5 bits
; and look up length in table.
			
		anda	#%00011111	; Mask off bits
		leax	POSTBYTES,PCR	; Lookup table of lengths
		lda	A,X	; Get table entry
		adda	LEN	; Add to instruction length
		sta	LEN	; Save new length
			
NotIndexed		
			
; Print address followed by a space
		ldx	dump_address,PCR
		lbsr	PrintAddress
			
; Print one more space
			
		lbsr	PrintSpace
			
; Print the op code bytes based on the instruction length
			
		ldb	LEN	; Number of bytes in instruction
		ldx	dump_address,PCR	; Pointer to start of instruction
opby		lda	,X+	; Get instruction byte and increment pointer
		lbsr	PrintByte	; Print it, followed by a space
		decb			; Decrement byte count
		bne	opby	; Repeat until done
			
; Print needed remaining spaces to pad out to correct column
			
		leax	PADDING,PCR	; Pointer to start of lookup table
		lda	LEN	; Number of bytes in instruction
		deca			; Subtract 1 since table starts at 1, not 0
		lda	A,X	; Get number of spaces to print
		lbsr	PrintSpaces
			
; If a page2/3 instruction, advance ADDR to the next byte which points
; to the real op code.
			
		tst	PAGE23	; Flag set
		beq	noinc	; Branch if not
		ldd	dump_address	; Increment 16-bit address
		addd	#1
		std	dump_address
			
; Get and print mnemonic (4 chars)
			
noinc		ldb	OPTYPE	; Get instruction type to index into table
		clra			; Clear MSB of D
		aslb			; 16-bit shift of D: Rotate B, MSB into Carry
		rola			; Rotate A, Carry into LSB
		aslb			; Do it twice to multiple by four
		rola			; 
		leax	MNEMONICS,PCR	; Pointer to start of table
		sta	TEMP1	; Save value of A
		lda	D,X	; Get first char of mnemonic
		lbsr	putChar	; Print it
		lda	TEMP1	; Restore value of A
		incb			; Advance pointer
		lda	D,X	; Get second char of mnemonic
		lbsr	putChar	; Print it
		lda	TEMP1	; Restore value of A
		incb			; Advance pointer
		lda	D,X	; Get third char of mnemonic
		lbsr	putChar	; Print it
		lda	TEMP1	; Restore value of A
		incb			; Advance pointer
		lda	D,X	; Get fourth char of mnemonic
		lbsr	putChar	; Print it
			
; Display any operands based on addressing mode and call appropriate
; routine. TODO: Could use a lookup table for this.
			
		lda	AM	; Get addressing mode
		cmpa	#AM_INVALID
		beq	DO_INVALID
		cmpa	#AM_INHERENT
		beq	DO_INHERENT
		cmpa	#AM_IMMEDIATE8
		beq	DO_IMMEDIATE8
		cmpa	#AM_IMMEDIATE16
		lbeq	DO_IMMEDIATE16
		cmpa	#AM_DIRECT
		lbeq	DO_DIRECT
		cmpa	#AM_EXTENDED
		lbeq	DO_EXTENDED
		cmpa	#AM_RELATIVE8
		lbeq	DO_RELATIVE8
		cmpa	#AM_RELATIVE16
		lbeq	DO_RELATIVE16
		cmpa	#AM_INDEXED
		lbeq	DO_INDEXED
		bra	DO_INVALID	; Should never be reached
			
DO_INVALID				; Display "   ; INVALID"
		lda	#15	; Want 15 spaces
		lbsr	PrintSpaces
		leax	MSG1,PCR
		lbsr	putStr
		lbra	done
			
DO_INHERENT				; Nothing else to do
		lbra	done
			
DO_IMMEDIATE8		
		lda	OPTYPE	; Get opcode type
		cmpa	#OP_TFR	; Is is TFR?
		beq	XFREXG	; Handle special case of TFR
		cmpa	#OP_EXG	; Is is EXG?
		beq	XFREXG	; Handle special case of EXG
			
		cmpa	#OP_PULS	; Is is PULS?
		lbeq	PULPSH
		cmpa	#OP_PULU	; Is is PULU?
		lbeq	PULPSH
		cmpa	#OP_PSHS	; Is is PSHS?
		lbeq	PULPSH
		cmpa	#OP_PSHU	; Is is PSHU?
		lbeq	PULPSH
					; Display "  #$nn"
		lbsr	Print2Spaces	; Two spaces
		lda	#'#	; Number sign
		lbsr	putChar
		lbsr	PrintDollar	; Dollar sign
		ldx	dump_address,PCR	; Get address of op code
		lda	1,X	; Get next byte (immediate data)
		lbsr	PrintByte	; Print as hex value
		lbra	done
			
XFREXG					; Handle special case of TFR and EXG
					; Display "  r1,r2"
		lbsr	Print2Spaces	; Two spaces
		ldx	dump_address,PCR	; Get address of op code
		lda	1,X	; Get next byte (postbyte)
		anda	#%11110000	; Mask out source register bits
		lsra			; Shift into low order bits
		lsra	
		lsra	
		lsra	
		bsr	TFREXGRegister	; Print source register name
		lda	#',	; Print comma
		lbsr	putChar
		lda	1,X	; Get postbyte again
		anda	#%00001111	; Mask out destination register bits
		bsr	TFREXGRegister	; Print destination register name
		lbra	done
			
; Look up register name (in A) from Transfer/Exchange postbyte. 4 LSB
; bits determine the register name. Value is printed. Invalid value
; is shown as '?'.
; Value:    0 1 2 3 4 5  8 9 10 11
; Register: D X Y U S PC A B CC DP
			
TFREXGRegister		
		cmpa	#0
		bne	Try1
		lda	#'D
		bra	Print1Reg
Try1		cmpa	#1
		bne	Try2
		lda	#'X
		bra	Print1Reg
Try2		cmpa	#2
		bne	Try3
		lda	#'Y
		bra	Print1Reg
Try3		cmpa	#3
		bne	Try4
		lda	#'U
		bra	Print1Reg
Try4		cmpa	#4
		bne	Try5
		lda	#'S
		bra	Print1Reg
Try5		cmpa	#5
		bne	Try8
		lda	#'P
		ldb	#'C
		bra	Print2Reg
Try8		cmpa	#8
		bne	Try9
		lda	#'A
		bra	Print1Reg
Try9		cmpa	#9
		bne	Try10
		lda	#'B
		bra	Print1Reg
Try10		cmpa	#10
		bne	Try11
		lda	#'C
		ldb	#'C
		bra	Print2Reg
Try11		cmpa	#11
		bne	Inv
		lda	#'D
		ldb	#'P
		bra	Print2Reg
Inv		lda	#'?	; Invalid
					; Fall through
Print1Reg		
		lbsr	putChar	; Print character
		rts	
Print2Reg		
		lbsr	putChar	; Print first character
		tfr	B,A
		lbsr	putChar	; Print second character
		rts	
			
; Handle PSHS/PSHU/PULS/PULU instruction operands
; Format is a register list, eg; "  A,B,X"
			
PULPSH			
		lbsr	Print2Spaces	; Two spaces
		lda	#1
		sta	FIRST	; Flag set before any items printed
		ldx	dump_address,PCR	; Get address of op code
		lda	1,X	; Get next byte (postbyte)
			
; Postbyte bits indicate registers to push/pull when 1.
; 7  6   5 4 3  2 1 0
; PC S/U Y X DP B A CC
			
; TODO: Could simplify this with shifting and lookup table.
			
		bita	#%10000000	; Bit 7 set?
		beq	bit6
		pshs	A,B
		lda	#'P
		ldb	#'C
		bsr	Print2Reg	; Print PC
		clr	FIRST
		puls	A,B
bit6		bita	#%01000000	; Bit 6 set?
		beq	bit5
			
; Need to show S or U depending on instruction
			
		pshs	A	; Save postbyte
		lda	OPTYPE	; Get opcode type
		cmpa	#OP_PULS
		beq	printu
		cmpa	#OP_PSHS
		beq	printu
		lbsr	PrintCommaIfNotFirst
		lda	#'S	; Print S
pr1		bsr	Print1Reg
		clr	FIRST
		puls	A
		bra	bit5
printu		bsr	PrintCommaIfNotFirst
		lda	#'U	; Print U
		bra	pr1
bit5		bita	#%00100000	; Bit 5 set?
		beq	bit4
		pshs	A
		bsr	PrintCommaIfNotFirst
		lda	#'Y
		bsr	Print1Reg	; Print Y
		clr	FIRST
		puls	A
bit4		bita	#%00010000	; Bit 4 set?
		beq	bit3
		pshs	A
		bsr	PrintCommaIfNotFirst
		lda	#'X
		bsr	Print1Reg	; Print X
		clr	FIRST
		puls	A
bit3		bita	#%00001000	; Bit 3 set?
		beq	bit2
		pshs	A,B
		bsr	PrintCommaIfNotFirst
		lda	#'D
		ldb	#'P
		bsr	Print2Reg	; Print DP
		clr	FIRST
		puls	A,B
bit2		bita	#%00000100	; Bit 2 set?
		beq	bit1
		pshs	A
		bsr	PrintCommaIfNotFirst
		lda	#'B
		lbsr	Print1Reg	; Print B
		clr	FIRST
		puls	A
bit1		bita	#%00000010	; Bit 1 set?
		beq	bit0
		pshs	A
		bsr	PrintCommaIfNotFirst
		lda	#'A
		lbsr	Print1Reg	; Print A
		clr	FIRST
		puls	A
bit0		bita	#%00000001	; Bit 0 set?
		beq	done1
		pshs	A,B
		bsr	PrintCommaIfNotFirst
		lda	#'C
		ldb	#'C
		lbsr	Print2Reg	; Print CC
		clr	FIRST
		puls	A,B
done1		lbra	done
			
; Print comma if FIRST flag is not set.
PrintCommaIfNotFirst 	
		tst	FIRST
		bne	ret1
		lda	#',
		lbsr	putChar
ret1		rts	
			
DO_IMMEDIATE16				; Display "  #$nnnn"
		lbsr	Print2Spaces	; Two spaces
		lda	#'#	; Number sign
		lbsr	putChar
		lbsr	PrintDollar	; Dollar sign
		ldx	dump_address,PCR	; Get address of op code
		lda	1,X	; Get first byte (immediate data MSB)
		ldb	2,X	; Get second byte (immediate data LSB)
		tfr	D,X	; Put in X to print
		lbsr	PrintAddress	; Print as hex value
		lbra	done
			
DO_DIRECT				; Display "  $nn"
		lbsr	Print2Spaces	; Two spaces
		lbsr	PrintDollar	; Dollar sign
		ldx	dump_address,PCR	; Get address of op code
		lda	1,X	; Get next byte (byte data)
		lbsr	PrintByte	; Print as hex value
		lbra	done
			
DO_EXTENDED				; Display "  $nnnn"
		lbsr	Print2Spaces	; Two spaces
		lbsr	PrintDollar	; Dollar sign
		ldx	dump_address,PCR	; Get address of op code
		lda	1,X	; Get first byte (address MSB)
		ldb	2,X	; Get second byte (address LSB)
		tfr	D,X	; Put in X to print
		lbsr	PrintAddress	; Print as hex value
		lbra	done
			
DO_RELATIVE8				; Display "  $nnnn"
		lbsr	Print2Spaces	; Two spaces
		lbsr	PrintDollar	; Dollar sign
			
; Destination address for relative branch is address of opcode + (sign
; extended)offset + 2, e.g.
;   $1015 + $(FF)FC + 2 = $1013
;   $101B + $(00)27 + 2 = $1044
			
		ldx	dump_address,PCR	; Get address of op code
		ldb	1,X	; Get first byte (8-bit branch offset)
		sex			; Sign extend to 16 bits
		addd	dump_address	; Add address of op code
		addd	#2	; Add 2
		tfr	D,X	; Put in X to print
		lbsr	PrintAddress	; Print as hex value
		lbra	done
			
DO_RELATIVE16				; Display "  $nnnn"
		lbsr	Print2Spaces	; Two spaces
		lbsr	PrintDollar	; Dollar sign
			
; Destination address calculation is similar to above, except offset
; is 16 bits and need to add 3.
			
		ldx	dump_address,PCR	; Get address of op code
		ldd	1,X	; Get next 2 bytes (16-bit branch offset)
		addd	dump_address	; Add address of op code
		addd	#3	; Add 3
		tfr	D,X	; Put in X to print
		lbsr	PrintAddress	; Print as hex value
		lbra	done
			
DO_INDEXED		
		lbsr	Print2Spaces	; Two spaces
			
; Addressing modes are determined by the postbyte:
;
; Postbyte  Format  Additional Bytes
; --------  ------  ----------------
; 0RRnnnnn  n,R     0
; 1RR00100  ,R      0
; 1RR01000  n,R     1
; 1RR01001  n,R     2
; 1RR00110  A,R     0
; 1RR00101  B,R     0
; 1RR01011  D,R     0
; 1RR00000  ,R+     0
; 1RR00001  ,R++    0
; 1RR00010  ,-R     0
; 1RR00011  ,--R    0
; 1xx01100  n,PCR   1
; 1xx01101  n,PCR   2
; 1RR10100  [,R]    0
; 1RR11000  [n,R]   1
; 1RR11001  [n,R]   2
; 1RR10110  [A,R]   0
; 1RR10101  [B,R]   0
; 1RR11011  [D,R]   0
; 1RR10001  [,R++]  0
; 1RR10011  [,--R]  0
; 1xx11100  [n,PCR] 1
; 1xx11101  [n,PCR] 2
; 10011111  [n]     2
;
; Where RR: 00=X 01=Y 10=U 11=S
			
		lda	POSTBYT	; Get postbyte
		bmi	ind2	; Branch if MSB is 1
			
					; Format is 0RRnnnnn  n,R
		anda	#%00011111	; Get 5-bit offset
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintByte	; Print offset
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbra	done
ind2			
		anda	#%10011111	; Mask out register bits
		cmpa	#%10000100	; Check against pattern
		bne	ind3
					; Format is 1RR00100  ,R
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbra	done
ind3			
		cmpa	#%10001000	; Check against pattern
		bne	ind4
					; Format is 1RR01000  n,R
		ldx	dump_address,PCR
		lda	2,X	; Get 8-bit offset
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintByte	; Display it
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbra	done
ind4			
		cmpa	#%10001001	; Check against pattern
		bne	ind5
					; Format is 1RR01001  n,R
		ldx	dump_address,PCR
		ldd	2,X	; Get 16-bit offset
		tfr	D,X
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintAddress	; Display it
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbra	done
ind5			
		cmpa	#%10000110	; Check against pattern
		bne	ind6
					; Format is 1RR00110  A,R
		lda	#'A
		lbsr	putChar	; Print A
commar		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbra	done
ind6			
		cmpa	#%10000101	; Check against pattern
		bne	ind7
					; Format is 1RR00101  B,R
		lda	#'B
		lbsr	putChar
		bra	commar
ind7			
		cmpa	#%10001011	; Check against pattern
		bne	ind8
					; Format is 1RR01011  D,R
		lda	#'D
		lbsr	putChar
		bra	commar
ind8			
		cmpa	#%10000000	; Check against pattern
		bne	ind9
					; Format is 1RR00000  ,R+
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lda	#'+	; Print plus
		lbsr	putChar
		lbra	done
ind9			
		cmpa	#%10000001	; Check against pattern
		bne	ind10
					; Format is 1RR00001  ,R++
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lda	#'+	; Print plus twice
		lbsr	putChar
		lbsr	putChar
		lbra	done
ind10			
		cmpa	#%10000010	; Check against pattern
		bne	ind11
					; Format is 1RR00010  ,-R
		lbsr	PrintComma	; Print comma
		lda	#'-	; Print minus
		lbsr	putChar
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbra	done
ind11			
		cmpa	#%10000011	; Check against pattern
		bne	ind12
					; Format is 1RR00011  ,--R
		lbsr	PrintComma	; Print comma
		lda	#'-	; Print minus twice
		lbsr	putChar
		lbsr	putChar
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbra	done
ind12			
		cmpa	#%10001100	; Check against pattern
		bne	ind13
					; Format is 1xx01100  n,PCR
		ldx	dump_address,PCR
		lda	2,X	; Get 8-bit offset
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintByte	; Display it
		lbsr	PrintComma	; Print comma
		lbsr	PrintPCR	; Print PCR
		lbra	done
ind13			
		cmpa	#%10001101	; Check against pattern
		bne	ind14
					; Format is 1xx01101  n,PCR
		ldx	dump_address,PCR
		ldd	2,X	; Get 16-bit offset
		tfr	D,X
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintAddress	; Display it
		lbsr	PrintComma	; Print comma
		lbsr	PrintPCR	; Print PCR
		lbra	done
ind14			
		cmpa	#%10010100	; Check against pattern
		bne	ind15
					; Format is 1RR10100  [,R]
		lbsr	PrintLBracket	; Print left bracket
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbsr	PrintRBracket	; Print right bracket
		lbra	done
ind15			
		cmpa	#%10011000	; Check against pattern
		bne	ind16
					; Format is 1RR11000  [n,R]
		lbsr	PrintLBracket	; Print left bracket
		ldx	dump_address,PCR
		lda	2,X	; Get 8-bit offset
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintByte	; Display it
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbsr	PrintRBracket	; Print right bracket
		lbra	done
ind16			
		cmpa	#%10011001	; Check against pattern
		bne	ind17
					; Format is 1RR11001  [n,R]
		lbsr	PrintLBracket	; Print left bracket
		ldx	dump_address,PCR
		ldd	2,X	; Get 16-bit offset
		tfr	D,X
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintAddress	; Display it
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbsr	PrintRBracket	; Print right bracket
		lbra	done
ind17			
		cmpa	#%10010110	; Check against pattern
		bne	ind18
					; Format is 1RR10110  [A,R]
		lbsr	PrintLBracket	; Print left bracket
		lda	#'A
		lbsr	putChar	; Print A
comrb		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lbsr	PrintRBracket	; Print right bracket
		lbra	done
ind18			
		cmpa	#%10010101	; Check against pattern
		bne	ind19
					; Format is 1RR10101  [B,R]
		lbsr	PrintLBracket	; Print left bracket
		lda	#'B
		lbsr	putChar
		bra	comrb
ind19			
		cmpa	#%10011011	; Check against pattern
		bne	ind20
					; Format is 1RR11011  [D,R]
		lbsr	PrintLBracket	; Print left bracket
		lda	#'D
		lbsr	putChar
		bra	comrb
ind20			
		cmpa	#%10010001	; Check against pattern
		bne	ind21
					; Format is 1RR10001  [,R++]
		lbsr	PrintLBracket	; Print left bracket
		lbsr	PrintComma	; Print comma
		lda	POSTBYT	; Get postbyte again
		lbsr	PrintRegister	; Print register name
		lda	#'+	; Print plus twice
		lbsr	putChar
		lbsr	putChar
		lbsr	PrintRBracket	; Print right bracket
		lbra	done
ind21			
		cmpa	#%10010011	; Check against pattern
		bne	ind22
					; Format is 1RR10011  [,--R]
		lbsr	PrintLBracket	; Print left bracket
		lbsr	PrintComma	; Print comma
		lda	#'-	; Print minus twice
		lbsr	putChar
		lbsr	putChar
		lda	POSTBYT	; Get postbyte again
		bsr	PrintRegister	; Print register name
		lbsr	PrintRBracket	; Print right bracket
		bra	done
ind22			
		cmpa	#%10011100	; Check against pattern
		bne	ind23
					; Format is 1xx11100  [n,PCR]
		lbsr	PrintLBracket	; Print left bracket
		ldx	dump_address,PCR
		lda	2,X	; Get 8-bit offset
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintByte	; Display it
		lbsr	PrintComma	; Print comma
		bsr	PrintPCR	; Print PCR
		lbsr	PrintRBracket	; Print right bracket
		bra	done
ind23			
		cmpa	#%10011101	; Check against pattern
		bne	ind24
					; Format is 1xx11101  [n,PCR]
		lbsr	PrintLBracket	; Print left bracket
		ldx	dump_address,PCR
		ldd	2,X	; Get 16-bit offset
		tfr	D,X
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintAddress	; Display it
		lbsr	PrintComma	; Print comma
		bsr	PrintPCR	; Print PCR
		lbsr	PrintRBracket	; Print right bracket
		bra	done
ind24			
		cmpa	#%10011111	; Check against pattern
		bne	ind25
					; Format is 1xx11111  [n]
		lbsr	PrintLBracket	; Print left bracket
		ldx	dump_address,PCR
		ldd	2,X	; Get 16-bit offset
		tfr	D,X
		lbsr	PrintDollar	; Dollar sign
		lbsr	PrintAddress	; Display it
		lbsr	PrintRBracket	; Print right bracket
		bra	done
ind25					; Should never be reached
		bra	done
			
; Print register name encoded in bits 5 and 6 of A for indexed
; addressing: xRRxxxxx where RR: 00=X 01=Y 10=U 11=S
; Registers changed: X
PrintRegister		
		pshs	A	; Save A
		anda	#%01100000	; Mask out other bits
		lsra			; Shift into 2 LSB
		lsra	
		lsra	
		lsra	
		lsra	
		leax	<REGTABLE,PCR	; Lookup table of register name characters
		lda	A,X	; Get character
		lbsr	putChar	; Print it
		puls	A	; Restore A
		rts			; Return
REGTABLE		
		fcc	"XYUS"
			
; Print the string "PCR" on the console.
; Registers changed: X
PrintPCR		
		leax	MSG3,PCR	; "PCR" string
		lbsr	putStr
		rts	
			
; Print final CR
			
done		lbsr	putNL
			
; Update address to next instruction
; If it was a page 2/3 instruction, we need to subtract one from the
; length to account for ADDR being moved to the second byte of the
; instruction.
			
		tst	PAGE23	; Flag set
		beq	not23	; Branch if not
		dec	LEN	; Decrement length
not23		clra			; Clear MSB of D
		ldb	LEN	; Get length byte in LSB of D
		addd	dump_address	; Add to address
		std	dump_address	; Write new address
			
; Return
		rts	
			
; *** DATA
			
; Table of instruction strings. 4 bytes per table entry
MNEMONICS		
		fcc	"???	"          ; $00
		fcc	"ABX	"          ; $01
		fcc	"ADCA"	; $02
		fcc	"ADCB"	; $03
		fcc	"ADDA"	; $04
		fcc	"ADDB"	; $05
		fcc	"ADDD"	; $06
		fcc	"ANDA"	; $07
		fcc	"ANDB"	; $08
		fcc	"ANDC"	; $09 Should really  be "ANDCC"
		fcc	"ASL	"          ; $0A
		fcc	"ASLA"	; $0B
		fcc	"ASLB"	; $0C
		fcc	"ASR	"          ; $0D
		fcc	"ASRA"	; $0E
		fcc	"ASRB"	; $0F
		fcc	"BCC	"          ; $10
		fcc	"BCS	"          ; $11
		fcc	"BEQ	"          ; $12
		fcc	"BGE	"          ; $13
		fcc	"BGT	"          ; $14
		fcc	"BHI	"          ; $15
		fcc	"BITA"	; $16
		fcc	"BITB"	; $17
		fcc	"BLE	"          ; $18
		fcc	"BLS	"          ; $19
		fcc	"BLT	"          ; $1A
		fcc	"BMI	"          ; $1B
		fcc	"BNE	"          ; $1C
		fcc	"BPL	"          ; $1D
		fcc	"BRA	"          ; $1E
		fcc	"BRN	"          ; $1F
		fcc	"BSR	"          ; $20
		fcc	"BVC	"          ; $21
		fcc	"BVS	"          ; $22
		fcc	"CLR	"          ; $23
		fcc	"CLRA"	; $24
		fcc	"CLRB"	; $25
		fcc	"CMPA"	; $26
		fcc	"CMPB"	; $27
		fcc	"CMPD"	; $28
		fcc	"CMPS"	; $29
		fcc	"CMPU"	; $2A
		fcc	"CMPX"	; $2B
		fcc	"CMPY"	; $2C
		fcc	"COMA"	; $2D
		fcc	"COMB"	; $2E
		fcc	"COM	"          ; $2F
		fcc	"CWAI"	; $30
		fcc	"DAA	"          ; $31
		fcc	"DEC	"          ; $32
		fcc	"DECA"	; $33
		fcc	"DECB"	; $34
		fcc	"EORA"	; $35
		fcc	"EORB"	; $36
		fcc	"EXG	"          ; $37
		fcc	"INC	"          ; $38
		fcc	"INCA"	; $39
		fcc	"INCB"	; $3A
		fcc	"JMP	"          ; $3B
		fcc	"JSR	"          ; $3C
		fcc	"LBCC"	; $3D
		fcc	"LBCS"	; $3E
		fcc	"LBEQ"	; $3F
		fcc	"LBGE"	; $40
		fcc	"LBGT"	; $41
		fcc	"LBHI"	; $42
		fcc	"LBLE"	; $43
		fcc	"LBLS"	; $44
		fcc	"LBLT"	; $45
		fcc	"LBMI"	; $46
		fcc	"LBNE"	; $47
		fcc	"LBPL"	; $48
		fcc	"LBRA"	; $49
		fcc	"LBRN"	; $4A
		fcc	"LBSR"	; $4B
		fcc	"LBVC"	; $4C
		fcc	"LBVS"	; $4D
		fcc	"LDA	"          ; $4E
		fcc	"LDB	"          ; $4F
		fcc	"LDD	"          ; $50
		fcc	"LDS	"          ; $51
		fcc	"LDU	"          ; $52
		fcc	"LDX	"          ; $53
		fcc	"LDY	"          ; $54
		fcc	"LEAS"	; $55
		fcc	"LEAU"	; $56
		fcc	"LEAX"	; $57
		fcc	"LEAY"	; $58
		fcc	"LSR	"          ; $59
		fcc	"LSRA"	; $5A
		fcc	"LSRB"	; $5B
		fcc	"MUL	"          ; $5C
		fcc	"NEG	"          ; $5D
		fcc	"NEGA"	; $5E
		fcc	"NEGB"	; $5F
		fcc	"NOP	"          ; $60
		fcc	"ORA	"          ; $61
		fcc	"ORB	"          ; $62
		fcc	"ORCC"	; $63
		fcc	"PSHS"	; $64
		fcc	"PSHU"	; $65
		fcc	"PULS"	; $66
		fcc	"PULU"	; $67
		fcc	"ROL	"          ; $68
		fcc	"ROLA"	; $69
		fcc	"ROLB"	; $6A
		fcc	"ROR	"          ; $6B
		fcc	"RORA"	; $6C
		fcc	"RORB"	; $6D
		fcc	"RTI	"          ; $6E
		fcc	"RTS	"          ; $6F
		fcc	"SBCA"	; $70
		fcc	"SBCB"	; $71
		fcc	"SEX	"          ; $72
		fcc	"STA	"          ; $73
		fcc	"STB	"          ; $74
		fcc	"STD	"          ; $75
		fcc	"STS	"          ; $76
		fcc	"STU	"          ; $77
		fcc	"STX	"          ; $78
		fcc	"STY	"          ; $79
		fcc	"SUBA"	; $7A
		fcc	"SUBB"	; $7B
		fcc	"SUBD"	; $7C
		fcc	"SWI	"          ; $7D
		fcc	"SWI2"	; $7E
		fcc	"SWI3"	; $7F
		fcc	"SYNC"	; $80
		fcc	"TFR	"          ; $81
		fcc	"TST	"          ; $82
		fcc	"TSTA"	; $83
		fcc	"TSTB"	; $84
			
; Lengths of instructions given an addressing mode. Matches values of
; AM_* Indexed addessing instructions length can increase due to post
; byte.
LENGTHS			
		fcb	1	; 0 AM_INVALID
		fcb	1	; 1 AM_INHERENT
		fcb	2	; 2 AM_IMMEDIATE8
		fcb	3	; 3 AM_IMMEDIATE16
		fcb	2	; 4 AM_DIRECT
		fcb	3	; 5 AM_EXTENDED
		fcb	2	; 6 AM_RELATIVE8
		fcb	3	; 7 AM_RELATIVE16
		fcb	2	; 8 AM_INDEXED
			
; Lookup table to return needed remaining spaces to print to pad out
; instruction to correct column in disassembly.
; # bytes: 1 2 3 4
; Padding: 9 6 3 0
PADDING			
		fcb	10,7,4,1
			
; Lookup table to return number of additional bytes for indexed
; addressing based on low order 5 bits of postbyte. Based on
; detailed list of values below.
			
POSTBYTES		
		fcb	0,0,0,0,0,0,0,0
		fcb	1,2,0,0,1,2,0,0
		fcb	0,0,0,0,0,0,0,0
		fcb	1,2,0,0,1,2,0,2
			
; Pattern:  # Extra bytes:
; --------  --------------
; 0XXXXXXX   0
; 1XX00000   0
; 1XX00001   0
; 1XX00010   0
; 1XX00011   0
; 1XX00100   0
; 1X000101   0
; 1XX00110   0
; 1XX00111   0 (INVALID)
; 1XX01000   1
; 1XX01001   2
; 1XX01010   0 (INVALID)
; 1XX01011   0
; 1XX01100   1
; 1XX01101   2
; 1XX01110   0 (INVALID)
; 1XX01111   0 (INVALID)
; 1XX10000   0 (INVALID)
; 1XX10001   0
; 1XX10010   0 (INVALID)
; 1XX10011   0
; 1XX10100   0
; 1XX10101   0
; 1XX10110   0
; 1XX10111   0 (INVALID)
; 1XX11000   1
; 1XX11001   2
; 1XX11010   0 (INVALID)
; 1XX11011   0
; 1XX11100   1
; 1XX11101   2
; 1XX11110   0 (INVALID)
; 1XX11111   2
			
; Opcodes. Listed in order indexed by op code. Defines the mnemonic.
OPCODES			
		fcb	OP_NEG	; 00
		fcb	OP_INV	; 01
		fcb	OP_INV	; 02
		fcb	OP_COMB	; 03
		fcb	OP_LSR	; 04
		fcb	OP_INV	; 05
		fcb	OP_ROR	; 06
		fcb	OP_ASR	; 07
		fcb	OP_ASL	; 08
		fcb	OP_ROL	; 09
		fcb	OP_DEC	; 0A
		fcb	OP_INV	; 0B
		fcb	OP_INC	; 0C
		fcb	OP_TST	; 0D
		fcb	OP_JMP	; 0E
		fcb	OP_CLR	; 0F
			
		fcb	OP_INV	; 10 Page 2 extended opcodes (see other table)
		fcb	OP_INV	; 11 Page 3 extended opcodes (see other table)
		fcb	OP_NOP	; 12
		fcb	OP_SYNC	; 13
		fcb	OP_INV	; 14
		fcb	OP_INV	; 15
		fcb	OP_LBRA	; 16
		fcb	OP_LBSR	; 17
		fcb	OP_INV	; 18
		fcb	OP_DAA	; 19
		fcb	OP_ORCC	; 1A
		fcb	OP_INV	; 1B
		fcb	OP_ANDCC	; 1C
		fcb	OP_SEX	; 1D
		fcb	OP_EXG	; 1E
		fcb	OP_TFR	; 1F
			
		fcb	OP_BRA	; 20
		fcb	OP_BRN	; 21
		fcb	OP_BHI	; 22
		fcb	OP_BLS	; 23
		fcb	OP_BCC	; 24
		fcb	OP_BCS	; 25
		fcb	OP_BNE	; 26
		fcb	OP_BEQ	; 27
		fcb	OP_BVC	; 28
		fcb	OP_BVS	; 29
		fcb	OP_BPL	; 2A
		fcb	OP_BMI	; 2B
		fcb	OP_BGE	; 2C
		fcb	OP_BLT	; 2D
		fcb	OP_BGT	; 2E
		fcb	OP_BLE	; 2F
			
		fcb	OP_LEAX	; 30
		fcb	OP_LEAY	; 31
		fcb	OP_LEAS	; 32
		fcb	OP_LEAU	; 33
		fcb	OP_PSHS	; 34
		fcb	OP_PULS	; 35
		fcb	OP_PSHU	; 36
		fcb	OP_PULU	; 37
		fcb	OP_INV	; 38
		fcb	OP_RTS	; 39
		fcb	OP_ABX	; 3A
		fcb	OP_RTI	; 3B
		fcb	OP_CWAI	; 3C
		fcb	OP_MUL	; 3D
		fcb	OP_INV	; 3E
		fcb	OP_SWI	; 3F
			
		fcb	OP_NEGA	; 40
		fcb	OP_INV	; 41
		fcb	OP_INV	; 42
		fcb	OP_COMA	; 43
		fcb	OP_LSRA	; 44
		fcb	OP_INV	; 45
		fcb	OP_RORA	; 46
		fcb	OP_ASRA	; 47
		fcb	OP_ASLA	; 48
		fcb	OP_ROLA	; 49
		fcb	OP_DECA	; 4A
		fcb	OP_INV	; 4B
		fcb	OP_INCA	; 4C
		fcb	OP_TSTA	; 4D
		fcb	OP_INV	; 4E
		fcb	OP_CLRA	; 4F
			
		fcb	OP_NEGB	; 50
		fcb	OP_INV	; 51
		fcb	OP_INV	; 52
		fcb	OP_COMB	; 53
		fcb	OP_LSRB	; 54
		fcb	OP_INV	; 55
		fcb	OP_RORB	; 56
		fcb	OP_ASRB	; 57
		fcb	OP_ASLB	; 58
		fcb	OP_ROLB	; 59
		fcb	OP_DECB	; 5A
		fcb	OP_INV	; 5B
		fcb	OP_INCB	; 5C
		fcb	OP_TSTB	; 5D
		fcb	OP_INV	; 5E
		fcb	OP_CLRB	; 5F
			
		fcb	OP_NEG	; 60
		fcb	OP_INV	; 61
		fcb	OP_INV	; 62
		fcb	OP_COM	; 63
		fcb	OP_LSR	; 64
		fcb	OP_INV	; 65
		fcb	OP_ROR	; 66
		fcb	OP_ASR	; 67
		fcb	OP_ASL	; 68
		fcb	OP_ROL	; 69
		fcb	OP_DEC	; 6A
		fcb	OP_INV	; 6B
		fcb	OP_INC	; 6C
		fcb	OP_TST	; 6D
		fcb	OP_JMP	; 6E
		fcb	OP_CLR	; 6F
			
		fcb	OP_NEG	; 70
		fcb	OP_INV	; 71
		fcb	OP_INV	; 72
		fcb	OP_COM	; 73
		fcb	OP_LSR	; 74
		fcb	OP_INV	; 75
		fcb	OP_ROR	; 76
		fcb	OP_ASR	; 77
		fcb	OP_ASL	; 78
		fcb	OP_ROL	; 79
		fcb	OP_DEC	; 7A
		fcb	OP_INV	; 7B
		fcb	OP_INC	; 7C
		fcb	OP_TST	; 7D
		fcb	OP_JMP	; 7E
		fcb	OP_CLR	; 7F
			
		fcb	OP_SUBA	; 80
		fcb	OP_CMPA	; 81
		fcb	OP_SBCA	; 82
		fcb	OP_SUBD	; 83
		fcb	OP_ANDA	; 84
		fcb	OP_BITA	; 85
		fcb	OP_LDA	; 86
		fcb	OP_INV	; 87
		fcb	OP_EORA	; 88
		fcb	OP_ADCA	; 89
		fcb	OP_ORA	; 8A
		fcb	OP_ADDA	; 8B
		fcb	OP_CMPX	; 8C
		fcb	OP_BSR	; 8D
		fcb	OP_LDX	; 8E
		fcb	OP_INV	; 8F
			
		fcb	OP_SUBA	; 90
		fcb	OP_CMPA	; 91
		fcb	OP_SBCA	; 92
		fcb	OP_SUBD	; 93
		fcb	OP_ANDA	; 94
		fcb	OP_BITA	; 95
		fcb	OP_LDA	; 96
		fcb	OP_STA	; 97
		fcb	OP_EORA	; 98
		fcb	OP_ADCA	; 99
		fcb	OP_ORA	; 9A
		fcb	OP_ADDA	; 9B
		fcb	OP_CMPX	; 9C
		fcb	OP_JSR	; 9D
		fcb	OP_LDX	; 9E
		fcb	OP_STX	; 9F
			
		fcb	OP_SUBA	; A0
		fcb	OP_CMPA	; A1
		fcb	OP_SBCA	; A2
		fcb	OP_SUBD	; A3
		fcb	OP_ANDA	; A4
		fcb	OP_BITA	; A5
		fcb	OP_LDA	; A6
		fcb	OP_STA	; A7
		fcb	OP_EORA	; A8
		fcb	OP_ADCA	; A9
		fcb	OP_ORA	; AA
		fcb	OP_ADDA	; AB
		fcb	OP_CMPX	; AC
		fcb	OP_JSR	; AD
		fcb	OP_LDX	; AE
		fcb	OP_STX	; AF
			
		fcb	OP_SUBA	; B0
		fcb	OP_CMPA	; B1
		fcb	OP_SBCA	; B2
		fcb	OP_SUBD	; B3
		fcb	OP_ANDA	; B4
		fcb	OP_BITA	; B5
		fcb	OP_LDA	; B6
		fcb	OP_STA	; B7
		fcb	OP_EORA	; B8
		fcb	OP_ADCA	; B9
		fcb	OP_ORA	; BA
		fcb	OP_ADDA	; BB
		fcb	OP_CMPX	; BC
		fcb	OP_JSR	; BD
		fcb	OP_LDX	; BE
		fcb	OP_STX	; BF
			
		fcb	OP_SUBB	; C0
		fcb	OP_CMPB	; C1
		fcb	OP_SBCB	; C2
		fcb	OP_ADDD	; C3
		fcb	OP_ANDB	; C4
		fcb	OP_BITB	; C5
		fcb	OP_LDB	; C6
		fcb	OP_INV	; C7
		fcb	OP_EORB	; C8
		fcb	OP_ADCB	; C9
		fcb	OP_ORB	; CA
		fcb	OP_ADDB	; CB
		fcb	OP_LDD	; CC
		fcb	OP_INV	; CD
		fcb	OP_LDU	; CE
		fcb	OP_INV	; CF
			
		fcb	OP_SUBB	; D0
		fcb	OP_CMPB	; D1
		fcb	OP_SBCB	; D2
		fcb	OP_ADDD	; D3
		fcb	OP_ANDB	; D4
		fcb	OP_BITB	; D5
		fcb	OP_LDB	; D6
		fcb	OP_STB	; D7
		fcb	OP_EORB	; D8
		fcb	OP_ADCB	; D9
		fcb	OP_ORB	; DA
		fcb	OP_ADDB	; DB
		fcb	OP_LDD	; DC
		fcb	OP_STD	; DD
		fcb	OP_LDU	; DE
		fcb	OP_STU	; DF
			
		fcb	OP_SUBB	; E0
		fcb	OP_CMPB	; E1
		fcb	OP_SBCB	; E2
		fcb	OP_ADDD	; E3
		fcb	OP_ANDB	; E4
		fcb	OP_BITB	; E5
		fcb	OP_LDB	; E6
		fcb	OP_STB	; E7
		fcb	OP_EORB	; E8
		fcb	OP_ADCB	; E9
		fcb	OP_ORB	; EA
		fcb	OP_ADDB	; EB
		fcb	OP_LDD	; EC
		fcb	OP_STD	; ED
		fcb	OP_LDU	; EE
		fcb	OP_STU	; EF
			
		fcb	OP_SUBB	; F0
		fcb	OP_CMPB	; F1
		fcb	OP_SBCB	; F2
		fcb	OP_ADDD	; F3
		fcb	OP_ANDB	; F4
		fcb	OP_BITB	; F5
		fcb	OP_LDB	; F6
		fcb	OP_STB	; F7
		fcb	OP_EORB	; F8
		fcb	OP_ADCB	; F9
		fcb	OP_ORB	; FA
		fcb	OP_ADDB	; FB
		fcb	OP_LDD	; FC
		fcb	OP_STD	; FD
		fcb	OP_LDU	; FE
		fcb	OP_STU	; FF
			
; Table of addressing modes. Listed in order,indexed by op code.
MODES			
		fcb	AM_DIRECT	; 00
		fcb	AM_INVALID	; 01
		fcb	AM_INVALID	; 02
		fcb	AM_DIRECT	; 03
		fcb	AM_DIRECT	; 04
		fcb	AM_INVALID	; 05
		fcb	AM_DIRECT	; 06
		fcb	AM_DIRECT	; 07
		fcb	AM_DIRECT	; 08
		fcb	AM_DIRECT	; 09
		fcb	AM_DIRECT	; 0A
		fcb	AM_INVALID	; 0B
		fcb	AM_DIRECT	; 0C
		fcb	AM_DIRECT	; 0D
		fcb	AM_DIRECT	; 0E
		fcb	AM_DIRECT	; 0F
			
		fcb	AM_INVALID	; 10 Page 2 extended opcodes (see other table)
		fcb	AM_INVALID	; 11 Page 3 extended opcodes (see other table)
		fcb	AM_INHERENT	; 12
		fcb	AM_INHERENT	; 13
		fcb	AM_INVALID	; 14
		fcb	AM_INVALID	; 15
		fcb	AM_RELATIVE16	; 16
		fcb	AM_RELATIVE16	; 17
		fcb	AM_INVALID	; 18
		fcb	AM_INHERENT	; 19
		fcb	AM_IMMEDIATE8	; 1A
		fcb	AM_INVALID	; 1B
		fcb	AM_IMMEDIATE8	; 1C
		fcb	AM_INHERENT	; 1D
		fcb	AM_IMMEDIATE8	; 1E
		fcb	AM_IMMEDIATE8	; 1F
			
		fcb	AM_RELATIVE8	; 20
		fcb	AM_RELATIVE8	; 21
		fcb	AM_RELATIVE8	; 22
		fcb	AM_RELATIVE8	; 23
		fcb	AM_RELATIVE8	; 24
		fcb	AM_RELATIVE8	; 25
		fcb	AM_RELATIVE8	; 26
		fcb	AM_RELATIVE8	; 27
		fcb	AM_RELATIVE8	; 28
		fcb	AM_RELATIVE8	; 29
		fcb	AM_RELATIVE8	; 2A
		fcb	AM_RELATIVE8	; 2B
		fcb	AM_RELATIVE8	; 2C
		fcb	AM_RELATIVE8	; 2D
		fcb	AM_RELATIVE8	; 2E
		fcb	AM_RELATIVE8	; 2F
			
		fcb	AM_INDEXED	; 30
		fcb	AM_INDEXED	; 31
		fcb	AM_INDEXED	; 32
		fcb	AM_INDEXED	; 33
		fcb	AM_IMMEDIATE8	; 34
		fcb	AM_IMMEDIATE8	; 35
		fcb	AM_IMMEDIATE8	; 36
		fcb	AM_IMMEDIATE8	; 37
		fcb	AM_INVALID	; 38
		fcb	AM_INHERENT	; 39
		fcb	AM_INHERENT	; 3A
		fcb	AM_INHERENT	; 3B
		fcb	AM_IMMEDIATE8	; 3C
		fcb	AM_INHERENT	; 3D
		fcb	AM_INVALID	; 3E
		fcb	AM_INHERENT	; 3F
			
		fcb	AM_INHERENT	; 40
		fcb	AM_INVALID	; 41
		fcb	AM_INVALID	; 42
		fcb	AM_INHERENT	; 43
		fcb	AM_INHERENT	; 44
		fcb	AM_INVALID	; 45
		fcb	AM_INHERENT	; 46
		fcb	AM_INHERENT	; 47
		fcb	AM_INHERENT	; 48
		fcb	AM_INHERENT	; 49
		fcb	AM_INHERENT	; 4A
		fcb	AM_INVALID	; 4B
		fcb	AM_INHERENT	; 4C
		fcb	AM_INHERENT	; 4D
		fcb	AM_INVALID	; 4E
		fcb	AM_INHERENT	; 4F
			
		fcb	AM_INHERENT	; 50
		fcb	AM_INVALID	; 51
		fcb	AM_INVALID	; 52
		fcb	AM_INHERENT	; 53
		fcb	AM_INHERENT	; 54
		fcb	AM_INVALID	; 55
		fcb	AM_INHERENT	; 56
		fcb	AM_INHERENT	; 57
		fcb	AM_INHERENT	; 58
		fcb	AM_INHERENT	; 59
		fcb	AM_INHERENT	; 5A
		fcb	AM_INVALID	; 5B
		fcb	AM_INHERENT	; 5C
		fcb	AM_INHERENT	; 5D
		fcb	AM_INVALID	; 5E
		fcb	AM_INHERENT	; 5F
			
		fcb	AM_INDEXED	; 60
		fcb	AM_INVALID	; 61
		fcb	AM_INVALID	; 62
		fcb	AM_INDEXED	; 63
		fcb	AM_INDEXED	; 64
		fcb	AM_INVALID	; 65
		fcb	AM_INDEXED	; 66
		fcb	AM_INDEXED	; 67
		fcb	AM_INDEXED	; 68
		fcb	AM_INDEXED	; 69
		fcb	AM_INDEXED	; 6A
		fcb	AM_INVALID	; 6B
		fcb	AM_INDEXED	; 6C
		fcb	AM_INDEXED	; 6D
		fcb	AM_INDEXED	; 6E
		fcb	AM_INDEXED	; 6F
			
		fcb	AM_EXTENDED	; 70
		fcb	AM_INVALID	; 71
		fcb	AM_INVALID	; 72
		fcb	AM_EXTENDED	; 73
		fcb	AM_EXTENDED	; 74
		fcb	AM_INVALID	; 75
		fcb	AM_EXTENDED	; 76
		fcb	AM_EXTENDED	; 77
		fcb	AM_EXTENDED	; 78
		fcb	AM_EXTENDED	; 79
		fcb	AM_EXTENDED	; 7A
		fcb	AM_INVALID	; 7B
		fcb	AM_EXTENDED	; 7C
		fcb	AM_EXTENDED	; 7D
		fcb	AM_EXTENDED	; 7E
		fcb	AM_EXTENDED	; 7F
			
		fcb	AM_IMMEDIATE8	; 80
		fcb	AM_IMMEDIATE8	; 81
		fcb	AM_IMMEDIATE8	; 82
		fcb	AM_IMMEDIATE16	; 83
		fcb	AM_IMMEDIATE8	; 84
		fcb	AM_IMMEDIATE8	; 85
		fcb	AM_IMMEDIATE8	; 86
		fcb	AM_INVALID	; 87
		fcb	AM_IMMEDIATE8	; 88
		fcb	AM_IMMEDIATE8	; 89
		fcb	AM_IMMEDIATE8	; 8A
		fcb	AM_IMMEDIATE8	; 8B
		fcb	AM_IMMEDIATE16	; 8C
		fcb	AM_RELATIVE8	; 8D
		fcb	AM_IMMEDIATE16	; 8E
		fcb	AM_INVALID	; 8F
			
		fcb	AM_DIRECT	; 90
		fcb	AM_DIRECT	; 91
		fcb	AM_DIRECT	; 92
		fcb	AM_DIRECT	; 93
		fcb	AM_DIRECT	; 94
		fcb	AM_DIRECT	; 95
		fcb	AM_DIRECT	; 96
		fcb	AM_DIRECT	; 97
		fcb	AM_DIRECT	; 98
		fcb	AM_DIRECT	; 99
		fcb	AM_DIRECT	; 9A
		fcb	AM_DIRECT	; 9B
		fcb	AM_DIRECT	; 9C
		fcb	AM_DIRECT	; 9D
		fcb	AM_DIRECT	; 9E
		fcb	AM_DIRECT	; 9F
			
		fcb	AM_INDEXED	; A0
		fcb	AM_INDEXED	; A1
		fcb	AM_INDEXED	; A2
		fcb	AM_INDEXED	; A3
		fcb	AM_INDEXED	; A4
		fcb	AM_INDEXED	; A5
		fcb	AM_INDEXED	; A6
		fcb	AM_INDEXED	; A7
		fcb	AM_INDEXED	; A8
		fcb	AM_INDEXED	; A9
		fcb	AM_INDEXED	; AA
		fcb	AM_INDEXED	; AB
		fcb	AM_INDEXED	; AC
		fcb	AM_INDEXED	; AD
		fcb	AM_INDEXED	; AE
		fcb	AM_INDEXED	; AF
			
		fcb	AM_EXTENDED	; B0
		fcb	AM_EXTENDED	; B1
		fcb	AM_EXTENDED	; B2
		fcb	AM_EXTENDED	; B3
		fcb	AM_EXTENDED	; B4
		fcb	AM_EXTENDED	; B5
		fcb	AM_EXTENDED	; B6
		fcb	AM_EXTENDED	; B7
		fcb	AM_EXTENDED	; B8
		fcb	AM_EXTENDED	; B9
		fcb	AM_EXTENDED	; BA
		fcb	AM_EXTENDED	; BB
		fcb	AM_EXTENDED	; BC
		fcb	AM_EXTENDED	; BD
		fcb	AM_EXTENDED	; BE
		fcb	AM_EXTENDED	; BF
			
		fcb	AM_IMMEDIATE8	; C0
		fcb	AM_IMMEDIATE8	; C1
		fcb	AM_IMMEDIATE8	; C2
		fcb	AM_IMMEDIATE16	; C3
		fcb	AM_IMMEDIATE8	; C4
		fcb	AM_IMMEDIATE8	; C5
		fcb	AM_IMMEDIATE8	; C6
		fcb	AM_INVALID	; C7
		fcb	AM_IMMEDIATE8	; C8
		fcb	AM_IMMEDIATE8	; C9
		fcb	AM_IMMEDIATE8	; CA
		fcb	AM_IMMEDIATE8	; CB
		fcb	AM_IMMEDIATE16	; CC
		fcb	AM_INHERENT	; CD
		fcb	AM_IMMEDIATE16	; CE
		fcb	AM_INVALID	; CF
			
		fcb	AM_DIRECT	; D0
		fcb	AM_DIRECT	; D1
		fcb	AM_DIRECT	; D2
		fcb	AM_DIRECT	; D3
		fcb	AM_DIRECT	; D4
		fcb	AM_DIRECT	; D5
		fcb	AM_DIRECT	; D6
		fcb	AM_DIRECT	; D7
		fcb	AM_DIRECT	; D8
		fcb	AM_DIRECT	; D9
		fcb	AM_DIRECT	; DA
		fcb	AM_DIRECT	; DB
		fcb	AM_DIRECT	; DC
		fcb	AM_DIRECT	; DD
		fcb	AM_DIRECT	; DE
		fcb	AM_DIRECT	; DF
			
		fcb	AM_INDEXED	; E0
		fcb	AM_INDEXED	; E1
		fcb	AM_INDEXED	; E2
		fcb	AM_INDEXED	; E3
		fcb	AM_INDEXED	; E4
		fcb	AM_INDEXED	; E5
		fcb	AM_INDEXED	; E6
		fcb	AM_INDEXED	; E7
		fcb	AM_INDEXED	; E8
		fcb	AM_INDEXED	; E9
		fcb	AM_INDEXED	; EA
		fcb	AM_INDEXED	; EB
		fcb	AM_INDEXED	; EC
		fcb	AM_INDEXED	; ED
		fcb	AM_INDEXED	; EE
		fcb	AM_INDEXED	; EF
			
		fcb	AM_EXTENDED	; F0
		fcb	AM_EXTENDED	; F1
		fcb	AM_EXTENDED	; F2
		fcb	AM_EXTENDED	; F3
		fcb	AM_EXTENDED	; F4
		fcb	AM_EXTENDED	; F5
		fcb	AM_EXTENDED	; F6
		fcb	AM_EXTENDED	; F7
		fcb	AM_EXTENDED	; F8
		fcb	AM_EXTENDED	; F9
		fcb	AM_EXTENDED	; FA
		fcb	AM_EXTENDED	; FB
		fcb	AM_EXTENDED	; FC
		fcb	AM_EXTENDED	; FD
		fcb	AM_EXTENDED	; FE
		fcb	AM_EXTENDED	; FF
			
; Special table for page 2 instructions prefixed by $10.
; Format: opcode (less 10), instruction, addressing mode
			
PAGE2			
		fcb	$21,OP_LBRN,AM_RELATIVE16
		fcb	$22,OP_LBHI,AM_RELATIVE16
		fcb	$23,OP_LBLS,AM_RELATIVE16
		fcb	$24,OP_LBCC,AM_RELATIVE16
		fcb	$25,OP_LBCS,AM_RELATIVE16
		fcb	$26,OP_LBNE,AM_RELATIVE16
		fcb	$27,OP_LBEQ,AM_RELATIVE16
		fcb	$28,OP_LBVC,AM_RELATIVE16
		fcb	$29,OP_LBVS,AM_RELATIVE16
		fcb	$2A,OP_LBPL,AM_RELATIVE16
		fcb	$2B,OP_LBMI,AM_RELATIVE16
		fcb	$2C,OP_LBGE,AM_RELATIVE16
		fcb	$2D,OP_LBLT,AM_RELATIVE16
		fcb	$2E,OP_LBGT,AM_RELATIVE16
		fcb	$2F,OP_LBLE,AM_RELATIVE16
		fcb	$3F,OP_SWI2,AM_INHERENT
		fcb	$83,OP_CMPD,AM_IMMEDIATE16
		fcb	$8C,OP_CMPY,AM_IMMEDIATE16
		fcb	$8E,OP_LDY,AM_IMMEDIATE16
		fcb	$93,OP_CMPD,AM_DIRECT
		fcb	$9C,OP_CMPY,AM_DIRECT
		fcb	$9E,OP_LDY,AM_DIRECT
		fcb	$9D,OP_STY,AM_DIRECT
		fcb	$A3,OP_CMPD,AM_INDEXED
		fcb	$AC,OP_CMPY,AM_INDEXED
		fcb	$AE,OP_LDY,AM_INDEXED
		fcb	$AF,OP_STY,AM_INDEXED
		fcb	$B3,OP_CMPD,AM_EXTENDED
		fcb	$BC,OP_CMPY,AM_EXTENDED
		fcb	$BE,OP_LDY,AM_EXTENDED
		fcb	$BF,OP_STY,AM_EXTENDED
		fcb	$CE,OP_LDS,AM_IMMEDIATE16
		fcb	$DE,OP_LDS,AM_DIRECT
		fcb	$DD,OP_STS,AM_DIRECT
		fcb	$EE,OP_LDS,AM_INDEXED
		fcb	$EF,OP_STS,AM_INDEXED
		fcb	$FE,OP_LDS,AM_EXTENDED
		fcb	$FF,OP_STS,AM_EXTENDED
		fcb	0	; indicates end of table
			
; Special table for page 3 instructions prefixed by $11.
; Same format as table above.
			
PAGE3			
		fcb	$3F,OP_SWI3,AM_INHERENT
		fcb	$83,OP_CMPU,AM_IMMEDIATE16
		fcb	$8C,OP_CMPS,AM_IMMEDIATE16
		fcb	$93,OP_CMPU,AM_DIRECT
		fcb	$9C,OP_CMPS,AM_DIRECT
		fcb	$A3,OP_CMPU,AM_INDEXED
		fcb	$AC,OP_CMPS,AM_INDEXED
		fcb	$B3,OP_CMPU,AM_EXTENDED
		fcb	$BC,OP_CMPS,AM_EXTENDED
		fcb	0	; indicates end of table
			
; Display strings. Should be terminated in EOT character.
			
MSG1		fcn	";	INVALID"
MSG2		fcn	"PRESS	<SPACE> TO CONTINUE, <Q> TO QUIT "
MSG3		fcn	"PCR"
			

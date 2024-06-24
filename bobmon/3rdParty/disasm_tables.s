;*************************************************************************
;
; Copyright 2013 by Sean Conner.
;
; This library is free software; you can redistribute it and/or modify it
; under the terms of the GNU Lesser General Public License as published by
; the Free Software Foundation; either version 3 of the License, or (at your
; option) any later version.
;
; This library is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
; License for more details.
;
; You should have received a copy of the GNU Lesser General Public License
; along with this library; if not, see <http://www.gnu.org/licenses/>.
;
; Comments, questions and criticisms can be sent to: sean@conman.org
;
;*************************************************************************
;
; This software is an MC6809 disassembler written in MC6809 assembly.  The
; code is position independent, so it can be placed anywhere in memory.  It
; is also read only, so it can be placed in ROM.  It uses 47 bytes of
; stackspace (including return address), and requires 55 bytes for output.


tillegal	fcs	"ILLEGAL"
tabx		fcs	"ABX"
tadc		fcs	"ADC"
tadd		fcs	"ADD"
tand		fcs	"AND"
tasr		fcs	"ASR"
tbcc		fcs	"BCC"
tbcs		fcs	"BCS"
tbeq		fcs	"BEQ"
tbge		fcs	"BGE"
tbgt		fcs	"BGT"
tbhi		fcs	"BHI"
tbit		fcs	"BIT"
tble		fcs	"BLE"
tbls		fcs	"BLS"
tblt		fcs	"BLT"
tbmi		fcs	"BMI"
tbne		fcs	"BNE"
tbpl		fcs	"BPL"
tbra		fcs	"BRA"
tbrn		fcs	"BRN"
tbsr		fcs	"BSR"
tbvc		fcs	"BVC"
tbvs		fcs	"BVS"
tclr		fcs	"CLR"
tcmp		fcs	"CMP"
tcom		fcs	"COM"
tcwai		fcs	"CWAI"
tdaa		fcs	"DAA"
tdec		fcs	"DEC"
teor		fcs	"EOR"
texg		fcs	"EXG"
tinc		fcs	"INC"
tjmp		fcs	"JMP"
tjsr		fcs	"JSR"
tld		fcs	"LD"
tlea		fcs	"LEA"
tlsl		fcs	"LSL"
tlsr		fcs	"LSR"
tmul		fcs	"MUL"
tneg		fcs	"NEG"
tnop		fcs	"NOP"
tor		fcs	"OR"
tpsh		fcs	"PSH"
tpul		fcs	"PUL"
trol		fcs	"ROL"
tror		fcs	"ROR"
trti		fcs	"RTI"
trts		fcs	"RTS"
tsbc		fcs	"SBC"
tsex		fcs	"SEX"
tst		fcs	"ST"
tsub		fcs	"SUB"
tswi		fcs	"SWI"
tsync		fcs	"SYNC"
ttfr		fcs	"TFR"
ttst		fcs	"TST"

regA		equ	tbra + 2	; 'A'
regB		equ	tsub + 2	; 'B'
regDP		fcs	"DP"
regCC		equ	tbcc + 1	; 'CC'
regD		equ	tadd + 2	; 'D'
regX		equ	tabx + 2	; 'X'
regY		fcs	"Y"
regS		equ	tbcs + 2	; 'S'
regU		fcs	"U"
regPC		fcs	"PC"

sp		fcs	" "
t2		fcs	"2"
t3		fcs	"3"
unknown		fcs	"?"
tcm		fcs	",-"
tcmm		fcs	",--"
tbr		fcs	"B,"
tar		fcs	"A,"
tdr		fcs	"D,"

indexreg	fcb	regX	,regY	,regU	,regS

exgtfr		fcb	regD	,regX	,regY	,regU
		fcb	regS	,regPC	,unknown,unknown
		fcb	regA	,regB	,regCC	,regDP
		fcb	unknown,unknown,unknown,unknown

pshpultab	fcb	regPC	,0	,regY	,regX
		fcb	regDP	,regB	,regA	,regCC

;----------------------------------------------------------------------
; Opcode tables.  The main table has the following structure:
;
;	addressing mode
;	opcode text
;	additional opcode text	
;----------------------------------------------------------------------

ops		fcb	direct		,tneg		,sp	; $00
		fcb	illegal		,tillegal	,sp
		fcb	illegal		,tillegal	,sp
		fcb	direct		,tcom		,sp
		fcb	direct		,tlsr		,sp
		fcb	illegal		,tillegal	,sp
		fcb	direct		,tror		,sp
		fcb	direct		,tasr		,sp
		fcb	direct		,tlsl		,sp
		fcb	direct		,trol		,sp
		fcb	direct		,tdec		,sp
		fcb	illegal		,tillegal	,sp
		fcb	direct		,tinc		,sp
		fcb	direct		,ttst		,sp
		fcb	direct		,tjmp		,sp
		fcb	direct		,tclr		,sp

		fcb	page1		,sp		,sp	; $10
		fcb	page2		,sp		,sp
		fcb	inherent	,tnop		,sp
		fcb	inherent	,tsync		,sp
		fcb	illegal		,tillegal	,sp
		fcb	illegal		,tillegal	,sp
		fcb	lrelative	,tbra		,sp
		fcb	lrelative	,tbsr		,sp
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tdaa		,sp
		fcb	immediate	,tor		,regCC
		fcb	illegal		,tillegal	,sp
		fcb	immediate	,tand		,regCC
		fcb	inherent	,tsex		,sp
		fcb	exg		,texg		,sp
		fcb	exg		,ttfr		,sp

		fcb	relative	,tbra		,sp	; $20
		fcb	relative	,tbrn		,sp
		fcb	relative	,tbhi		,sp
		fcb	relative	,tbls		,sp
		fcb	relative	,tbcc		,sp
		fcb	relative	,tbcs		,sp
		fcb	relative	,tbne		,sp
		fcb	relative	,tbeq		,sp
		fcb	relative	,tbvc		,sp
		fcb	relative	,tbvs		,sp
		fcb	relative	,tbpl		,sp
		fcb	relative	,tbmi		,sp
		fcb	relative	,tbge		,sp
		fcb	relative	,tblt		,sp
		fcb	relative	,tbgt		,sp
		fcb	relative	,tble		,sp

		fcb	indexed		,tlea		,regX	; $30
		fcb	indexed		,tlea		,regY
		fcb	indexed		,tlea		,regS
		fcb	indexed		,tlea		,regU
		fcb	pushpull	,tpsh		,regS
		fcb	pushpull	,tpul		,regS
		fcb	pushpull	,tpsh		,regU
		fcb	pushpull	,tpul		,regU
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,trts		,sp
		fcb	inherent	,tabx		,sp
		fcb	inherent	,trti		,sp
		fcb	immediate	,tcwai		,sp
		fcb	inherent	,tmul		,sp
		fcb	illegal		,tillegal	,sp
		fcb	immediate	,tswi		,sp

		fcb	inherent	,tneg		,regA	; $40
		fcb	illegal		,tillegal	,sp
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tcom		,regA
		fcb	inherent	,tlsr		,regA
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tror		,regA
		fcb	inherent	,tasr		,regA
		fcb	inherent	,tlsl		,regA
		fcb	inherent	,trol		,regA
		fcb	inherent	,tdec		,regA
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tinc		,regA
		fcb	inherent	,ttst		,regA
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tclr		,regA

		fcb	inherent	,tneg		,regB	; $50
		fcb	illegal		,tillegal	,sp
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tcom		,regB
		fcb	inherent	,tlsr		,regB
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tror		,regB
		fcb	inherent	,tasr		,regB
		fcb	inherent	,tlsl		,regB
		fcb	inherent	,trol		,regB
		fcb	inherent	,tdec		,regB
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tinc		,regB
		fcb	inherent	,ttst		,regB
		fcb	illegal		,tillegal	,sp
		fcb	inherent	,tclr		,regB

		fcb	indexed		,tneg		,sp	; $60
		fcb	illegal		,tillegal	,sp
		fcb	illegal		,tillegal	,sp
		fcb	indexed		,tcom		,sp
		fcb	indexed		,tlsr		,sp
		fcb	illegal		,tillegal	,sp
		fcb	indexed		,tror		,sp
		fcb	indexed		,tasr		,sp
		fcb	indexed		,tlsl		,sp
		fcb	indexed		,trol		,sp
		fcb	indexed		,tdec		,sp
		fcb	illegal		,tillegal	,sp
		fcb	indexed		,tinc		,sp
		fcb	indexed		,ttst		,sp
		fcb	indexed		,tjmp		,sp
		fcb	indexed		,tclr		,sp

		fcb	extended	,tneg		,sp	; $70
		fcb	illegal		,tillegal	,sp
		fcb	illegal		,tillegal	,sp
		fcb	extended	,tcom		,sp
		fcb	extended	,tlsr		,sp
		fcb	illegal		,tillegal	,sp
		fcb	extended	,tror		,sp
		fcb	extended	,tasr		,sp
		fcb	extended	,tlsl		,sp
		fcb	extended	,trol		,sp
		fcb	extended	,tdec		,sp
		fcb	illegal		,tillegal	,sp
		fcb	extended	,tinc		,sp
		fcb	extended	,ttst		,sp
		fcb	extended	,tjmp		,sp
		fcb	extended	,tclr		,sp

		fcb	immediate	,tsub		,regA	; $80
		fcb	immediate	,tcmp		,regA
		fcb	immediate	,tsbc		,regA
		fcb	imm16		,tsub		,regD
		fcb	immediate	,tand		,regA
		fcb	immediate	,tbit		,regA
		fcb	immediate	,tld		,regA
		fcb	illegal		,tillegal	,sp
		fcb	immediate	,teor		,regA
		fcb	immediate	,tadc		,regA
		fcb	immediate	,tor		,regA
		fcb	immediate	,tadd		,regA
		fcb	imm16		,tcmp		,regX
		fcb	relative	,tbsr		,sp
		fcb	imm16		,tld		,regX
		fcb	illegal		,tillegal	,sp

		fcb	direct		,tsub		,regA	; $90
		fcb	direct		,tcmp		,regA
		fcb	direct		,tsbc		,regA
		fcb	direct		,tsub		,regD
		fcb	direct		,tand		,regA
		fcb	direct		,tbit		,regA
		fcb	direct		,tld		,regA
		fcb	direct		,tst		,regA
		fcb	direct		,teor		,regA
		fcb	direct		,tadc		,regA
		fcb	direct		,tor		,regA
		fcb	direct		,tadd		,regA
		fcb	direct		,tcmp		,regX
		fcb	direct		,tjsr		,sp
		fcb	direct		,tld		,regX
		fcb	direct		,tst		,regX

		fcb	indexed		,tsub		,regA	; $A0
		fcb	indexed		,tcmp		,regA
		fcb	indexed		,tsbc		,regA
		fcb	indexed		,tsub		,regD
		fcb	indexed		,tand		,regA
		fcb	indexed		,tbit		,regA
		fcb	indexed		,tld		,regA
		fcb	indexed		,tst		,regA
		fcb	indexed		,teor		,regA
		fcb	indexed		,tadc		,regA
		fcb	indexed		,tor		,regA
		fcb	indexed		,tadd		,regA
		fcb	indexed		,tcmp		,regX
		fcb	indexed		,tjsr		,sp
		fcb	indexed		,tld		,regX
		fcb	indexed		,tst		,regX

		fcb	extended	,tsub		,regA	; $B0
		fcb	extended	,tcmp		,regA
		fcb	extended	,tsbc		,regA
		fcb	extended	,tsub		,regD
		fcb	extended	,tand		,regA
		fcb	extended	,tbit		,regA
		fcb	extended	,tld		,regA
		fcb	extended	,tst		,regA
		fcb	extended	,teor		,regA
		fcb	extended	,tadc		,regA
		fcb	extended	,tor		,regA
		fcb	extended	,tadd		,regA
		fcb	extended	,tcmp		,regX
		fcb	extended	,tjsr		,sp
		fcb	extended	,tld		,regX
		fcb	extended	,tst		,regX

		fcb	immediate	,tsub		,regB	; $C0
		fcb	immediate	,tcmp		,regB
		fcb	immediate	,tsbc		,regB
		fcb	imm16		,tadd		,regD
		fcb	immediate	,tand		,regB
		fcb	immediate	,tbit		,regB
		fcb	immediate	,tld		,regB
		fcb	illegal		,tillegal	,sp
		fcb	immediate	,teor		,regB
		fcb	immediate	,tadc		,regB
		fcb	immediate	,tor		,regB
		fcb	immediate	,tadd		,regB
		fcb	imm16		,tld		,regD
		fcb	illegal		,tillegal	,sp
		fcb	imm16		,tld		,regU
		fcb	illegal		,tillegal	,sp

		fcb	direct		,tsub		,regB	; $D0
		fcb	direct		,tcmp		,regB
		fcb	direct		,tsbc		,regB
		fcb	direct		,tadd		,regD
		fcb	direct		,tand		,regB
		fcb	direct		,tbit		,regB
		fcb	direct		,tld		,regB
		fcb	direct		,tst		,regB
		fcb	direct		,teor		,regB
		fcb	direct		,tadc		,regB
		fcb	direct		,tor		,regB
		fcb	direct		,tadd		,regB
		fcb	direct		,tld		,regD
		fcb	direct		,tst		,regD
		fcb	direct		,tld		,regU
		fcb	direct		,tst		,regU

		fcb	indexed		,tsub		,regB	; $E0
		fcb	indexed		,tcmp		,regB
		fcb	indexed		,tsbc		,regB
		fcb	indexed		,tadd		,regD
		fcb	indexed		,tand		,regB
		fcb	indexed		,tbit		,regB
		fcb	indexed		,tld		,regB
		fcb	indexed		,tst		,regB
		fcb	indexed		,teor		,regB
		fcb	indexed		,tadc		,regB
		fcb	indexed		,tor		,regB
		fcb	indexed		,tadd		,regB
		fcb	indexed		,tld		,regD
		fcb	indexed		,tst		,regD
		fcb	indexed		,tld		,regU
		fcb	indexed		,tst		,regU

		fcb	extended	,tsub		,regB	; $F0
		fcb	extended	,tcmp		,regB
		fcb	extended	,tsbc		,regB
		fcb	extended	,tadd		,regD
		fcb	extended	,tand		,regB
		fcb	extended	,tbit		,regB
		fcb	extended	,tld		,regB
		fcb	extended	,tst		,regB
		fcb	extended	,teor		,regB
		fcb	extended	,tadc		,regB
		fcb	extended	,tor		,regB
		fcb	extended	,tadd		,regB
		fcb	extended	,tld		,regD
		fcb	extended	,tst		,regD
		fcb	extended	,tld		,regU
		fcb	extended	,tst		,regU

;---------------------------------------------------------------------
; Extended opcode information.  The structure here is:
;
;	2nd byte of opcode
;	addressing mode
;	text of opcode
;	additional text for opcode
;---------------------------------------------------------------------

opsp1		fcb	$21,lrelative	,tbrn		,sp
		fcb	$22,lrelative	,tbhi		,sp
		fcb	$23,lrelative	,tbls		,sp
		fcb	$24,lrelative	,tbcc		,sp
		fcb	$25,lrelative	,tbcs		,sp
		fcb	$26,lrelative	,tbne		,sp
		fcb	$27,lrelative	,tbeq		,sp
		fcb	$28,lrelative	,tbvc		,sp
		fcb	$29,lrelative	,tbvs		,sp
		fcb	$2A,lrelative	,tbpl		,sp
		fcb	$2B,lrelative	,tbmi		,sp
		fcb	$2C,lrelative	,tbge		,sp
		fcb	$2D,lrelative	,tblt		,sp
		fcb	$2E,lrelative	,tbgt		,sp
		fcb	$2F,lrelative	,tble		,sp
		fcb	$3F,inherent	,tswi		,t2
		fcb	$83,imm16	,tcmp		,regD
		fcb	$8C,imm16	,tcmp		,regY
		fcb	$8E,imm16	,tld		,regY
		fcb	$93,direct	,tcmp		,regD
		fcb	$9C,direct	,tcmp		,regY
		fcb	$9E,direct	,tld		,regY
		fcb	$9F,direct	,tst		,regY
		fcb	$A3,indexed	,tcmp		,regD
		fcb	$AC,indexed	,tcmp		,regY
		fcb	$AE,indexed	,tld		,regY
		fcb	$AF,indexed	,tst		,regY
		fcb	$B3,extended	,tcmp		,regD
		fcb	$BC,extended	,tcmp		,regY
		fcb	$BE,extended	,tld		,regY
		fcb	$BF,extended	,tst		,regY
		fcb	$CE,imm16	,tld		,regS
		fcb	$DE,direct	,tld		,regS
		fcb	$DF,direct	,tst		,regS
		fcb	$EE,indexed	,tld		,regS
		fcb	$EF,indexed	,tst		,regS
		fcb	$FE,extended	,tld		,regS
		fcb	$FF,extended	,tst		,regS
		fcb	$00,illegal	,tillegal	,sp

opsp2		fcb	$3F,inherent	,tswi		,t3
		fcb	$83,imm16	,tcmp		,regU
		fcb	$8C,imm16	,tcmp		,regS
		fcb	$93,direct	,tcmp		,regU
		fcb	$9C,direct	,tcmp		,regS
		fcb	$A3,indexed	,tcmp		,regU
		fcb	$AC,indexed	,tcmp		,regS
		fcb	$B3,extended	,tcmp		,regU
		fcb	$BC,extended	,tcmp		,regS
		fcb	$00,illegal	,tillegal	,sp

;--------------------------------------------------------

jmptab		lbra	fillegal
		lbra	finherent
		lbra	fimmediate
		lbra	fdirect
		lbra	fextended
		lbra	findexed
		lbra	frelative
		lbra	flrelative
		lbra	fpage1
		lbra	fpage2
		lbra	fexg
		lbra	fpushpull
		lbra	fimm16


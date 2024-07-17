;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; unassemble_cmd.asm - implements the "unassemble" command.
;
		import	g.argc
		import	g.argv
		import	g.commandLine
		import	g.linesPerPage

		import	putStr
		import  putChar
		import	putNL		globals
		import	strToHex
		import	disasm
		import	padToCol

		section globals
g.unassembleAddress rmb	2

		section code

		export	unassembleMinArgs
		export	unassembleMaxArgs
		export	unassembleCommand
		export	unassembleHelp
unassembleMinArgs equ	0
unassembleMaxArgs equ	1
unassembleCommand fcn	"unassemble"
unassembleHelp	fcn	"[<address>]\tUnassemble code"

		export	unassembleFn
unassembleFn	lda	g.argc
		cmpa	#2		; Address was supplied
		bne	duNoArgs

; A start address was supplied
		leax	g.argv,pcr
		ldx	2,x
		lbsr	strToHex
		bcs	duBadArgs
		std	g.unassembleAddress
		
duNoArgs	ldy	g.unassembleAddress
		leax	g.commandLine,pcr
		ldb	g.linesPerPage

duNext		bsr	disassembleInstruction
		decb
		bne	duNext
		sty	g.unassembleAddress
duDone		rts
		
duBadArgs	leax	du_msg_1,pcr
		lbsr	putStr
		rts

du_msg_1	fcn	"Badly formatted address.\r\n"


disassembleInstruction
		pshs	a,b,x,u
		* leax	g.zobbo,pcr
		leax	g.commandLine,pcr

		lbsr	disasm
		
		ldu	,x++			; Address
		bsr	ddPr4
		pshs	x
		leax	ddsep_1_msg,pcr
		lbsr	putStr
		puls	x

		ldu	,x++			; Instruction code
		bsr	ddPr4
		ldu	,x++			; Operand code
		bsr	ddPr4

		lda	#24
		lbsr	padToCol

		ldu	,x++			; Instruction text
		bsr	ddPr

		lda	#32
		lbsr	padToCol
		ldu	,x			; Operand text
		bsr	ddPr

		lbsr	putNL

		puls	a,b,x,u,pc

ddsep_1_msg	fcn	":  "


ddPr		pshs	b,a
		ldb	#100
		bra	print

ddPr2		pshs	b,a
		ldb	#2
		bra	print

ddPr4		pshs	b,a
		ldb	#4
print		lda	,u+
		beq	done
		lbsr	putChar
		decb
		bne	print

done		puls	b,a,pc

		end section
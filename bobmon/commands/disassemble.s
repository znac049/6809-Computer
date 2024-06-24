		globals

g.unassembleAddress rmb	2

		code

disassMinArgs	equ	0
disassMaxArgs	equ	1
disassembleCommand
		fcn	"unassemble"
disassembleHelp	fcn	"[<address>]",TAB,"Unassemble code"

doDisassemble	lda	g.argc
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

du_msg_1	fcn	"Badly formatted address.",CR,LF


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
		bra	1F

ddPr2		pshs	b,a
		ldb	#2
		bra	1F

ddPr4		pshs	b,a
		ldb	#4
1		lda	,u+
		beq	ddpDone
		lbsr	putChar
		decb
		bne	1B

ddpDone		puls	b,a,pc
disassMinArgs	equ	0
disassMaxArgs	equ	1
disassembleCommand
		fcn	"disassemble"
disassembleHelp	fcn	"[<address>]",TAB,"Disassemble code"

doDisassemble	leax	g.commandLine,pcr
		ldy	#$4000
		
		lbsr	disasm
		
		ldd	#g.commandLine
		lbsr	putHexWord
		lbsr	putNL
		tfr	y,d
		lbsr	putHexWord
		lbsr	putNL

		rts

disassMinArgs	equ	0
disassMaxArgs	equ	1
disassembleCommand
		fcn	"disassemble"
disassembleHelp	fcn	"[<address>]",TAB,"Disassemble code"

doDisassemble	lbsr	Disassemble
		rts

bootMinArgs	equ	0
bootMaxArgs	equ	0
bootCommand	fcn	"boot"
bootHelp	fcn	TAB,"Attempt to boot from disk"

doBoot
		rts
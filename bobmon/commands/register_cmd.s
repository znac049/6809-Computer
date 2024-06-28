registersMinArgs equ	0
registersMaxArgs equ	0
registersCommand fcn	"registers"
registersHelp	fcn	TAB,"Display system registers"

		globals

g.regA		rmb	1
g.regB		rmb	1
g.regX		rmb	2
g.regY		rmb	2
g.regU		rmb	2
g.regS		rmb	2


		code

doRegisters	pshs	a,b,x,y,u
		leax	regA_msg,pcr
		lbsr	putStr
		ldb	g.regA
		clra
		* ldd	#$DEAD
		lbsr	printNum		; putHexByte
		
		leax	regB_msg,pcr
		lbsr	putStr
		ldb	g.regB
		clra	
		* ldd	#$FACE
		lbsr	printNum		; putHexByte
		
		leax	regX_msg,pcr
		lbsr	putStr
		ldd	g.regX
		* ldd	#$00FF
		lbsr	printNum		; putHexWord
		
		leax	regY_msg,pcr
		lbsr	putStr
		ldd	g.regY
		* ldd	#1
		lbsr	printNum		; putHexWord
		
		leax	regU_msg,pcr
		lbsr	putStr
		ldd	g.regU
		* ldd	#0
		lbsr	printNum		; putHexWord
		
		leax	regS_msg,pcr
		lbsr	putStr
		ldd	g.regS
		* ldd	#$0CAB
		lbsr	printNum		; putHexWord

		lbsr	putNL
		
		puls	a,b,x,y,u,pc

regA_msg	fcn	"A:"
regB_msg	fcn	" B:"
regX_msg	fcn	" X:"
regY_msg	fcn	" Y:"
regU_msg	fcn	" U:"
regS_msg	fcn	" S:"

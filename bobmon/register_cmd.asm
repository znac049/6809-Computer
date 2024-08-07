;
; Simple 6809 Monitor
;
; Copyright(c) 2016-2024, Bob Green <bob@chippers.org.uk>
;
; register_cmd.asm - implements the "Go" command.
;
		import	printNum
		import	putStr
		import	putNL

		section globals

		export	g.regA
g.regA		rmb	1
		export	g.regB
g.regB		rmb	1
		export	g.regX
g.regX		rmb	2
		export	g.regY
g.regY		rmb	2
		export	g.regU
g.regU		rmb	2
		export	g.regS
g.regS		rmb	2


		section code
		
		export	registersMinArgs
		export	registersMaxArgs
		export	registersCommand
		export	registersHelp
registersMinArgs equ	0
registersMaxArgs equ	0
registersCommand fcn	"registers"
registersHelp	fcn	"\tDisplay system registers"


		export	registersFn
registersFn	pshs	a,b,x,y,u
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

		end section
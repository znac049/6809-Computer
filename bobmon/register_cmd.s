registersMinArgs equ	0
registersMaxArgs equ	0
registersCommand fcn	"registers"
registersHelp	fcn	TAB,"Display system registers"

doRegisters	pshs	a,b,x,y,u
		leax	reg_msg_1,pcr
		lbsr	putStr
		lbsr	putHexByte
		
		leax	reg_msg_2,pcr
		lbsr	putStr
		tfr	b,a
		lbsr	putHexByte
		
		leax	reg_msg_3,pcr
		lbsr	putStr
		tfr	x,d
		lbsr	putHexWord
		
		leax	reg_msg_4,pcr
		lbsr	putStr
		tfr	y,d
		lbsr	putHexWord
		
		leax	reg_msg_5,pcr
		lbsr	putStr
		tfr	u,d
		lbsr	putHexWord
		
		leax	reg_msg_6,pcr
		lbsr	putStr
		tfr	s,d
		lbsr	putHexWord

		lbsr	putNL
		
		puls	a,b,x,y,u,pc

reg_msg_1	fcn	"A:"
reg_msg_2	fcn	" B:"
reg_msg_3	fcn	" X:"
reg_msg_4	fcn	" Y:"
reg_msg_5	fcn	" U:"
reg_msg_6	fcn	" S:"

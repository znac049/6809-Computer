;--------------------------------------------------------
;
; commands.s - command processing
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

; Main command table
cmd_table	fdb	doDebug
		fcn	"debug"

		fdb	doDump
		fcn	"dump"

		fdb	doRegisters
		fcn	"registers"

		fdb	doHelp
		fcn	"?"

		fdb	0

doDebug		rts

doDump		leax	dump_msg,pcr
		lbsr	putStr
		rts

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

doHelp		rts

dump_msg	fcn	CR,LF,"Dumping...",CR,LF

; matchCommand -
;
;  
matchCommand	pshs	x,y,b
		tfr	x,y
		leax	cmd_table,pcr

		ldd	#0
		std	-5,s
		clr	-3,s
		sty	-2,s

1		ldd	,x		; address of handler
		beq	5F		; end of command table
		stx	-5,s
		leax	2,x		; Point at start of command string

2		lda	,y+		; compare strings
		beq	4F		; end of string

		cmpa	#SPACE		; end of command?
		beq	4F

		cmpa	,x+		; compare string with command
		beq	2B

3		lda	,x+		; No match - skip over rest of string
		bne	3B
		ldy	-2,s		; next command
		bra	1B

4		ldy	-2,s		; It's a match - try the next command
		inc 	-3,s		; Increment the match count
		ldd	[-5,s]
		std	matched_command_ptr
		bra	1B

5		lda	-3,s
		puls	x,y,b,pc

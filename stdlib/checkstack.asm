	section code

_set_stack_overflow_handler	export
check_stack_overflow		export

stack_overflow_handler	import
end_of_sbrk_mem		import
INISTK			import

_set_stack_overflow_handler:
	ifndef OS9
	LDD	2,S	first argument
	STD	stack_overflow_handler,pcr
    endc
	RTS

check_stack_overflow:
	ifndef OS9

	PSHS    B,A
	LDD	stack_overflow_handler,pcr	is there a handler?
	BEQ	no_stack_overflow		no
	CMPS    end_of_sbrk_mem,pcr
	BLO     stack_overflow_detected
	CMPS	INISTK,pcr
	BLO	no_stack_overflow
stack_overflow_detected:
	LDD	stack_overflow_handler,pcr	get current handler
	LDX	#0				disable stack checking
	STX	stack_overflow_handler,pcr	because handler calls this routine
	TFR	D,X	preserve handler address in X, for the JSR

	TFR	S,D	pass out-of-range stack ptr as 2nd argument to handler
	ADDD	#4	don't count current routine call
	PSHS	B,A
	LDD	4,S	return address of LBSR that led to this routine
	SUBD	#3	point to LBSR instruction
	PSHS	B,A
	JSR	,X	handler does not have to return
stack_overflow_freeze:
	BRA	stack_overflow_freeze	freeze if handler returned
no_stack_overflow:
	PULS    A,B,PC

	ELSE
	RTS
	endc


	endsection

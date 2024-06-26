* 6809 assembly program generated by cmoc 0.1.86


	SECTION	code


___va_arg	IMPORT
_abs	IMPORT
_adddww	IMPORT
_atoi	IMPORT
_atol	IMPORT
_atoui	IMPORT
_atoul	IMPORT
_bsearch	IMPORT
_cmpdww	IMPORT
_delay	IMPORT
_divdwb	IMPORT
_divdww	IMPORT
_divmod16	IMPORT
_divmod8	IMPORT
_dwtoa	IMPORT
_enable_printf_float	IMPORT
_exit	IMPORT
_isalnum	IMPORT
_isalpha	IMPORT
_isdigit	IMPORT
_isspace	IMPORT
_itoa10	IMPORT
_labs	IMPORT
_ltoa10	IMPORT
_memchr	IMPORT
_memcmp	IMPORT
_memcpy	IMPORT
_memichr	IMPORT
_memicmp	IMPORT
_memmove	IMPORT
_memset	IMPORT
_memset16	IMPORT
_mulwb	IMPORT
_mulww	IMPORT
_printf	IMPORT
_putchar	IMPORT
_putstr	IMPORT
_qsort	IMPORT
_rand	IMPORT
_readline	IMPORT
_readword	IMPORT
_sbrk	IMPORT
_sbrkmax	IMPORT
_setConsoleOutHook	IMPORT
_set_null_ptr_handler	IMPORT
_set_stack_overflow_handler	IMPORT
_sprintf	IMPORT
_sqrt16	IMPORT
_sqrt32	IMPORT
_srand	IMPORT
_strcat	IMPORT
_strchr	IMPORT
_strcmp	IMPORT
_strcpy	IMPORT
_strcspn	IMPORT
_stricmp	IMPORT
_strlen	IMPORT
_strlwr	IMPORT
_strncmp	IMPORT
_strncpy	IMPORT
_strpbrk	IMPORT
_strrchr	IMPORT
_strspn	IMPORT
_strstr	IMPORT
_strtok	IMPORT
_strtol	IMPORT
_strtoul	IMPORT
_strupr	IMPORT
_subdww	IMPORT
_tolower	IMPORT
_toupper	IMPORT
_ultoa10	IMPORT
_utoa10	IMPORT
_vprintf	IMPORT
_vsprintf	IMPORT
_zerodw	IMPORT


*******************************************************************************

* FUNCTION printAsciiZ(): defined at assert.c:26
_printAsciiZ	EQU	*
.static.function.printAsciiZ	EQU	*
* Calling convention: Default
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      4,U:    2 bytes: s: const char *: line 26
	BRA	L00087		jump to for condition
L00086	EQU	*
* Line assert.c:29: for body
* Line assert.c:29: function call: putchar()
	LDB	[4,U]		indirection
	SEX			promoting byte argument to word
	PSHS	B,A		argument 1 of putchar(): const char
	LBSR	_putchar
	LEAS	2,S
* Useless label L00088 removed
* Line assert.c:28: for increment(s)
	LDD	4,U
	ADDD	#1
	STD	4,U
L00087	EQU	*
* Line assert.c:28: for condition
	LDB	[4,U]		indirection
* optim: loadCmpZeroBeqOrBne
	BNE	L00086
* optim: branchToNextLocation
* Useless label L00089 removed
* Useless label L00080 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION printAsciiZ(): defined at assert.c:26
funcend_printAsciiZ	EQU *
funcsize_printAsciiZ	EQU	funcend_printAsciiZ-_printAsciiZ
__OnFailedAssert	EXPORT


*******************************************************************************

* FUNCTION _OnFailedAssert(): defined at assert.c:34
__OnFailedAssert	EQU	*
* Calling convention: Default
	PSHS	U
	LEAU	,S
	LEAS	-6,S
* Formal parameter(s):
*      4,U:    2 bytes: file: const char *: line 34
*      6,U:    2 bytes: lineno: int: line 34
*      8,U:    2 bytes: condition: const char *: line 34
* Local non-static variable(s):
*     -6,U:    6 bytes: tmp: char[]: line 46
* Line assert.c:36: if
	LDD	_failedAssertHandler+0,PCR	variable `failedAssertHandler', declared at assert.c:22
* optim: loadCmpZeroBeqOrBne
	BEQ	L00091		 (optim: condBranchOverUncondBranch)
* optim: condBranchOverUncondBranch
* Useless label L00090 removed
* Line assert.c:37
* Line assert.c:38: function call through pointer
	LDD	8,U		variable `condition', declared at assert.c:34
	PSHS	B,A		argument 3: const char *
	LDD	6,U		variable `lineno', declared at assert.c:34
	PSHS	B,A		argument 2: int
	LDD	4,U		variable `file', declared at assert.c:34
	PSHS	B,A		argument 1: const char *
	JSR	[_failedAssertHandler+0,PCR]
	LEAS	6,S
	LBRA	L00081		return (assert.c:39)
L00091	EQU	*		else clause of if() started at assert.c:36
* Useless label L00092 removed
* Line assert.c:43: function call: printAsciiZ()
	LEAX	S00084,PCR	"***ASSERT FAILED: "
	PSHS	X		argument 1 of printAsciiZ(): const char[]
	LBSR	_printAsciiZ
	LEAS	2,S
* Line assert.c:44: function call: printAsciiZ()
	LDD	4,U		variable `file', declared at assert.c:34
	PSHS	B,A		argument 1 of printAsciiZ(): const char *
	LBSR	_printAsciiZ
	LEAS	2,S
* Line assert.c:45: function call: putchar()
	LDB	#$3A		decimal 58 signed
	SEX			promoting byte argument to word
	PSHS	B,A		argument 1 of putchar(): char
	LBSR	_putchar
	LEAS	2,S
* Line assert.c:47: function call: printAsciiZ()
* Line assert.c:47: function call: itoa10()
	LEAX	-6,U		address of array tmp
* optim: optimizePshsOps
	LDD	6,U		variable `lineno', declared at assert.c:34
	PSHS	X,B,A		optim: optimizePshsOps
	LBSR	_itoa10
	LEAS	4,S
	PSHS	B,A		argument 1 of printAsciiZ(): char *
	LBSR	_printAsciiZ
	LEAS	2,S
* Line assert.c:48: function call: printAsciiZ()
	LEAX	S00085,PCR	": "
	PSHS	X		argument 1 of printAsciiZ(): const char[]
	LBSR	_printAsciiZ
	LEAS	2,S
* Line assert.c:49: function call: printAsciiZ()
	LDD	8,U		variable `condition', declared at assert.c:34
	PSHS	B,A		argument 1 of printAsciiZ(): const char *
	LBSR	_printAsciiZ
	LEAS	2,S
* Line assert.c:50: function call: putchar()
	LDB	#$0A		decimal 10 signed
	SEX			promoting byte argument to word
	PSHS	B,A		argument 1 of putchar(): char
	LBSR	_putchar
	LEAS	2,S
* Line assert.c:52: if
	LDB	_freezeOnFailedAssert+0,PCR	variable `freezeOnFailedAssert', declared at assert.c:20
* optim: loadCmpZeroBeqOrBne
	BNE	L00094
* optim: branchToNextLocation
* Useless label L00093 removed
* Line assert.c:53
* Line assert.c:53: function call: exit()
	CLRA
	LDB	#$01		decimal 1 signed
	PSHS	B,A		argument 1 of exit(): int
	LBSR	_exit
	LEAS	2,S
L00094	EQU	*		else clause of if() started at assert.c:52
* Useless label L00095 removed
L00096	EQU	*
* Line assert.c:55: for body
* Useless label L00098 removed
	BRA	L00096
* Useless label L00099 removed
L00081	EQU	*		end of _OnFailedAssert()
	LEAS	,U
	PULS	U,PC
* END FUNCTION _OnFailedAssert(): defined at assert.c:34
funcend__OnFailedAssert	EQU *
funcsize__OnFailedAssert	EQU	funcend__OnFailedAssert-__OnFailedAssert
__FreezeOnFailedAssert	EXPORT


*******************************************************************************

* FUNCTION _FreezeOnFailedAssert(): defined at assert.c:60
__FreezeOnFailedAssert	EQU	*
* Calling convention: Default
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      4,U:    2 bytes: freeze: int: line 60
* Line assert.c:62: assignment: =
	LDD	4,U		variable freeze
* optim: loadCmpZeroBeqOrBne
	BNE	L00100		if true
	CLRB
	BRA	L00101		false
L00100	EQU	*
	LDB	#1
L00101	EQU	*
	STB	_freezeOnFailedAssert+0,PCR
* Useless label L00082 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION _FreezeOnFailedAssert(): defined at assert.c:60
funcend__FreezeOnFailedAssert	EQU *
funcsize__FreezeOnFailedAssert	EQU	funcend__FreezeOnFailedAssert-__FreezeOnFailedAssert
__SetFailedAssertHandler	EXPORT


*******************************************************************************

* FUNCTION _SetFailedAssertHandler(): defined at assert.c:66
__SetFailedAssertHandler	EQU	*
* Calling convention: Default
	PSHS	U
	LEAU	,S
* Formal parameter(s):
*      4,U:    2 bytes: newHandler: void (*)(const char *, int, const char *): line 66
* Line assert.c:68: assignment: =
* optim: stripConsecutiveLoadsToSameReg
	LDD	4,U
	STD	_failedAssertHandler+0,PCR
* Useless label L00083 removed
	LEAS	,U
	PULS	U,PC
* END FUNCTION _SetFailedAssertHandler(): defined at assert.c:66
funcend__SetFailedAssertHandler	EQU *
funcsize__SetFailedAssertHandler	EQU	funcend__SetFailedAssertHandler-__SetFailedAssertHandler


	ENDSECTION




	SECTION	initgl




*******************************************************************************

* Initialize global variables.


	ENDSECTION




	SECTION	rodata


string_literals_start	EQU	*


*******************************************************************************

* STRING LITERALS
S00084	EQU	*
	FCC	"***ASSERT FAILED: "
	FCB	0
S00085	EQU	*
	FCC	": "
	FCB	0
string_literals_end	EQU	*


*******************************************************************************

* READ-ONLY GLOBAL VARIABLES


	ENDSECTION




	SECTION	rwdata


* Statically-initialized global variables
_freezeOnFailedAssert	EQU	*		freezeOnFailedAssert: unsigned char: assert.c:20
	FCB	$00		decimal 0
.global.static.variable.freezeOnFailedAssert	EQU	*
_failedAssertHandler	EQU	*		failedAssertHandler: void (*)(const char *, int, const char *): assert.c:22
	FDB	$00		0 decimal
.global.static.variable.failedAssertHandler	EQU	*
* Statically-initialized local static variables


	ENDSECTION




	SECTION	bss


bss_start	EQU	*
* Uninitialized global variables
* Uninitialized local static variables
bss_end	EQU	*


	ENDSECTION




*******************************************************************************

* Importing 3 utility routine(s).
_exit	IMPORT
_itoa10	IMPORT
_putchar	IMPORT


*******************************************************************************

	END

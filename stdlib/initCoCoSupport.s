* 6809 assembly program generated by cmoc 0.1.86


	SECTION	code


_isCoCo3	IMPORT
_textScreenWidth	IMPORT
_textScreenHeight	IMPORT
_isCoCo3	EXPORT
_textScreenWidth	EXPORT
_textScreenHeight	EXPORT
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
_initCoCoSupport	EXPORT


*******************************************************************************

* FUNCTION initCoCoSupport(): defined at initCoCoSupport.c:9
_initCoCoSupport	EQU	*
* Calling convention: Default
* Line initCoCoSupport.c:15: assignment: =
	CLR	_isCoCo3+0,PCR	variable isCoCo3
* Line initCoCoSupport.c:17: assignment: =
	LDB	#$20
	STB	_textScreenWidth+0,PCR	variable textScreenWidth
* Line initCoCoSupport.c:18: assignment: =
	LDB	#$10
	STB	_textScreenHeight+0,PCR	variable textScreenHeight
* Useless label L00078 removed
	RTS
* END FUNCTION initCoCoSupport(): defined at initCoCoSupport.c:9
funcend_initCoCoSupport	EQU *
funcsize_initCoCoSupport	EQU	funcend_initCoCoSupport-_initCoCoSupport


	ENDSECTION




	SECTION	initgl




*******************************************************************************

* Initialize global variables.


	ENDSECTION




	SECTION	rodata


string_literals_start	EQU	*
string_literals_end	EQU	*


*******************************************************************************

* READ-ONLY GLOBAL VARIABLES


	ENDSECTION




	SECTION	rwdata


* Statically-initialized global variables
* Statically-initialized local static variables


	ENDSECTION




	SECTION	bss


bss_start	EQU	*
* Uninitialized global variables
_isCoCo3	EQU	*
	RMB	1		isCoCo3: unsigned char: initCoCoSupport.c:4
_textScreenWidth	EQU	*
	RMB	1		textScreenWidth: unsigned char: initCoCoSupport.c:5
_textScreenHeight	EQU	*
	RMB	1		textScreenHeight: unsigned char: initCoCoSupport.c:6
* Uninitialized local static variables
bss_end	EQU	*


	ENDSECTION




*******************************************************************************

* Importing 0 utility routine(s).


*******************************************************************************

	END
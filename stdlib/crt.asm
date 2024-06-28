	        INCLUDE std.inc

	        SECTION code

INILIB		EXPORT
_exit		EXPORT
INISTK          EXPORT
CHROUT          EXPORT
null_ptr_handler        EXPORT
unpackSingleAndConvertToASCII_hook EXPORT
singlePrecisionSize     EXPORT
nop_handler     EXPORT

end_of_sbrk_mem EXPORT
program_break   EXPORT
stack_overflow_handler  EXPORT

INITGL		IMPORT
program_end	IMPORT



; Initializes the standard library.
; Input: D = minus the number of bytes for the stack space (e.g., -1024 for 1k stack).
;        Not used under OS-9.
; Initializes the "bss" section with zeroes, under non OS-9 platforms.
; Saves the initial stack for use by exit().
; Initializes internal variables used by sbrk(), except under OS-9.
; Initializes the null pointer handler pointer.
; Initializes the stack overflow handler pointer, except under OS-9.
; Initializes CHROUT, which points to the system's character output routine.
; Initializes the user program's global variables.
;
INILIB          pshs    d

; Zero out BSS segment (for OS-9, done by OS9PREP).
; Must be done first, because code that follows initializes INISTK, etc.
l_bss           IMPORT
s_bss           IMPORT

                leax    ini_msg_1,pcr
                sys     scPutStr
                ldd     #l_bss
                sys     scPut4Hex
                sys     scPutNL

                leax    ini_msg_2,pcr
                sys     scPutStr
                leax    s_bss,pcr
                tfr     x,d
                sys     scPut4Hex
                sys     scPutNL

                puls    d
                
                LDX     #l_bss                  ; number of bytes in "bss" section
                BEQ     @done
                LEAU    s_bss,pcr               ; address of "bss" section
@loop
                CLR     ,U+
                LEAX    -1,X
                BNE     @loop
@done

                ldx     #$4000
	        STX	INISTK,pcr		save this for exit()

	        LEAX	D,X			point to top of stack space
	        STX	end_of_sbrk_mem,pcr	sbrk() will not allocate past this
	        LEAX	program_end,PCR		end of generated code and data
	        STX	program_break,pcr	initial Unix-like "program break" (cf sbrk)

	        LEAX	nop_handler,PCR
	        STX	null_ptr_handler,pcr

                LDX	#0
	        STX	stack_overflow_handler,pcr	

	        LEAX	PUTCHR,PCR
	        STX	CHROUT,pcr

; Install dummy routine in hook that converts a float to decimal.
; See enable_printf_float.asm.
                LEAX    unpackSingleAndConvertToASCII_dummy,PCR         ; PCR in caps b/c ref to code
                STX     unpackSingleAndConvertToASCII_hook,pcr          ; pcr in lower-case b/c ref to data

	        LBSR	INITGL		initialize global variables
                LBRA    constructors

ini_msg_1       fcn     "BSS length: "
ini_msg_2       fcn     "BSS base  : "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; See also unpackSingleAndConvertToASCII.asm.
;
unpackSingleAndConvertToASCII_dummy
        ; Write "!" at U.
	LDB     #'!
        STB     ,u
        CLR     1,u
        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

* void exit(int exitStatus);
*
* Clean up before returning control to the host environment.
* That environment does not necessarily use the exit status.
* It may only use the low byte.
*
* MUST be called by BSR, LBSR or JSR, not jumped to with BRA, LBRA or JMP,
* so that 2,S can be used to get 'exitStatus'.
*
_exit
	ldd	2,s
        sys     scTerminate
	LBSR	destructors

	IFDEF USIM

	SYNC			to leave usim

	ENDC


nop_handler:
	RTS


	ENDSECTION


	SECTION bss

INISTK		RMB	2		receives initial stack pointer

; Initialized by INILIB to an RTS routine.
; Call set_null_ptr_handler() to specify another handler.
; The handler is assumed to have this signature:
; void handler(char *addressOfFailedCheck);
;
null_ptr_handler	RMB	2

; Initialized by INILIB to a null pointer.
; Call set_stack_overflow_handler() to specify another handler.
; The handler is assumed to have this signature:
; void handler(char *addressOfFailedCheck, char *stackRegister);
;
stack_overflow_handler	RMB	2


end_of_sbrk_mem	RMB	2
program_break	RMB	2

CHROUT  RMB     2       Routine to write char to current device

; Pointer to a routine that does something if floating-point support is enabled,
; or writes a placeholder string otherwise. See enable_printf_float().
; Used by CMOC's printf() implementation (see printf.asm).
; Initialized by float-ctor.asm in the ECB/Dragon cases.
;
unpackSingleAndConvertToASCII_hook RMB 2

; Size in bytes of the float type. Used by printf.asm.
;
singlePrecisionSize RMB 1

	ENDSECTION


        SECTION code

PUTCHR  EXPORT


	IFDEF USIM

* Code to be used with the version of usim that CMOC is shipped with.
*
PUTCHR	STA	$FF00
	RTS

        ENDC


        IFDEF _CMOC_VOID_TARGET_

PUTCHR	swi
	fdb	1
	RTS

        ENDC


        ENDSECTION


* This section will precede the "constructors" section, i.e., all code that initializes
* user libraries. Such code must not end with an RTS instruction.
* This section exists to define the address of the pre-main constructor subroutine.
        SECTION constructors_start
constructors
        ENDSECTION

# This section will follow the "constructors" section. It ends the pre_main_init routine.
        SECTION constructors_end
        RTS
        ENDSECTION


* Similarly for destructor code.
        SECTION destructors_start
destructors
        ENDSECTION

        SECTION destructors_end
        RTS
        ENDSECTION

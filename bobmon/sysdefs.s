;--------------------------------------------------------
;
; sysdefs.s - hardware specific definitions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

;
; Ram specific
;
ram_start		equ	0
ram_size		equ	$8000
ram_end			equ	(ram_start+ram_size)-1

;
; Rom specific
;
rom_start		equ	$c000

vectorTable_start	equ	$fff0

Uart0Base	equ	$a000
Uart1Base	equ	$a008
CFBase		equ	$a010
RegBase		equ	$a030
MMUBase		equ	$a040
SDBase		equ	$a050
FDCBase		equ	$a060

; Virtual disk controller registers
FDC.SR		equ	0
FDC.CMD		equ	0
FDC.DR		equ	1
FDC.Sec2	equ	2
FDC.Sec1	equ	3
FDC.Sec0	equ	4

; ATA CF device registers
; When CS0 is asserted (low)
CF.Data		equ	0	; R/W
CF.Error	equ	1	; Read
CF.Features	equ 	1	; Write
CF.SecCnt	equ	2	; R/W
CF.LSN0		equ	3	; R/W - bits  0-7
CF.LSN1		equ	4	; R/W - bits  8-15
CF.LSN2		equ	5	; R/W - bits 16-23
CF.LSN3		equ	6	; R/W - bits 24-27
CF.Status	equ	7	; Read
CF.Command	equ	7	; Write

; Status register
SR.BSYMask	equ	$80
SR.DRDYMask	equ	$40
SR.DFMask	equ	$20
SR.DSCMask	equ	$10
SR.DRQMask	equ	$08
SR.CORRMask	equ	$04
SR.IDXMask	equ	$02
SR.ERRMask	equ	$01

; Commands
CMD.RESET	equ	$04
CMD.IDENTIFY	equ	$EC
CMD.READLONG	equ	$22
CMD.WRITELONG	equ	$32
CMD.DIAG	equ	$90
CMD.IDENTIFYDEV	equ	$ec
CMD.SETFEATURES	equ	$EF

; When CS1 is asserted (low)
CF.AltStatus	equ	22	; Read
CF.DevControl	equ	22	; Write

; SD Controller registers
SD.Data		equ	0			; data register
SD.Ctrl		equ	1
SD.Status	equ	1
SD.LBA0		equ	2
SD.LBA1		equ	3
SD.LBA2		equ	4
SD.LBA3		equ     5

MAXLINE		equ	128
SECSIZE		equ	512

;
; Monitor
;
system_stack		equ	$0200
user_stack		equ	$0400

;
; System calls
;
scGetChar		equ	0	; Input character with no parity
scPutChar		equ	1	; Output chaarcter
scPutStr		equ	2	; Print a string (EOS terminated)
scPutNLStr		equ	3	; Put CR/LF and string
scPut2Hex		equ	4	; Output two digit hex and a space
scPut4Hex		equ	5	; Output four digit hex and a space
scPutNL			equ	6
scPutSpace		equ	7
scEnterMonitor		equ	8	; Reenter the monitor

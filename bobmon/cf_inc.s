CFBase		equ	$a008

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
SR.DWFMask	equ	$20
SR.DSCMask	equ	$10
SR.DRQMask	equ	$08
SR.CORRMask	equ	$04
SR.IDXMask	equ	$02
SR.ERRMask	equ	$01

; Commands
CFCMD.RESET	equ	$04
CFCMD.IDENTIFY	equ	$EC
CFCMD.READ	equ	$20
CFCMD.READLONG	equ	$22
CFCMD.WRITELONG	equ	$32
CFCMD.DIAG	equ	$90
CFCMD.IDENTIFYDEV	equ	$ec
CFCMD.SETFEATURES	equ	$EF


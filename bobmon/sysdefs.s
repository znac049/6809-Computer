;--------------------------------------------------------
;
; sysdefs.s - hardware specific definitions
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;

; What CPU are we targetting?
target_6809		equ	1
target_6309		equ	0


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
Uart1Base	equ	$a020
VDiskBase	equ	$a008

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


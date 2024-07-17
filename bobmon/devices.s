; Device addresses
Uart0Base	equ	$a000
Uart1Base	equ	$a020
VDiskBase	equ	$a008

		include	"cf_inc.s"



; Character Devices
CDev.BaseAddr	equ	0	; Base address of device
CDev.InitFn	equ	2	; Initialisation function
CDev.Info	equ	4	; Info block
CDev.CanRead	equ	6	; Character available
CDev.CanWrite	equ	8	; Data buffer has space for a character
CDev.Read	equ	10	; Read a character
CDev.Write	equ	12	; Write a character
Sizeof.CDev	equ	14

; Character device Info block
CInfo.Name	equ	0
Sizeof.CInfo	equ	2


; Block Devices
BDev.BaseAddr	equ	CDev.BaseAddr	; Base address of device 
BDev.InitFn	equ	CDev.InitFn	; Initialisation function
BDev.Info	equ	CDev.Info	; Static disk information
BDev.ReadBlock	equ	6	; Read a block of data
BDev.WriteBlock	equ	8	; Write a block of data
Sizeof.BDev	equ	10

; Block device info block
BInfo.Name	equ	CInfo.Name	; pointer to string
Sizeof.BInfo	equ	2


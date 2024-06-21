	INCLUDE std.inc

	SECTION code

_delay	EXPORT

* Wait for a number of ticks (1/60 second) which is given on the stack.
_delay
	IFDEF USIM

	LDD	2,S		number of ticks to wait
	STD	$FF02		ask simulator to wait
	RTS

	ENDC


	IFDEF _CMOC_VOID_TARGET_

	RTS

	ENDC


	ENDSECTION

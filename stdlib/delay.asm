	include std.inc

	section code

_delay	export

* Wait for a number of ticks (1/60 second) which is given on the stack.
_delay
	ifdef USIM

	LDD	2,S		number of ticks to wait
	STD	$FF02		ask simulator to wait
	RTS

	endc


	ifdef _CMOC_VOID_TARGET_

	RTS

	endc


	endsection

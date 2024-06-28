        section code

convertABToUpperCase    export


convertABToUpperCase:
		bsr		convertAToUpperCaseAndExg
convertAToUpperCaseAndExg:
		cmpa	#'a
		blo		@done
		cmpa	#'z
		bhi		@done
		suba	#32
@done
		exg		a,b
		rts


        endsection

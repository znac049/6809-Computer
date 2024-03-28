toupper		pshs	cc
		cmpa	#$61
		bmi	toupper_done
		cmpa	#$7a
		bhi	toupper_done
		suba	#$20
toupper_done	puls	cc
		rts

tolower		pshs	cc
		cmpa	#$41
		bmi	tolower_done
		cmpa	#$5a
		bhi	tolower_done
		adda	#$20
tolower_done	puls	cc
		rts


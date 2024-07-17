;--------------------------------------------------------
;
; system_vectors.s - CPU vector table
;
; 	(C) Bob Green <bob@chippers.org.uk> 2024
;
;		System vector specification
;
		import	handle_undef
		import	handle_swi3
		import	handle_swi2
		import	handle_firq
		import	handle_irq
		import	handle_swi
		import	handle_nmi
		import	handle_reset
		
		section	vectors

		fdb	handle_undef	; $fff0
		fdb	handle_swi3	; $fff2
		fdb	handle_swi2	; $fff4
		fdb	handle_firq	; $fff6
		fdb	handle_irq	; $fff8
		fdb	handle_swi	; $fffa
		fdb	handle_nmi	; $fffc
		fdb	handle_reset	; $fffe

		end section
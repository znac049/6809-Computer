	section code

tfrZtoB	export


* Transfer condition code Z to B.
* Output: B = 0 or 1.
*
tfrZtoB
        tfr     cc,b
        andb    #4              ; keep Z flag
        lsrb
        lsrb
        rts


        endsection

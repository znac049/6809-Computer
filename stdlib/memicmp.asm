        section code

_memicmp                export

convertABToUpperCase    import
memcmpimpl              import


_memicmp
        leax    compareBytes,PCR
        lbra    memcmpimpl


compareBytes
        lda     ,x+
        ldb     ,u+
        lbsr    convertABToUpperCase
        pshs    b
        cmpa    ,s+
        rts


        endsection

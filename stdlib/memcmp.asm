        section code

_memcmp         export

memcmpimpl      import


_memcmp
        leax    compareBytes,PCR
        lbra    memcmpimpl


compareBytes
        lda     ,x+
        cmpa    ,u+
        rts


        endsection

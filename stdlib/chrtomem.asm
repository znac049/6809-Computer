        section code

chrtomem        export

* Writes register A at the address given by chrtomem_writer,
* which gets incremented by 1.
*
chrtomem:
        pshs    x
        ldx     chrtomem_writer,pcr
        sta     ,x+
        stx     chrtomem_writer,pcr
        puls    x,pc

        endsection

        section bss

chrtomem_writer export

chrtomem_writer rmb     2       used by chrtomem

        endsection

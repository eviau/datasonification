<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

        instr 1
a1      oscil   10000, p4, 1
        out     a1
        endin

</CsInstruments>  
<CsScore>

;f-table
f1  0   4096    10 1

;ins    start    dur    freq
i1   0   4   245
i1   4   4   246
i1   8   4   289
i1   12   4   510
i1   16   4   103
i1   20   4   349
i1   24   4   452
i1   28   4   312
i1   32   4   290
i1   36   4   299


</CsScore>
</CsoundSynthesizer>


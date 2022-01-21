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
i1      0        4      220
i1      4        4      360
i1      8        4      440

</CsScore>
</CsoundSynthesizer>


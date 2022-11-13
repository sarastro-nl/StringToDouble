.hexDigits:         defb "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"
.hexDigitsString:   defb "0x ", 0

; RAM details
RAM4Dend:     equ   RAM4Dstart

printDoubleHex:
              ld    hl, .hexDigitsString
              call  .printString
              ld    hl, dac
              ld    b, 8
.printLoop:
              ld    c, (hl)
              push  hl
              ld    a, c
              srl   a
              srl   a
              srl   a
              srl   a
              ld    hl, .hexDigits
              ld    d, 0
              ld    e, a
              add   hl, de
              ld    a, (hl)
              call  chput
              ld    a, c
              and   &h0f
              ld    hl, .hexDigits
              ld    e, a
              add   hl, de
              ld    a, (hl)
              call  chput
              ld    a, " "
              call  chput
              pop   hl
              inc   hl
              djnz  .printLoop
              ld    hl, .newLine
              jp    .printString

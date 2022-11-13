;.rShiftString:      defb "shifting right: ", 0
RAM4Fend:     equ   RAM4Fstart

rightShift:
; ld    hl, .rShiftString
; call  .printString
; ld    a, (.shift)
; call  printU8bit

              ld    hl, dac
              call  makeZero

              ld    hl, 0
              ld    (.ir), hl
              ld    (.iw), hl
.rightShiftLoop1:
              call  .shiftDigit
              ld    a, c
              or    a
              jr    z, .rightShiftLoop1

              ld    hl, (.dp)
              ld    de, (.ir)
              dec   de
              or    a               ; reset carry
              sbc   hl, de
              ld    (.dp), hl

.rightShiftLoop2:
              ld    hl, .digits
              ld    de, (.iw)
              add   hl, de
              ld    (hl), c
              inc   de
              ld    (.iw), de

              ld    hl, dac
              call  compareUInt64ToZero
              jr    z, .finish

              call  .shiftDigit

              jr    .rightShiftLoop2
.finish:
              ld    de, (.iw)
              ld    (.nrDigits), de

; call  debugDouble

              ret

.shiftDigit:
              call  times10UInt64
              call  .readNextDigit
              call  UInt64WithU8bitArg
              call  addUInt64

              ld    a, (.shift)
              ld    hl, dac + 7
              ld    b, 0
              ld    c, a
              srl   c
              srl   c
              srl   c
              or    a
              sbc   hl, bc
              and   &h07
              push  hl
              ld    hl, .bits
              ld    c, a
              add   hl, bc
              ld    d, (hl)
              pop   hl

              ld    bc, &h0400
              ld    e, 1
.bitLoop:     ld    a, d
              and   (hl)
              jr    z, .continue
              cpl
              and   (hl)
              ld    (hl), a
              ld    a, c
              add   e
              ld    c, a
.continue:    ld    a, d
              add   a, a
              ld    d, a
              jr    nc, .skipDecHL
              dec   hl
              ld    d, 1
.skipDecHL:   ld    a, e
              add   a, a
              ld    e, a
              djnz  .bitLoop

              ret

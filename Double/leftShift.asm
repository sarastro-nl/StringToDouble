.extraDigits:       defb 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4
                    defb 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 7, 8, 8
                    defb 8, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11
                    defb 12, 12, 12, 13, 13, 13, 13, 14, 14, 14
                    defb 15, 15, 15, 16, 16, 16, 16, 17, 17, 17
                    defb 18, 18, 18, 19
;.lShiftString:      defb "shifting left: ", 0

; RAM details
.ed:          equ   RAM4Estart      ; 1 byte
RAM4Eend:     equ   .ed + 1

leftShift:
; ld    hl, .lShiftString
; call  .printString
; ld    a, (.shift)
; call  printU8bit

              ld    hl, dac
              call  makeZero

              ld    hl, .extraDigits
              ld    a, (.shift)
              ld    d, 0
              ld    e, a
              add   hl, de
              ld    a, (hl)
              ld    (.ed), a
              ld    hl, (.nrDigits)
              dec   hl
              ld    (.ir), hl
              ld    e, a
              add   hl, de
              ld    (.iw), hl

.leftShiftLoop1:
              ld    hl, arg
              call  makeZero
              call  .shiftDigit
              call  addUInt64
              call  divideBy10UInt64 ; dac = dac / 10
              call  .writeDigit

              ld    hl, (.ir)
              ld    a, h
              and   &H80
              jr    z, .leftShiftLoop1

.leftShiftLoop2:

              ld    hl, dac
              call  compareUInt64ToZero
              jr    z, .finish

              call  divideBy10UInt64 ; dac = dac / 10
              call  .writeDigit

              jr    .leftShiftLoop2

.finish:
              ld    hl, (.iw)
              ld    a, (.ed)
              ld    d, 0
              ld    e, a
              ld    a, h
              or    l
              push  af              ; store flag
              jr    nz, .addExtraDigits
              dec   de
.addExtraDigits:
              ld    hl, (.dp)
              add   hl, de
              ld    (.dp), hl
              ld    hl, (.nrDigits)
              add   hl, de
              ld    (.nrDigits), hl
              pop   af
              jr    nz, .trimZero
              ld    b, h
              ld    c, l
              ld    hl, .digits + 1
              ld    de, .digits
              ldir
.trimZero:
              ld    hl, .digits
              ld    de, (.nrDigits)
              add   hl, de
              xor   a
.trimZeroLoop:
              dec   hl
              dec   de
              or    (hl)
              jr    z, .trimZeroLoop
              inc   de
              ld    (.nrDigits), de

; call  debugDouble

              ret

.writeDigit:
              ld    a, (modulo10)
              ld    hl, .digits
              ld    de, (.iw)
              add   hl, de
              ld    (hl), a
              dec   de
              ld    (.iw), de
              ret

.shiftDigit:
              ld    hl, (.nrDigits)
              dec   hl
              ld    de, (.ir)
              or    a
              sbc   hl, de
              ret   c
              ld    hl, .digits
              add   hl, de
              ld    a, (hl)
              dec   de
              ld    (.ir), de
              or    a
              ret   z

              ld    d, a
              ld    a, (.shift)
              ld    hl, arg + 7
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
              ld    a, (hl)
              pop   hl

              ld    b, 4
.bitLoop:     srl   d
              jr    nc, .continue
              or    (hl)
              ld    (hl), a
.continue:    add   a, a
              jr    nc, .skipDecHL
              dec   hl
              ld    a, 1
.skipDecHL:   djnz  .bitLoop

              ret

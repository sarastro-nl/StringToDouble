.powers:            defb 0, 3, 6, 9, 13, 16, 19, 23, 26, 29, 33, 36, 39, 43, 46, 49, 53, 56, 59
.bits:              defb 1, 2, 4, 8, 16, 32, 64, 128

; RAM details
.dp:          equ   RAM4start       ; 2 bytes
.nrDigits:    equ   .dp + 2         ; 2 bytes
.digits:      equ   .nrDigits + 2   ; 300 bytes, this should be enough for 1e-100 < x < 1e+100
.flags:       equ   .digits + 300   ; 1 byte
.exp:         equ   .flags + 1      ; 2 bytes
.ir:          equ   .exp + 2        ; 2 bytes
.iw:          equ   .ir + 2         ; 2 bytes
.shift:       equ   .iw + 2         ; 1 byte
RAM4Astart:   equ   .shift + 1
include "Double/parseDouble.asm"
RAM4Bstart:   equ   RAM4Aend
include "Double/debugDouble.asm"
RAM4Cstart:   equ   RAM4Bend
include "Double/printDouble.asm"
RAM4Dstart:   equ   RAM4Cend
include "Double/printDoubleHex.asm"
RAM4Estart:   equ   RAM4Dend
include "Double/leftShift.asm"
RAM4Fstart:   equ   RAM4Eend
include "Double/rightShift.asm"
RAM4end:      equ   RAM4Fend

initDouble:
              ld    hl, 1023
              ld    (.exp), hl

; call  debugDouble

              ld    hl, (.dp)
              ld    a, h
              and   &h80
              jr    nz, .loopNegative

.loopPositive:
              ld    hl, (.dp)
              ld    de, 2
              or    a
              sbc   hl, de
              jr    c, .zeroOrOne
              ld    de, 17
              sbc   hl, de          ; nc
              ld    a, 60
              jr    nc, .maxRightShift
              ld    hl, .powers
              ld    de, (.dp)
              add   hl, de
              ld    a, (hl)
.maxRightShift:
              ld    (.shift), a
              ld    hl, (.exp)
              ld    d, 0
              ld    e, a
              add   hl, de
              ld    (.exp), hl

              call  rightShift

              jr    .loopPositive

.loopNegative:
              ld    hl, -18
              ld    de, (.dp)
              or    a
              sbc   hl, de
              ld    a, 60
              jr    nc, .maxLeftShift
              ld    hl, .powers
              ld    de, (.dp)
              or    a
              sbc   hl, de
              ld    a, (hl)
              inc   a
.maxLeftShift:
              ld    (.shift), a
              ld    hl, (.exp)
              ld    d, 0
              ld    e, a
              or    a
              sbc   hl, de
              ld    (.exp), hl

              call  leftShift

              ld    hl, (.dp)
              ld    a, h
              and   &h80
              jr    nz, .loopNegative

.zeroOrOne:
              ld    b, 3
              ld    hl, 0
              ld    (.ir), hl
.first3DigitsLoop:
              add   hl, hl
              ld    d, h
              ld    e, l
              add   hl, hl
              add   hl, hl
              add   hl, de
              push  hl
              call  .readNextDigit
              pop   hl
              ld    d, 0
              ld    e, a
              add   hl, de
              djnz  .first3DigitsLoop

              ld    a, (.dp)
              ld    bc, 0
              or    a               ; nc
              jr    nz, .dpOne
.dpZero:
              ld    c, 4
              ld    de, 125
              sbc   hl, de          ; nc
              jr    c, .addShift
              ld    c, 3
              sbc   hl, de          ; nc
              jr    c, .addShift
              ld    c, 2
              ld    de, 250
              sbc   hl, de          ; nc
              jr    c, .addShift
              ld    c, 1
              jr    .addShift
.dpOne:
              ld    de, 200
              sbc   hl, de          ; nc
              jr    c, .addShift
              ld    bc, -1          ; b = &hff
              sbc   hl, de          ; nc
              jr    c, .addShift
              ld    c, -2
              ld    de, 400
              sbc   hl, de          ; nc
              jr    c, .addShift
              ld    c, -3
.addShift:
              ld    hl, (.exp)
              or    a
              sbc   hl, bc
              ld    (.exp), hl
              ld    a, c
              add   52
              ld    (.shift), a
              call  leftShift

              ld    hl, dac
              call  makeZero
              ld    b, 16
              ld    hl, 0
              ld    (.ir), hl
.mantisseLoop:
              push  bc
              call  times10UInt64
              call  .readNextDigit
              call  UInt64WithU8bitArg
              call  addUInt64
              pop   bc
              djnz  .mantisseLoop
              call  .readNextDigit
              cp    5
              jr    c, .noRounding
              ld    a, 1
              call  UInt64WithU8bitArg
              call  addUInt64
.noRounding:  ld    hl, dac
              ld    de, (.exp)
              ld    (hl), e
              ld    a, d
              rrd
              dec   a               ; to compensate for the 1.
              sla   a
              sla   a
              sla   a
              sla   a
              inc   hl
              add   a, (hl)
              ld    (hl), a
              dec   hl
              ld    a, (.flags)
              and   &h80
              add   a, (hl)
              ld    (hl), a
              ret

.readNextDigit:
              ld    hl, (.nrDigits)
              dec   hl
              ld    de, (.ir)
              xor   a               ; reset carry, a = 0
              sbc   hl, de
              jr    c, .endOfDigits
              ld    hl, .digits
              add   hl, de
              ld    a, (hl)
.endOfDigits:
              inc   de
              ld    (.ir), de
              ret

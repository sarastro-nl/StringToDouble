.zero:              defs 8
.eightTenth:        defb 204, 204, 204, 204, 204, 204, 204, 205

; RAM details
.hold1:       equ   RAM3start       ; 8 bytes
.hold2:       equ   .hold1 + 8      ; 8 bytes
.hold3:       equ   .hold2 + 8      ; 8 bytes
.multHold1:   equ   .hold3 + 8      ; 16 bytes
.multHold2:   equ   .multHold1 + 16 ; 16 bytes
.significant: equ   .multHold2 + 16 ; 1 byte
modulo10:     equ   .significant + 1; 1 byte
RAM3Astart:   equ   modulo10 + 1
include "UInt64/printUInt64.asm"
RAM3end:      equ   RAM3Aend

addUInt64:                          ; hl = hl + de
              ld    hl, dac
              ld    de, arg
.addUInt64Alt:
              ld    bc, 8
              add   hl, bc
              ex    de, hl
              add   hl, bc
              ld    b, 8
              or    a               ; clear carry
.addLoop:     dec   hl
              dec   de
              ld    a, (de)
              adc   a, (hl)
              ld    (de), a
              djnz  .addLoop
              ret

subUInt64:                          ; hl = hl - de
              ld    bc, 8
              add   hl, bc
              ex    de, hl
              add   hl, bc
              ld    b, 8
              or    a               ; clear carry
.subLoop:
              dec   hl
              dec   de
              ld    a, (de)
              sbc   a, (hl)
              ld    (de), a
              djnz  .subLoop
              ret

;       Inputs          c = number of significant bytes
;       Outputs         dac = dac * arg
;       Uses            .hold1, .multHold1, .multHold2

multiplyUInt64:
              ld    hl, dac
              call  compareUInt64ToZero   ; leaves c intact
              ret   z

              ld    hl, arg
              call  compareUInt64ToZero
              jr    nz, .bothNonZero
              ld    hl, dac
              jp    makeZero
.bothNonZero:
              ld    hl, .significant
              ld    (hl), c

              ld    hl, .multHold1
              call  makeZero        ; sets first 8 bytes to zero

              ld    b, 16
              ld    hl, .multHold2
              call  .makeZeroAlt

              ld    de, dac
              ld    hl, arg
              call  compareUInt64
              ld    de, dac
              ld    hl, arg
              jr    nc, .multiplyInit
              ex    de, hl
.multiplyInit:
              push  de
              ld    bc, 8
              ld    de, .hold1      ; hold1 = hl = lowest(dac, arg)
              ldir

              pop   hl
              ld    bc, 8
              ld    de, .multHold1 + 8   ; sets last 8 bytes with hl = highest(dac, arg)
              ldir

.multiplyLoop:
              ld    hl, .hold1
              call  divideBy2
              jr    nc, .zeroCheck

              ld    hl, .multHold2 + 16
              ld    de, .multHold1 + 16
              ld    b, 16
              or    a               ; clear carry
.multiplyAddLoop:
              dec   hl
              dec   de
              ld    a, (de)
              adc   a, (hl)
              ld    (hl), a
              djnz  .multiplyAddLoop
.zeroCheck:
              ld    hl, .hold1
              call  compareUInt64ToZero
              jr    z, .multiplyDone

              ld    hl, .multHold1 + 16
              ld    b, 16
              or    a               ; clear carry
.times2Loop:
              dec   hl
              rl    (hl)
              djnz  .times2Loop
              jr    .multiplyLoop
.multiplyDone:
              ld    hl, .significant
              ld    a, 8
              sub   (hl)
              ld    hl, .multHold2
              ld    d, 0
              ld    e, a
              add   hl, de
              ld    de, dac
              ld    bc, 8
              ldir
              ret

times10UInt64:
              ld    hl, dac
              call  compareUInt64ToZero
              ret   z

              call  .copyDacToArg
              call  addUInt64       ; dac = 2 * dac

              ld    bc, 8
              ld    hl, dac
              ld    de, .hold1
              ldir                  ; copy 2 * dac to .hold1

              call  .copyDacToArg
              call  addUInt64       ; dac = 4 * dac
              call  .copyDacToArg
              call  addUInt64       ; dac = 8 * dac

              ld    hl, dac
              ld    de, .hold1
              call  .addUInt64Alt   ; dac = 8 * dac + 2 * dac
              ret

.copyDacToArg:
              ld    bc, 8
              ld    hl, dac
              ld    de, arg
              ldir                  ; arg = dac
              ret

divideBy10UInt64:                   ; dac = dac / 10
              xor   a
              ld    (modulo10), a

              ld    hl, dac
              call  compareUInt64ToZero
              ret   z

              ld    bc, 8
              ld    hl, dac
              ld    de, .hold2      ; hold2 = dac (=n)
              ldir

              ld    bc, 8
              ld    hl, .eightTenth
              ld    de, arg
              ldir

              ld    c, 8
              call  multiplyUInt64  ; dac = dac * 8/10 (=n*8/10)
              ld    hl, dac
              call  divideBy2
              ld    hl, dac
              call  divideBy2
              ld    hl, dac
              call  divideBy2      ; dac = dac / 8 (=n/10)

              ld    bc, 8
              ld    hl, dac
              ld    de, .hold3
              ldir                  ; hold3 = dac (=q=n/10)

              call  times10UInt64   ; dac = dac * 10 (=10*q=n)

              ld    bc, 8
              ld    hl, .hold2
              ld    de, arg         ; arg = hold2 (=n)
              ldir

              ld    hl, arg
              ld    de, dac
              call  subUInt64       ; arg = arg - dac (=n-10*q)

              ld    bc, 8
              ld    hl, .hold3
              ld    de, dac
              ldir                  ; hold3 = dac (=q)

              ld    hl, arg + 7
              ld    a, (hl)
              ld    (modulo10), a
              sub   10
              ret   c

              ld    (modulo10), a

              ld    a, 1
              call  UInt64WithU8bitArg
              jp    addUInt64

divideBy2:
              ld    b, 8
              xor   a               ; reset carry
.divide2Loop:
              rr    (hl)
              inc   hl
              djnz  .divide2Loop
              ret

;       Inputs          hl, de
;       Outputs         z: de == hl, nc: de >= hl, c: de < hl
;       Uses
compareUInt64:
              ld    b, 8
.compareLoop:
              ld    a, (de)
              sub   (hl)
              ret   nz
              inc   hl
              inc   de
              djnz  .compareLoop
              ret

makeZero:
              ld    b, 8
.makeZeroAlt: xor   a
.makeZeroLoop:ld    (hl), a
              inc   hl
              djnz  .makeZeroLoop
              ret

UInt64WithU8bitArg:
              ld    hl, arg
              ld    c, a
              ld    b, 7
              call  .makeZeroAlt
              ld    (hl), c
              ret

compareUInt64ToZero:
              ld    de, .zero
              jr    compareUInt64

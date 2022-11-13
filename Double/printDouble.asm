.half:              defb &h45, &h63, &h91, &h82, &h44, &hf4, &h00, &h00 ; 5*10^18
.powersOf10:        defb &h0d, &he0, &hb6, &hb3, &ha7, &h64, &h00, &h00 ; 10^18
                    defb &h01, &h63, &h45, &h78, &h5d, &h8a, &h00, &h00 ; 10^17
                    defb &h00, &h23, &h86, &hf2, &h6f, &hc1, &h00, &h00 ; 10^16
                    defb &h00, &h03, &h8d, &h7e, &ha4, &hc6, &h80, &h00 ; 10^15
                    defb &h00, &h00, &h5a, &hf3, &h10, &h7a, &h40, &h00 ; 10^14
                    defb &h00, &h00, &h09, &h18, &h4e, &h72, &ha0, &h00 ; 10^13
                    defb &h00, &h00, &h00, &he8, &hd4, &ha5, &h10, &h00 ; 10^12
                    defb &h00, &h00, &h00, &h17, &h48, &h76, &he8, &h00 ; 10^11
                    defb &h00, &h00, &h00, &h02, &h54, &h0b, &he4, &h00 ; 10^10
                    defb &h00, &h00, &h00, &h00, &h3b, &h9a, &hca, &h00 ; 10^9
                    defb &h00, &h00, &h00, &h00, &h05, &hf5, &he1, &h00 ; 10^8
                    defb &h00, &h00, &h00, &h00, &h00, &h98, &h96, &h80 ; 10^7
                    defb &h00, &h00, &h00, &h00, &h00, &h0f, &h42, &h40 ; 10^6
                    defb &h00, &h00, &h00, &h00, &h00, &h01, &h86, &ha0 ; 10^5
                    defb &h00, &h00, &h00, &h00, &h00, &h00, &h27, &h10 ; 10^4
                    defb &h00, &h00, &h00, &h00, &h00, &h00, &h03, &he8 ; 10^3
.exponentString:    defb "*2^", 0

; RAM details
.hold:        equ   RAM4Cstart      ; 8 bytes
.exponent:    equ   .hold + 8       ; 2 bytes
RAM4Cend:     equ   .exponent + 2

printDouble:
              ld    hl, (dac)
              ld    a, l
              or    h
              jr    nz, .notZero
              ld    a, "0"
              jp    chput
.notZero:
              ld    (.exponent), hl

              ld    a, (dac)
              and   &h80
              jr    z, .print
              ld    a, "-"
              call  chput
.print:
              ld    a, "1"
              call  chput
              ld    a, "."
              call  chput

              ld    bc, 7
              ld    hl, dac + 1
              ld    de, .hold
              ldir                  ; hold1 = 7 bytes mantisse

              ld    hl, .hold + 7
              xor   a
              ld    (hl), a
              ld    b, 7
.times16Loop:
              dec   hl
              rld
              djnz  .times16Loop

              ld    hl, dac
              call  makeZero

              ld    bc, 8
              ld    hl, .half
              ld    de, arg
              ldir                  ; arg = 0.5
.addLoop:
              ld    hl, .hold
              call  compareUInt64ToZero
              jr    z, .addingDone

              ld    hl, .hold
              call  .times2
              jr    nc, .halfArg
              call  addUInt64
.halfArg:
              ld    hl, arg
              call  divideBy2
              jr    .addLoop

.addingDone:
              call  .printMantisse
              call  .printExponent

              ret

.times2:
              ld    bc, 7
              add   hl, bc
              ld    b, 7
              or    a               ; reset carry
.times2Loop:
              dec   hl
              rl    (hl)
              djnz  .times2Loop
              ret

.printMantisse:
              ld    b, 16
              ld    hl, .powersOf10
.nextDigit:
              ld    c, "0"            ; counter loop
.nextCompare: ld    de, dac
              push  hl
              push  bc
              call  compareUInt64
              pop   bc
              pop   hl
              jr    c, .printOut
              push  bc
              call  .subtract
              pop   bc
              inc   c
              jr    .nextCompare
.printOut:    ld    a, c
              call  chput           ; rst &h18
              ld    de, 8
              add   hl, de
              djnz  .nextDigit
              ret

.subtract:    ld    bc, 8
              add   hl, bc
              ld    de, dac + 8
              ld    b, 8
              or    a               ; reset carry
.subtractLoop:
              dec   hl
              dec   de
              ld    a, (de)
              sbc   a, (hl)
              ld    (de), a
              djnz  .subtractLoop
              ret

.printExponent:
              ld    hl, .exponentString
              call  .printString

              xor   a
              ld    hl, .exponent
              rrd
              inc   hl
              rrd

              ld    hl, (.exponent)
              ld    a, l
              and   &h07
              ld    l, h
              ld    h, a
              ld    de, 1023
              or    a
              sbc   hl, de
              jp    print16bit

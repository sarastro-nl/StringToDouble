.rShiftString:      defb "shifting right: ", 0
.setBitBlock: bit   0, (hl)
              ret   z               
              res   0, (hl)         
              set   0, c
              ret
.setBitBlockSize: equ $ - .setBitBlock  

; RAM details
.setBit:      equ   RAM4Fstart      ; .setBitBlockSize bytes
RAM4Fend:     equ   .setBit + .setBitBlockSize

rightShift:         
 ld    hl, .rShiftString
 call  .printString
 ld    a, (.shift)
 call  printU8bit
                    
              ld    hl, dac         
              call  makeZero

              ld    bc, .setBitBlockSize
              ld    hl, .setBitBlock
              ld    de, .setBit
              ldir                  ; copy self changing code to ram

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
                    
 call  debugDouble

              ret   

.shiftDigit:
              call  times10UInt64
              call  .readNextDigit  
              call  UInt64WithU8bitArg
              call  addUInt64

              ld    a, (.shift)
              ld    c, a

              and   &h07
              ld    d, a
              sla   d
              sla   d
              sla   d

              ld    hl, dac + 7
              ld    b, 0
              srl   c
              srl   c
              srl   c
              or    a               
              sbc   hl, bc
                    
              ld    bc, &h0400
              ld    e, 0            
.bitLoop:
              ld    a, &b01000110   ; bit 0, (hl)
              add   d
              ld    (.setBit + 1), a
              add   64              ; res 0, (hl)
              ld    (.setBit + 4), a
              ld    a, e
              add   &b11000001      ; set 0, c
              ld    (.setBit + 6), a

              call  .setBit

              ld    a, d
              add   8
              and   &b00111000
              ld    d, a
              jr    nz, .skipDecHL
              dec   hl
.skipDecHL:   ld    a, e
              add   8
              ld    e, a            
              djnz  .bitLoop        

              ret

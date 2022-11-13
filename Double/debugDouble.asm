.digitsString:      defb "digits: ", 0
.nrDigitsString:    defb "nrDigits: ", 0
.dpString:          defb "dp: ", 0
.flagsString:       defb "flags: ", 0
.expString:         defb "exp: ", 0

; RAM details
RAM4Bend:     equ   RAM4Bstart

debugDouble:
              ld    hl, .digitsString
              call  .printString
              ld    hl, .digits
              ld    bc, (.nrDigits)
              ld    a, c            
              or    b
              jr    nz, .digitLoop
              xor   a               
              ld    (.digits), a
              ld    bc, 1
.digitLoop:
              ld    a, (hl)
              add   &h30
              call  chput
              inc   hl
              dec   bc
              ld    a, c
              or    b               
              jr    nz,  .digitLoop  

              ld    a, "\r"
              call  chput
              ld    a, "\n"
              call  chput

              ld    hl, .nrDigitsString
              call  .printString
              ld    hl, (.nrDigits)
              call  print16bit

              ld    hl, .dpString
              call  .printString
              ld    hl, (.dp)
              call  print16bit

;              ld    hl, .flagsString
;              call  .printString
;              ld    a, (.flags)
;              call  printU8bit

              ld    hl, .expString
              call  .printString
              ld    hl, (.exp)
              call  print16bit

              ret

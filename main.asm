chput:        equ   &ha2

	          org   &h4000
ROMheader:          defb    "AB"
                    defw    execute
                    defw    0, 0, 0, 0, 0, 0

.newLine:           defb 13, 10, 0
.doneString:        defb "done", 13, 10, 0

;.doubleString:       defb "+0.12343e-4", 0
;.doubleString:       defb "-009.123456e-111", 0
;.doubleString:       defb "0.124999", 0
;.doubleString:       defb "2.99792458e8", 0
;.doubleString:       defb "0.12343e-24", 0
.doubleString:       defb "6.62607015e-34", 0
;.doubleString:       defb ".7450580596923828125", 0
;.doubleString:       defb "19.9345", 0
;.doubleString:      defb "2.2299999999e-308", 0
                    
; RAM details
RAM1start:    equ   &hc000
include "U8bit/printU8bit.asm"    ; 0
RAM2start:    equ   RAM1end
include "16bit/print16bit.asm"
RAM3start:    equ   RAM2end
include "UInt64/UInt64.asm"
RAM4start:    equ   RAM3end
include "Double/Double.asm"
dac:          equ   RAM4end         ; 8 bytes
arg:          equ   dac + 8         ; 8 bytes

execute:
              ld    hl, .doubleString
              call  .printString
              ld    hl, .newLine
              call  .printString

              ld    hl, .doubleString
              call  parseDoubleString
              call  initDouble
              call  printDoubleHex
              call  printDouble

              ld    hl, .doneString
              call  .printString

.done:        jr    .done

.printString:
              ld    a, (hl)
              or    a
              ret   z
              call  chput
              inc   hl
              jr    .printString

.filler:	          defs    &h4000 - ($ - ROMheader)

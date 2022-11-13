chput:        equ   &ha2

                    defb &hfe	    ; Binary file ID
                    defw begin	    ; begin address
                    defw end - 1	; end address
                    defw execute	; program execution address (for ,R option)

              org   &hc000

begin:

include "U8bit/printU8bit.asm"
include "16bit/print16bit.asm"
include "UInt64/UInt64.asm"
include "UInt64/printUInt64.asm"
include "Double/Double.asm"

;dac:                defb &hBF, &hE9, &h99, &h99, &h99, &h99, &h99, &h9A ; -0.8
;dac:                defb &h3F, &hF0, &h28, &h74, &h42, &hC7, &hFB, &hAD ; 1.0098765
;dac:                defb &h3F, &hFF, &hCD, &h6A, &h16, &h1E, &h4F, &h76 ; 1.98765
;dac:                defb &h3F, &hF1, &hF9, &h72, &h47, &h45, &h38, &hEF ; 1.1234
;dac:                defb &h40, &h8F, &hFB, &h67, &h25, &hA3, &h78, &h77 ; 1023.4253647586
dac:                defb &h3D, &h50, &h7F, &h50, &h48, &h27, &h11, &h7D ; 2.34441*10^-13
;dac:                defb &hFF, &hFF, &hFF, &hFF, &hFF, &hFF, &hFF, &hFF
;dac:                defb 255, 255, 255, 255, 255, 255, 255, 251
arg:                defb 0, 0, 0, 0, 0, 0, 0, 30

.doubleInput:       defb "+0.12343e-4", 0
;.doubleInput:       defb "-009.123456e-111", 0
;.doubleInput:       defb "0.124999", 0
;.doubleInput:       defb "299792458e15", 0
;.doubleInput:       defb "299792458", 0
;.doubleInput:       defb "0.12343e-24", 0
;.doubleInput:       defb "6.62607015e-34", 0
;.doubleInput:       defb ".7450580596923828125", 0
;.doubleInput:       defb "8.345", 0
                    
execute:
              ld    hl, .doubleInput
              call  parseDouble

              call  initDouble
;              call  printDouble
              call  printDoubleHex     
              ret   

end:                end

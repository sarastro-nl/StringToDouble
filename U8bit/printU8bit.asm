.decimals:          defb 100
                    defb 10
                    
; RAM details
RAM1end:      equ   RAM1start       
                    
printU8bit:
              push  af
              push  bc
              push  de              
              push  hl
              or    a
              jr    z, .end
.nonZero:     ld    b, 2
              ld    hl, .decimals
              ld    e, "0"          ; counter
.loop:        dec   e
              ld    c, (hl)
.subtract:    inc   e
              sub   c
              jr    nc, .subtract
              add   c               ; restore a
              ld    c, a            ; keep rest
              ld    a, e
              cp    "0"
              jr    z, .skipZero
              and   &h7f            
              call  chput      
              ld    e, &h80 + "0"
.skipZero:    ld    a, c            ; restore rest
              inc   hl
              djnz  .loop
.end:         add   "0"             
              call  chput           
              ld    a, "\r"
              call  chput
              ld    a, "\n"
              call  chput
              pop   hl
              pop   de
              pop   bc
              pop   af
              ret                   

.decimals:          defw 10000
                    defw 1000
                    defw 100
                    defw 10
.digits:            defs 5
                    
print16bit:
              push  af
              push  bc
              push  de
              push  hl              
              ld    a, l            
              or    h
              jr    nz, .nonZero
              ld    a, "0"
              call  chput                    
              jr    .end
.nonZero:
              ld    a, h
              and   &h80
              jr    z, .positive
              xor   a               
              ld    de, 0
              ex    de, hl
              sbc   hl, de
              ld    a, "-"
              call  chput           
.positive:
              ld    a, 4
              ld    bc, .digits
              ld    de, .decimals

.nextDigit:   push  bc
              ex    de, hl
              ld    c, (hl)
              inc   hl
              ld    b, (hl)
              inc   hl
              push  bc
              ex    (sp), hl
              ex    de, hl
              ld    c, "0" - 1
              or    a               
.subtract:    inc   c
              sbc   hl, de
              jr    nc, .subtract
              add   hl, de
              pop   de
              ex    (sp), hl        
              ld    (hl), c
              inc   hl
              ex    (sp), hl
              pop   bc
              dec   a
              jr    nz, .nextDigit
              ld    a, l
              add   "0"             
              ld    (bc), a

.print:       ld    b, 6
              ld    hl, .digits
.skipZero:    dec   b               
              ld    a, (hl)
              inc   hl              
              cp    "0"             
              jr    z, .skipZero
.printLoop:   call  chput
              ld    a, (hl)
              inc   hl
              djnz  .printLoop
.end:
              ld    a, "\r"
              call  chput
              ld    a, "\n"
              call  chput
              pop   hl              
              pop   de
              pop   bc
              pop   af
              ret                   

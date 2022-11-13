.powersOf10:        defb &h8a, &hc7, &h23, &h04, &h89, &he8, &h00, &h00 ; 10^19
                    defb &h0d, &he0, &hb6, &hb3, &ha7, &h64, &h00, &h00 ; 10^18
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
                    defb &h00, &h00, &h00, &h00, &h00, &h00, &h00, &h64 ; 10^2
                    defb &h00, &h00, &h00, &h00, &h00, &h00, &h00, &h0a ; 10^1
; RAM details
.hold:        equ   RAM3Astart      ; 8 bytes
RAM3Aend:     equ   .hold + 8                                    

printUInt64:
              ld    hl, dac
              call  compareUInt64ToZero
              jr    z, .end
                    
              ld    bc, 8
              ld    hl, dac
              ld    de, .hold
              ldir                  ; copy dac to hold

              ld    b, 19
              ld    c, "0"          ; counter loop
              ld    hl, .powersOf10
.nextDigit:   
              push  bc
              push  hl
              ld    de, .hold       
              call  compareUInt64
              pop   hl
              jr    c, .printDigit
              push  hl              
              ld    de, .hold
              ex    de, hl
              call  subUInt64
              pop   hl              
              pop   bc
              inc   c
              jr    .nextDigit
.printDigit:  pop   bc
              ld    a, c
              cp    "0"
              jr    z, .skipZero
              and   &h7f
              call  chput
              ld    c, &h80 + "0"
.skipZero:    ld    de, 8
              add   hl, de
              djnz  .nextDigit
.end:         ld    hl, .hold + 7
              ld    a, (hl)
              add   "0"             
              call  chput
              ld    a, "\r"
              call  chput
              ld    a, "\n"
              jp    chput           

.error:             defb "Parse error", 13, 10, 0

; RAM details
RAM4Aend:     equ   RAM4Astart

parseDouble:
              ld    bc, 0
              ld    de, 0
              ld    (.dp), de
              ld    (.nrDigits), de
              xor   a
              ld    (.flags), a
              ld    de, .digits
              call  .loadNextCharacter
              cp    "+"
              jr    z, .skipZero
              cp    "-"
              jr    nz, .skipZeroAlt
              ld    a, &h80
              ld    (.flags), a
.skipZero:
              call  .loadNextCharacter
.skipZeroAlt:
              cp    "0"
              jr    z, .skipZero
.integer:
              cp    "0"
              jr    c, .point
              cp    "9" + 1
              jr    nc, .exponent
              sub   "0"
              ld    (de), a
              inc   de
              inc   bc
              call  .loadNextCharacter
              jr    .integer
.point:
              cp    "."
              jp    nz, .printError
              ld    a, c
              or    b
              jr    nz, .fraction
.skipZeroFraction:
              call  .loadNextCharacter
              cp    "0"
              jr    nz, .fractionAlt
              dec   bc
              jr    .skipZeroFraction
.fraction:
              call  .loadNextCharacter
.fractionAlt:
              cp    "0"
              jp    c, .printError
              cp    "9" + 1
              jr    nc, .exponent
              sub   "0"
              ld    (de), a
              inc   de
              jr    .fraction
.exponent:
              push  af
              push  hl
              call  .storeData
              pop   hl
              pop   af
              cp    "e"
              jr    z, .parseSignExponent
              cp    "E"
              jp    nz, .printError
.parseSignExponent:
              ld    de, 0
              ld    a, (hl)
              inc   hl
              cp    "+"
              jr    z, .parseExponent
              cp    "-"
              jr    nz, .parseExponentAlt
              ld    a, (.flags)
              or    &h40
              ld    (.flags), a
.parseExponent:
              ld    a, (hl)
              inc   hl
.parseExponentAlt:
              or    a
              jr    z, .addExponent
              cp    "0"
              jr    c, .printError
              cp    "9" + 1
              jr    nc, .printError
              push  hl
              ld    l, e
              ld    h, d
              add   hl, hl
              ld    e, l
              ld    d, h
              add   hl, hl
              add   hl, hl
              add   hl, de
              sub   "0"
              ld    e, a
              ld    d, 0
              add   hl, de
              ex    de, hl
              pop   hl
              jr    .parseExponent
.addExponent:
              ld    h, b
              ld    l, c
              ld    a, (.flags)
              and   &h40
              jr    z, .addExponentPositive
              or    a
              sbc   hl, de
                    defb &hfe       ; cp xx, to skip the ’add’
.addExponentPositive:
              add   hl, de
              ld    (.dp), hl
              ret

.printError:  ld    hl, .error
              jp    .printString

.loadNextCharacter:
              ld    a, (hl)
              inc   hl
              or    a
              ret   nz
              pop   hl              ; remove the return address
.storeData:
              ld    (.dp), bc
              ld    hl, .digits
              ex    de, hl
              or    a               ; reset carry
              sbc   hl, de
              ld    (.nrDigits), hl
              ld    a, h
              or    l
              ret   z
              ex    de, hl
              ld    hl, .digits
              add   hl, de
.trimTrailingZero:
              dec   hl
              ld    a, (hl)
              or    a
              ret   nz
              dec   de
              ld    (.nrDigits), de
              jr    .trimTrailingZero

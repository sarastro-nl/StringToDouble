all: data.rom

clean:
	rm -f data.rom

data.rom: *.asm */*.asm
	../z80asm-1.8/z80asm main.asm -o data.rom

all: ${HOME}/dev/javascript/WebMSX/src/main/data.js

clean:
	rm -f data.bin ${HOME}/dev/javascript/WebMSX/src/main/data.js

${HOME}/dev/javascript/WebMSX/src/main/data.js: data.bin
	perl convert.pl data.bin ${HOME}/dev/javascript/WebMSX/src/main/data.js

data.bin: *.asm */*.asm
	../z80asm-1.8/z80asm main.asm -o data.bin

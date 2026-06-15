# Frontend to dune.

.PHONY: default build install uninstall test clean

default: build

build:
	dune build

test:
	./mel.sh --check Samples

clean:
	dune clean
	rm -f Samples/*.lir
	rm -f Samples/*.asm
	rm -f Samples/*.png
	rm -f Samples/*.s
	rm -f Samples/*.exe

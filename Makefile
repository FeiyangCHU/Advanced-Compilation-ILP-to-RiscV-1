.PHONY: all ilp_to_tree tree_to_risc riscv clean

# Default target
all: ilp_to_tree tree_to_risc

# Build ilp_to_tree
ilp_to_tree:
	$(MAKE) -C ilp_to_tree

# Build tree_to_risc
tree_to_risc:
	$(MAKE) -C tree_to_risc

test: all
	./jamel.sh --check Samples

# Clean both subdirectories
clean:
	$(MAKE) -C ilp_to_tree clean
	$(MAKE) -C tree_to_risc clean
	rm -f Samples/*.exe
	rm -f Samples/*.asm
	rm -f Samples/*.resolved
	rm -f Samples/*.png
	rm -f Samples/*.hir
	rm -f Samples/*.lir
	rm -f Samples/*.s

deploy: test
	cp Samples/*.ilpml ilp_to_tree/Samples/
	cp Samples/*.print ilp_to_tree/Samples/
	cp Samples/*.hir tree_to_risc/Samples/
	cp Samples/*.print tree_to_risc/Samples/
	$(MAKE) clean

# Generic Makefile: Make all the subdirectories

.PHONY: all clean distclean install fix
all install fix:
	for a in *; do [ -d "$$a" ] || continue; make -C "$$a" $@ || exit; done

clean distclean:
	for a in *; do [ -d "$$a" ] || continue; make -C "$$a" $@; done


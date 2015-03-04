#

CONTRIB=

.PHONY: all
all:

.PHONY: clean
clean:
	for a in $(CONTRIB); do make -C "$$a" clean; done

.PHONY: realclean
distclean:	clean
	for a in $(CONTRIB); do make -C "$$a" distclean; done

.PHONY: install
install:	all
	for a in $(CONTRIB); do make -C "$$a" install; done


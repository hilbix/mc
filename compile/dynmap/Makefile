#

SUBS=DynmapCoreApi DynmapCore dynmap-api dynmap

.PHONY: all
all:	dynmap/target/dynmap-*-SNAPSHOT.jar

dynmap/target/dynmap-*-SNAPSHOT.jar:
	for a in $(SUBS); do ( cd "$$a" && mvn install || exit; ); done

.PHONY: clean
clean:
	for a in $(SUBS); do ( cd "$$a" && mvn clean; ); done

.PHONY: distclean
distclean:	clean
	rm -rf jar


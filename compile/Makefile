#

SUBDIR=dynmap turmites

all:	worldedit dynmap turmites

.PHONY: dynmap
dynmap:
	make -C dynmap

.PHONY: turmites
turmites:
	make -C turmites

.PHONY: worldedit
worldedit:
	cd worldedit && { ./gradlew build || { echo '========= try to run: make fix'; exit 1; }; }

.PHONY: clean
clean:
	cd worldedit && ./gradlew clean
	for a in $(SUBDIR); do make -C '$$a' clean; done

.PHONY: distclean
distclean:	clean
	for a in $(SUBDIR); do make -C '$$a' distclean; done

.PHONY: fix
fix:
	cd worldedit && ./gradlew --refresh-dependencies


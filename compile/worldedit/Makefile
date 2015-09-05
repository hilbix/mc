#

TARGET=worldedit
SUBS=$(TARGET)
JARNAME=worldedit/worldedit-bukkit/build/libs/worldedit-bukkit-*-SNAPSHOT-dist.jar
INSTDIR=jar

.PHONY: all clean distclean install fix
all:	$(JARNAME)

$(JARNAME):
	for a in $(SUBS); do ( cd "$$a" && ./gradlew build || { echo '========= try to run: make fix'; exit 1; } ); done

clean:
	cd '$(TARGET)' && ./gradlew clean

distclean:	clean

install:	all
	cp -f $(JARNAME) '$(INSTDIR)/$(TARGET).tmp'
	mv -f '$(INSTDIR)/$(TARGET).tmp' '$(INSTDIR)/$(TARGET).jar'

fix:
	cd '$(TARGET)' && ./gradlew --refresh-dependencies


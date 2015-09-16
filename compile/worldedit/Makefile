#

TARGET=worldedit
SUBS=$(TARGET)
JARNAME=worldedit/worldedit-bukkit/build/libs/worldedit-bukkit-*-SNAPSHOT-dist.jar
INSTDIR=jar

.PHONY: all clean distclean install fix
all:	$(JARNAME)

$(JARNAME):
	-for a in $(SUBS); do [ ! -d "$$a/.gradle" ] && ( cd "$$a" && ./gradlew clean setupDevWorkspace ); done
	for a in $(SUBS); do ( cd "$$a" && ./gradlew build || { echo '========= try to run: make fix'; exit 1; } ) || exit; done

clean:
	-for a in $(SUBS); do ( cd "$$a" && ./gradlew clean; ); done

distclean:	clean
	-for a in $(SUBS); do ( cd "$$a" && git clean -xdf; ); done

install:	all
	cp -f $(JARNAME) '$(INSTDIR)/$(TARGET).tmp'
	mv -f '$(INSTDIR)/$(TARGET).tmp' '$(INSTDIR)/$(TARGET).jar'

fix:
	-for a in $(SUBS); do ( cd "$$a"; ./gradlew clean setupDevWorkspace; ./gradlew --refresh-dependencies; ); done


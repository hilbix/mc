#

TARGET=dynmap
SUBS=DynmapCoreApi DynmapCore dynmap-api $(TARGET)
JARNAME=$(TARGET)/target/dynmap-*-SNAPSHOT.jar
INSTDIR=jar

.PHONY: all clean distclean install fix
all:	$(JARNAME)

$(JARNAME):
	for a in $(SUBS); do ( cd "$$a" && mvn install || exit; ); done

clean:
	-for a in $(SUBS); do ( cd "$$a" && mvn clean; ); done

distclean:	clean
	-for a in $(SUBS); do ( cd "$$a" && git clean -xdf; ); done

install:	all
	cp -f $(JARNAME) '$(INSTDIR)/$(TARGET).tmp'
	mv -f '$(INSTDIR)/$(TARGET).tmp' '$(INSTDIR)/$(TARGET).jar'

fix:


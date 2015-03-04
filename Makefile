#

# CONFIG:
#
# CraftBukkit version
CBVER=1.8
#
# WorldEdit version
WEVER=*-SNAPSHOT
DMVER=*-SNAPSHOT
#
# When to run cronjob to start server (each minute)
CRON=* * * * *
#
# Where to install scripts
BINDIR=$(HOME)/bin
#
# Install directory (NOT YET IMPLEMENTED!)
INSDIR=$(HOME)/bukkit
#
# Target directory for "make doc"
DOCDIR=/var/www/html/doc
#
# CONFIG END

SOFTLINKS=autostart jar
TOOLS=src/nonblocking/nonblocking src/ptybuffer/ptybuffer src/ptybuffer/ptybufferconnect src/ptybuffer/script/autostart.sh
CLEANDIRS=src/nonblocking src/ptybuffer compile contrib
SUBS=jar/turmites.jar jar/worldedit.jar jar/dynmap.jar
CBJAR=craftbukkit-$(CBVER).jar
WORLDEDITJAR=worldedit-bukkit-$(WEVER)-dist.jar
DYNMAPJAR=dynmap-$(DMVER).jar
BUILD=tmpbuild
SPIGOTURL=https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/
SPIGOTJAR=BuildTools.jar

#
# all, update
#

.PHONY: all
all:	jar/$(CBJAR) $(TOOLS) $(SUBS)
	make -C contrib all

.PHONY: update
update:	compile

#
# Tools
#

src/nonblocking/nonblocking src/ptybuffer/ptybuffer src/ptybuffer/ptybufferconnect:
	make -C "`dirname '$@'`"

#
# JARs
#

jar/turmites.jar:	compile/turmites/turmites.jar
	rm -f '$@'
	cp -f '$<' '$@'

jar/worldedit.jar:	compile/worldedit/worldedit-bukkit/build/libs/$(WORLDEDITJAR)
	rm -f '$@'
	cp -f '$<' '$@'

jar/dynmap.jar:	compile/dynmap/dynmap/target/$(DYNMAPJAR)
	rm -f '$@'
	cp -f '$<' '$@'

compile/dynmap/dynmap/target/$(DYNMAPJAR):
	make -C compile dynmap

compile/turmites/turmites.jar:	jar/$(CBJAR)
	make -C compile turmites

compile/worldedit/worldedit-bukkit/build/libs/$(WORLDEDITJAR):
	make -C compile worldedit

jar/$(CBJAR) $(BUILD)/Bukkit:
	make compile

#
# COMPILE
#

.PHONY: compile
compile:	
	mkdir -p jar $(BUILD)
	cd $(BUILD) && wget -N $(SPIGOTURL)$(SPIGOTJAR) && java -jar $(SPIGOTJAR)
	rm -f 'jar/$(CBJAR)'
	cp -f '$(BUILD)/$(CBJAR)' jar/

.PHONY: fix
fix:
	for a in $(CLEANDIRS); do make -C "$$a" fix; done

#
# CLEAN
#

.PHONY: clean
clean:
	for a in $(CLEANDIRS); do make -C "$$a" clean; done
	rm -rf $(BUILD)

.PHONY: distclean
distclean:	clean
	# DOC is not cleaned
	echo "To wipe jar/ which you need this to run Bukkit, use: make fullclean"
	for a in $(CLEANDIRS); do make -C "$$a" distclean; done

# fullclean wipes the JARs which are needed by Bukkit to run
.PHONY: fullclean
fullclean:	distclean
	rm -rf jar

#
# MAIN
#

.PHONY: doc
doc:	$(BUILD)/Bukkit
	javadoc -encoding UTF-8 -d '$(DOCDIR)/bukkit' -sourcepath '$(BUILD)/Bukkit/src/main/java:$(BUILD)/Bukkit/src/main/javadoc' -subpackages org.bukkit
	sed -i -f misc/javadoc-quicksearch.sed '$(DOCDIR)/bukkit/index-all.html'

.PHONY: install
install:	all
	for a in $(SOFTLINKS); do rm -f "$$HOME/$$a" && ln -s "$(PWD)/$$a" "$$HOME/$$a"; done
	mkdir -p '$(BINDIR)'
	for a in $(TOOLS); do cp -f "$$a" '$(BINDIR)'; done
	for a in bin/*.sh; do b="`basename "$$a" .sh`" && rm -f "$(BINDIR)/$$b" && ln -s "$(PWD)/$$a" "$$HOME/bin/$$b"; done
	sbin/add-crontab.sh '$(CRON)' 'bin/autostart.sh >/dev/null' '### autostart bukkit'
	@echo
	@echo Creating a bukkit not yet implemented
	@echo
	make -C contrib install
	@exit 1


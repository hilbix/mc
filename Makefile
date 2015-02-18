#

# CONFIG:
#
# CraftBukkit version
CBVER=1.8
#
# WorldEdit version
WEVER=6.0.2-SNAPSHOT
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
CLEANDIRS=src/nonblocking src/ptybuffer compile/turmites
SUBS=jar/turmites.jar jar/worldedit.jar
CBJAR=craftbukkit-$(CBVER).jar
WORLDEDITJAR=worldedit-bukkit-$(WEVER)-dist.jar
BUILD=tmpbuild
SPIGOTURL=https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/
SPIGOTJAR=BuildTools.jar

.PHONY: all
all:	jar/$(CBJAR) $(TOOLS) $(SUBS)
	make -C contrib all

.PHONY: update
update:	compile

jar/$(CBJAR) $(BUILD)/Bukkit:
	make compile

# Tools

src/nonblocking/nonblocking:
	make -C "`dirname '$@'`"

src/ptybuffer/ptybuffer src/ptybuffer/ptybufferconnect src/ptybuffer/script/autostart.sh:
	make -C "`dirname '$@'`"

# JARs

jar/turmites.jar:	jar/$(CBJAR) compile/turmites/turmites.jar
	cp -f compile/turmites/turmites.jar jar/

jar/worldedit.jar:	compile/worldedit/worldedit-bukkit/build/libs/$(WORLDEDITJAR)
	cp -f compile/worldedit/worldedit-bukkit/build/libs/$(WORLDEDITJAR) jar/worldedit.jar

compile/turmites/turmites.jar:
	make -C compile/turmites

compile/worldedit/worldedit-bukkit/build/libs/$(WORLDEDITJAR):
	make -C compile worldedit

.PHONY: compile
compile:	
	mkdir -p jar $(BUILD)
	cd $(BUILD) && wget -N $(SPIGOTURL)$(SPIGOTJAR) && java -jar $(SPIGOTJAR)
	rm -f 'jar/$(CBJAR)'
	cp -f '$(BUILD)/$(CBJAR)' jar/

# Helpers

.PHONY: clean
clean:
	for a in $(CLEANDIRS); do make -C "$$a" distclean; done
	rm -rf $(BUILD)
	make -C contrib clean

.PHONY: realclean
realclean:	clean
	# DOC is not cleaned
	rm -rf jar
	make -C contrib realclean

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


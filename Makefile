#

SOFTLINKS=autostart jar
TOOLS=src/nonblocking/nonblocking src/ptybuffer/ptybuffer src/ptybuffer/ptybufferconnect src/ptybuffer/script/autostart.sh
CLEANDIRS=src/nonblocking src/ptybuffer compile/turmites
SUBS=jar/turmites.jar
JAR=craftbukkit-1.8.jar
BUILD=tmpbuild
SPIGOTURL=https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/
SPIGOTJAR=BuildTools.jar
BINDIR=$(HOME)/bin

CRON=* * * * *

.PHONY: all
all:	jar/$(JAR) $(TOOLS) $(SUBS)

.PHONY: update
update:	compile

jar/$(JAR):
	make compile

src/nonblocking/nonblocking:
	make -C "`dirname '$@'`"

src/ptybuffer/ptybuffer src/ptybuffer/ptybufferconnect src/ptybuffer/script/autostart.sh:
	make -C "`dirname '$@'`"

jar/turmites.jar:	jar/$(JAR) compile/turmites/turmites.jar
	cp -f compile/turmites/turmites.jar jar/

compile/turmites/turmites.jar:
	make -C compile/turmites

.PHONY: compile
compile:	
	mkdir -p jar $(BUILD)
	cd $(BUILD) && wget -N $(SPIGOTURL)$(SPIGOTJAR) && java -jar $(SPIGOTJAR)
	rm -f 'jar/$(JAR)'
	cp -f '$(BUILD)/$(JAR)' jar/

.PHONY: clean
clean:
	for a in $(CLEANDIRS); do make -C "$$a" distclean; done
	rm -rf $(BUILD)

.PHONY: realclean
realclean:	clean
	rm -rf jar

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
	@exit 1


#

SOFTLINKS=autostart jar
TOOLS=src/nonblocking/nonblocking src/ptybuffer/ptybuffer src/ptybuffer/ptybufferconnect src/ptybuffer/script/autostart.sh
CLEANDIRS=src/nonblocking src/ptybuffer
JAR=craftbukkit-1.8.jar
BUILD=tmpbuild
SPIGOTURL=https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/
SPIGOTJAR=BuildTools.jar
BINDIR=$(HOME)/bin

CRON=* * * * *

.PHONY: all
all:	jar/$(JAR) $(TOOLS)

.PHONY: update
update:	compile

src/nonblocking/nonblocking:
	make -C "`dirname '$@'`"

jar/$(JAR):
	make compile

.PHONY: compile
compile:	
	mkdir -p jar $(BUILD)
	cd $(BUILD) && wget -N $(SPIGOTURL)$(SPIGOTJAR) && java -jar $(SPIGOTJAR)
	rm -f 'jar/$(JAR)'
	cp -f '$(BUILD)/$(JAR)' jar/

.PHONY: clean
clean:
	for a in $(CLEANDIRS); do make -C "$$a" clean; done
	make -C src/ptybuffer clean
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


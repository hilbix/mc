#

# CONFIG:
#
# CraftBukkit version
JARNAM=spigot
JARVER=1.10.2
#
# When to run cronjob to start server (each minute)
CRON=* * * * *
#
# Where to install scripts
BINDIR=$(HOME)/bin
#
# Install directory
INSDIR=$(HOME)/bukkit
#
# Target directory for "make doc"
DOCDIR=/var/www/html/doc
#
# CONFIG END

SOFTLINKS=autostart jar
TOOLS=src/nonblocking/nonblocking src/ptybuffer/ptybuffer src/ptybuffer/ptybufferconnect src/ptybuffer/script/autostart.sh
CLEANDIRS=src/nonblocking src/ptybuffer
SUBS=compile contrib
CBJAR=$(JARNAM)-$(JARVER).jar
BUILD=tmpbuild
SPIGOTURL=https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/
SPIGOTJAR=BuildTools.jar

#
# all, update
#

.PHONY: all clean distclean install fix
all:	jar/$(CBJAR) $(TOOLS)
	for a in $(SUBS); do $(MAKE) -C "$$a" $@ || exit; done

.PHONY: update
update:	compile

.PHONY: pull
pull:
	git pull && git submodule update --init --recursive && make all

#
# Tools
#

$(TOOLS):
	make -C "`dirname '$@'`" all

jar/$(CBJAR) $(BUILD)/Bukkit:
	make compile

#
# COMPILE
#

.PHONY: compile
compile:
	mkdir -p jar '$(BUILD)'
	cd '$(BUILD)' && wget -N '$(SPIGOTURL)$(SPIGOTJAR)' && java -jar '$(SPIGOTJAR)'
	rm -f 'jar/$(CBJAR)'
	cp -vf '$(BUILD)/$(JARNAM)-$(JARVER)'*.jar 'jar/$(CBJAR)'

fix:
	for a in $(SUBS); do $(MAKE) -C "$$a" $@ || exit; done

#
# CLEAN
#

clean:
	for a in $(SUBS) $(CLEANDIRS); do $(MAKE) -C "$$a" $@; done
	rm -rf '$(BUILD)'

# cannot wipe the copied JARs which are needed by Bukkit to run, to do that run fullclean
distclean:	clean
	# DOC is not cleaned
	for a in $(SUBS) $(CLEANDIRS); do $(MAKE) -C "$$a" $@; done
	echo "To wipe jar/ which is needed by Bukkit to run, use: make fullclean"
	echo "Note that $(DOCDIR) is not cleaned, too."

# perhaps fullclean will vanish in future (make install then copies jar/ to ../jar)
.PHONY: fullclean
fullclean:	distclean
	rm -rf jar

#
# INSTALL
#

.PHONY: doc
doc:	$(BUILD)/Bukkit
	javadoc -encoding UTF-8 -d '$(DOCDIR)/bukkit' -sourcepath '$(BUILD)/Bukkit/src/main/java:$(BUILD)/Bukkit/src/main/javadoc' -subpackages org.bukkit
	sed -i -f misc/javadoc-quicksearch.sed '$(DOCDIR)/bukkit/index-all.html'

.PHONY: install
install:	all
	# softlinks
	for a in $(SOFTLINKS); do rm -f "$$HOME/$$a" && ln -s "$(PWD)/$$a" "$$HOME/$$a"; done
	rm -f "$$HOME/log" && ln -s "/var/tmp/autostart/$$USER" "$$HOME/log"

	mkdir -p '$(BINDIR)' '$(INSDIR)/plugins'
	# ~/bin
	for a in $(TOOLS); do cp -f "$$a" '$(BINDIR)'; done
	for a in bin/*.sh; do b="`basename "$$a" .sh`" && rm -f "$(BINDIR)/$$b" && ln -s "$(PWD)/$$a" "$$HOME/bin/$$b"; done
	sbin/add-crontab.sh '$(CRON)' 'bin/autostart.sh >/dev/null' '### autostart bukkit'
	# ~/bukkit
	[ -L '$(INSDIR)/$(CBJAR)' ]      || ln -vs '../jar/$(CBJAR)' '$(INSDIR)/$(CBJAR)'
	[ -L '$(INSDIR)/$(JARNAM).jar' ] || ln -vs '$(CBJAR)' '$(INSDIR)/$(JARNAM).jar'

	for a in $(SUBS); do $(MAKE) -C "$$a" $@ || exit 1; done
	for a in $(SUBS); do for b in "$$a"/*; do [ -d "$$b" ] || continue; j="`basename "$$b"`.jar"; [ -L "$(INSDIR)/plugins/$$j" ] || ln -vs "../../jar/$$j" "$(INSDIR)/plugins/$$j"; done; done

	@echo
	@echo "To install typeahead searchable javadoc index to $(DOCDIR), run: make doc"
	@echo "Now run:"
	@echo "	bukkit"
	@echo "Answer the questions, then just hit the 'enter' key to start the server."
	@echo "Instead of pressing enter you can give commands like 'help' or 'auto' or 'setup'"


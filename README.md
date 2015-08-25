Setup runnable CraftBukkit by running `make`, as it ought to be.

For the really impatient, followint steps are needed:
- From a freshly created account on Deian Jesse with all neccessary prerequisites installed
- To a running Craftbukkit with DynMap (and WorldEdit) available.

```
cd
git clone https://github.com/hilbix/mc.git
cd mc
git submodule update --init --recursive
make
make install
hash -r
bukkit
start
eula
start
```

Bukkit listens on port 25565 by default.

This works for:
- Debian with all neccessary preriquisites installed
- a fresh login, so nothing is in the way


# MCbuild

Thanks to spigotmc.org for doing 99.99% of the really hard work.

> **WARNING!**
> This assumes that it is installed and run from an empty home directory.
> Also this probably only works if you do not tweak things too much.
> So always have a good current backup handy, as I cannot help you.
> This might break seriously.  **Use at own risk.**  You have been warned.

This was tested on a nonpublic 1-2 user VM with 6 GB RAM, 3 CPU threads of a 3.4 GHz i7


## Usage

This needs around 1 GB in `mc/`, and a lot more in `bukkit/`

Prepare a fresh Debian (Jessie) like following:

```bash
sudo apt-get install git gawk build-essential wget socat
sudo apt-get install openjdk-7-jdk
sudo apt-get install libzmq3-dev pkg-config libtool-bin autoconf	# ZeroMQ java binding
sudo apt-get install maven				# for dynmap
adduser --disabled-password --gecos 'Minecraft 1.8' mc
```

Switch into the context of this `mc` user.

```bash
cd
git clone https://github.com/hilbix/mc.git
cd mc
git submodule update --init --recursive
make
```

Then to prepare a `~/bukkit` run:

```bash
cd
cd mc
make install
```

This installs everyting:

- `~/bin/bukkit` which accesses Bukkit which is started by '~/autostart/bukkit.sh`
- `~/autostart/bukkit.sh`:  An interactive background script which allows you to control the server
- A `cron` job which runs '~/bin/autostart.sh' each minute, such that scripts in `~/autostart/` are automatically started
- Some more helpers into `~/bin` which may be explained in future
- It also tells you how to proceed

Perhaps, after install, you need to do `hash -r` or a relogin for the commands to work.

Note:

- To access the server console, run `bukkit` without parameters.  `bukkit` gives some good login-shell for Bukkit admins.  Execute from `.ssh/authorized_keys` (perhaps I can explain in future deeper)

- If you execute `bukkit` and see `connect: Connection refused` then run `autostart.sh` (it is in `~/bin/`) to start the control script.  If this does not help, do a `less ~/log/bukkit.out` and look at the end of this file.

- Some logging is done in '~/log/bukkit.out'.  You can clean up this directory by removing `*.log` and `*.out` any time.  `*.log` carry minor info while `*.out` perhaps is worth to rotate.


## Updates

- To update this, if you haven't changed anything: `git pull; git submodule update --init --recursive; make; make install`

- If you have some `git` trouble, try `git status` and correct until `git status` is clean

- To update the version of spigot: `cd && cd mc && make update && bukkit stop` (assumes autostart is on)

- If `make` or `make update` fails, try `make clean all` instead


## Contents

- `jar/craftbukkit-1.8.jar` build by invoking the Spigot build process
- `jar/dynmap.jar` suitable for this Craftbukkit 1.8
- `jar/worldedit.jar` suitable for this Craftbukkit 1.8
- `jar/turmites.jar` suitable for this Craftbukkit 1.8

Turmites is, why I created this.  They are not ready yet.  But following works:

- load/save books (see `/t load` and `/t save`)
- set fly and walkspeed (see `/t set`)
- get the position of any player

Note that the `turmites` plugin will change in future.  And if `turmites` is ripe enough to replace worldedit, I will drop `worldedit` support.


## Missing links

These are not yet properly documented here:

- Bukkit is probably not properly configured:
  - `~/bukkit/server.properties`
  - `~/bukkit/bukkit.yml`
  - `~/bukkit/permissions.yml`
- PluginMetrics is probably not properly configured:
  - `~/bukkit/plugins/PluginMetrics/config.yml`
- Dynmap is not properly configured:
  - `~/bukkit/plugins/dynmap/`
- You probably want to configure Putty/ssh such, that you can connect to Bukkit via a tunnel.
- You probably want to protect port 25565 against connections from unauthenticated users.

You currently have to do this as usual on your own, sorry, no support here for this yet.

Things you probably want to try (beginners hints):

- `op YOURPLAYER` on the `bukkit` console.  This works if the server runs.
- Stop the server using the server's `stop` command.
- After stopping, you can backup the server with the `backup` command (this needs some additional steps outside the `bukkit` script, which are told peu-a-peu if you give `backup`).  This backs up all the data under `~/bukkit` (but no other data!).  Beware, backups take a while and the backup is done to the local drive, so you probably want to save the backups somewhere really safe.
- You probably want to enable `auto` mode and later `bkon` (automatically backup) mode as well.


# FAQ

- Q: I have a FAQ
> A: Try https://github.com/hilbix/mc/wiki for mor FAQs.
> You can try https://hydra.geht.net/pager.php and perhaps I will listen.
> And BTW if you mark such messages "important" if they are not important to me, you just demonstrate, that you are mentally retarded.

- Q: `bukkit` gives something like `blah socat blah: Connection refused`
> A: look in `crontab -l` if `bin/autostart.sh`. Try `bash -x bin/autostart.sh` to diagnose.
> Also have a look into `~/log/bukkit.out`.  There are also `~/log/*.log` files which might help.
> Try not to touch or remove `.sock` files (they prevent things to be started multiply), all others files found in `~/log/` can be removed safely any time and are recreated if needed.

- Q: `bukkit cmd` outputs a lot of old server output, too.
> A: There is no workaround known for this, yet.

- Q: `bukkit cmd` delays two seconds and if commands are given in parallel, the output is mixed.
> A: There is no workaround known for this, and probably will never be.
> There is only a single bukkit console which is shared across all parallel running accesses.
> It's like a small chat system where everybody sees what others say.
> And there is no way to know when output of a command ends, so this is "detected" via silence.
> Not that this is more a limitation how java is controlled from commandline than the scripts here.

- Q: `bukkit CMD` does not support interactive commands
> A: Yes, this is a limitation.  Use `bukkit` and then enter the `CMD`

- Q: How to backup?
> A: Stop your server with `bukkit stop`, then run backup with `bukkit backup`.
> This runs an example script `~/bin/backup.sh` which backups everything in `~/bukkit`.
> If this works you see something like `Backup successful`
> If you see some `OOPS`, follow instructions which are printed, then retry.
> Note that `~/backup` can be a softlink which points to where you want to keep your backups written by `attic`.

- Q: How to restore?
> A: Please read `man attic`.  Use `~/backup/mc.attic` as `ARCHIVE`.
> But I cannot help you more on this subject, as `attic` is a pretty standard Linux command.

> Q: What is the `move` command?
> A: There is no example script for this yet.  If `~/bin/mover.sh` is present, it shall be a wrapper which copies `~/backup/.` to a remote server.   It is forked in background automatically after backup.  Perhaps create something which uses `rsync` for this.  Or wraps some script from your ISP to do backups.

- Q: How do I run Minecraft?
> A: This is not the Minecraft game.  This prepares a CraftBukkit 1.8 Minecraft Server.  Only.  If you do no know what this means, you are probably wrong here.

- Q: But I want to run Minecraft!
> A: Buy it.

- Q: I want Spigot.
> A: Look elsewhere.  I do not know anything about Spigot yet and probably never will.

- Q: I want Sponge.
> A: Sorry, you have to look elsewhere for now becasue I did not manage to run Sponge properly yet, sadly.
> However if somebody wants to enlighten me in how to setup and run sponge just by typing `make` such that it runs at least as stable as Bukkit based on Spigot, please leave me a message: http://hydra.geht.net/pager.php

- Q: It does not work.
> A: If this here does not help you, sorry, I cannot help.  Learn how to debug shell scripts and cron jobs and then follow the yellow brick road (start at `crontab -l`).

- Q: Please can you help?
> A: Nope, I really cannot help you!  Sorry.

- Q: How to run this under Windows/OS-X/BSD/RHEL/etc.
> A: This works under Debian Linux.  Everything else is up to you.

- Q: I found a bug!
> A: Clone, fix, push, pull-request.  Perhaps I listen.  Likely not.

- Q: This is not secure!
> A: It works as designed.  But see "I found a bug!".

- Q: Can you add plugin XYZ.
> A: Nope.  But you can.  `git submodule add URL-of-your-plugin-builder contrib/pluginname; cd contrib; vim Makefile`.
> See `compile/` for example.

- Q: So what are turmites?
> A: Just a name in that case here.  For more background please see Wikipedia.

- Q: License?
> A: Are you kidding?  This?  Free, what else!  Parts of the software linked here is Open Source with different licenses, of course.

- Q: Author?
> A: Not important.  This only assembles many things done by others.  Read the source for more information.


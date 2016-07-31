Setup runnable Spigot by running `make`, as it ought to be.

For the really impatient:
- Following steps are needed to run Spigot including plugins DynMap (and WorldEdit):
- Create a new blank user on a Debian Jessie with all neccessary prerequisites installed.
- Enter that user somehow.  Then do:

```
cd
git clone https://github.com/hilbix/mc.git
cd mc
git submodule update --init --recursive
make install
hash -r
bukkit
# Answer the questions on the screen
# Then you can enter commands.  To start the server use:
start
```

Spigot listens on port 25565 for connections by default, as usual.

Please note that the binary still is called `bukkit`.  Perhaps a future version will be renamed to `spigot`.


# MCbuild

Thanks to spigotmc.org for doing 99.99% of the really hard work.

> **WARNING!**
> This assumes that it is installed and run from an empty home directory.
> Also this probably only works if you do not tweak things too much.
> So always have a good current backup handy, as I cannot help you.
> This repo might break seriously.  **Use at your own risk.**  You have been warned.

This was tested on a nonpublic 1-2 user VM with 6 GB RAM, 3 CPU threads of a 3.4 GHz i7


## Usage

This needs around 1 GB in `mc/`, and a lot more in `bukkit/`

Prepare a fresh Debian (Jessie) with `sudo` for your login user.  Then do:

```bash
sudo apt-get install git gawk build-essential wget socat		# For build and tools
sudo apt-get install openjdk-8-jdk					# Spigot
sudo apt-get install libzmq3-dev pkg-config libtool-bin autoconf	# ZeroMQ java binding
sudo apt-get install maven						# dynmap
sudo adduser --disabled-password --gecos 'Minecraft 1.8' mc		# create user "mc"
```

Enter this new user `mc`, you can use: `sudo su - mc`

All following is done in the context of this new `mc` user:

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

This installs everything:

- `~/bin/bukkit` which accesses Spigot console.  Leave this console with `Ctrl+D` (aka `EOF` or `^D`) while bukkit continues to run in background.
- `~/autostart/bukkit.sh`:  An interactive background script which allows you to control the server
- A `cron` job which runs '~/bin/autostart.sh' each minute, such that scripts in `~/autostart/` are automatically started
- Some more helpers into `~/bin` which may be explained in future
- It also tells you how to proceed

Perhaps, after install, you need to do `hash -r` or do a relogin for the commands to work.

Note:

- To access the server console, run `bukkit` without parameters.  `bukkit` gives some good login-shell for Spigot admins.  Execute from `.ssh/authorized_keys` (perhaps I can explain in future deeper)

- If you execute `bukkit` and see `connect: Connection refused` then run `autostart.sh` (it is in `~/bin/`) to start the control script.  If this does not help, do a `less ~/log/bukkit.out` and look at the end of this file.

- Some logging is done in '~/log/bukkit.out'.  You can clean up this directory by removing `*.log` and `*.out` any time.  `*.log` carry minor info while `*.out` perhaps is worth to rotate.


## Updates

- To update this, use `make pull`, this runs `git pull && git submodule update --init --recursive && make all`

- If you have some `git` trouble, try `git status` and correct until `git status` is clean

- To update the version of Spigot provided by Spigot: `cd && cd mc && make update && bukkit stop` (assumes autostart is on)

- If `make` fails try `make clean all` instead

- If `make update` fails, try `make clean update` instead

- Look at the output.  There might be hints when to run `make fix` in case `maven` or `gradle` misbehave (as `make distclean` might not help in that case).


## Helpers

- `make doc`:  This installs a searchable index for the Bukkit-API into `/var/www/html/doc/bukkit/` (switch to "Index" to see a type ahead search bar, which is very helpful to locate things quickly in the Bukkit-API)


## Contents

- `jar/spigot-....jar` build by invoking the Spigot provided build process
- `jar/dynmap.jar` suitable for this version
- `jar/worldedit.jar` suitable for this version
- `jar/turmites.jar` suitable for this version

FYI: Turmites is, why I created this.  This is terribly incomplete yet.  But following works:

- load/save books (see `/t load` and `/t save`)
- set fly and walkspeed (see `/t set`)
- get the position of any player (see `/t get`)

Note that the `turmites` plugin will change in future.  And if `turmites` is ripe enough to replace `worldedit`, I will drop `worldedit` support (sorry, but `worldedit` is like cheating).


## Missing links

Following is not yet properly documented here:

- Spigot is probably not properly configured:
  - `~/bukkit/server.properties`
  - `~/bukkit/bukkit.yml`
  - `~/bukkit/permissions.yml`
- PluginMetrics is probably not properly configured:
  - `~/bukkit/plugins/PluginMetrics/config.yml`
- Dynmap is not properly configured:
  - `~/bukkit/plugins/dynmap/`
- You probably want to configure Putty/ssh such, that you can connect to Spigot via a tunnel.
- You probably want to protect port 25565 against connections from unauthenticated users.

You currently have to do this as usual on your own, sorry, no support here for this yet.

Things you probably want to try (beginners hints):

- `op YOURPLAYERNAME` on the `bukkit` console.  This works if the server runs.
- Stop the server using the server's `stop` command.
- After stopping, you can backup the server with the `backup` command (this needs some additional steps outside the `bukkit` script, which are told peu-a-peu if you enter `backup`).  This backs up all the data under `~/bukkit` (but no other data!).  Beware, backups take a while and the backup is done to the local drive, so you probably want to save the backups somewhere really safe.
- You probably want to enable `auto` mode and later `bkon` (automatically backup) mode as well.


# FAQ

- Q: I have a FAQ
> A: Try https://github.com/hilbix/mc/wiki for mor FAQs.
> You can try https://hydra.geht.net/pager.php and perhaps I will listen.
> And BTW if you mark such messages "important" if they are not really life-threatening, you just demonstrate, that you are mentally retarded.

- Q: `bukkit` gives something like `blah socat blah: Connection refused`
> A: look in `crontab -l` if `bin/autostart.sh`. Try `bash -x bin/autostart.sh` to diagnose.
> Also have a look into `~/log/bukkit.out`.  There are also `~/log/*.log` files which might help.
> Try not to touch or remove `.sock` files (they prevent things to be started multiply), all others files found in `~/log/` can be removed safely any time and are recreated if needed.

- Q: `bukkit cmd` outputs a lot of old server output, too.
> A: There is no workaround known for this, yet.

- Q: `bukkit cmd` delays two seconds and if commands are given in parallel, the output is mixed.
> A: There is no workaround known for this, and probably will never be.
> There is only a single bukkit console which is shared across all parallel running accesses.
> It's like a small chat system where everybody sees what others type.
> And there is no way to know when output of a command ends, so this is "detected" via silence.
> Note that this is more a limitation how java is controlled from commandline than the scripts here.

- Q: `bukkit CMD` does not support interactive commands
> A: Yes, this is a limitation.  Use `bukkit` and then enter the `CMD`

- Q: How to backup?
> A: Stop your server with `bukkit stop`, then run backup with `bukkit backup`.
> This runs an example script `~/bin/backup.sh` which backups everything in `~/bukkit`.
> If this works you see something like `Backup successful`
> If you see some `OOPS`, follow instructions which are printed, then retry.
> Note that `~/backup` can be a softlink which points to where you want to keep your backups written by `attic`.

- Q: How to restore from the backup?
> A: Try `backup.sh mount`, the `attic` archives are then in directory `~/restore`.
> You can also run `attic list ~/backup/mc.attic` to list the `BACKUP`s and then run something like `attic extract -vn ~/backup/mc.attic::BACKUP` etc.
> `attic` is a pretty standard Linux command, so please help yourself (RTFM).

> Q: What is the `move` command?
> A: There is no example script for this yet.  If `~/bin/mover.sh` is present, it shall be a wrapper which copies `~/backup/.` to a remote server.   It is forked in background automatically after backup.  Perhaps create something which uses `rsync` for this.  Or wrap some script from your ISP to do backups.

- Q: How do I run Minecraft?
> A: This is not the Minecraft game.  This prepares a Spigot Minecraft Server.  Only.  If you do no know what this means, you are probably wrong here.

- Q: But I want to run Minecraft!
> A: Minecraft must be bought from Mojang/Microsoft at http://minecraft.net/

- Q: I want Bukkit.
> A: Look out for the old version, this was for Bukkit.

- Q: I want Sponge.
> A: Sorry, you have to look elsewhere for now because I did not manage to run Sponge properly yet, sadly.
> However if somebody wants to enlighten me in how to setup and run Sponge just by typing `make` such that it runs at least as stable as Spigot, please leave me a message: http://hydra.geht.net/pager.php

- Q: It does not work.
> A: If this here does not help you, sorry, I cannot help.  Learn how to debug shell scripts and cron jobs and then follow the yellow brick road (start at `crontab -l`).  If you found the fix, see "I found a bug!"

- Q: Please can you help?
> A: Nope, I really cannot help you!  Sorry.

- Q: How to run this under Windows/OS-X/BSD/RHEL/etc.
> A: This works under Debian Linux.  Everything else is up to you.
> But for Windows you might try cygwin.com as environment to build.

- Q: I found a bug!
> A: Clone, fix, push, send pull-request on Github.  Perhaps I listen.  Likely not.

- Q: This is not secure!
> A: It works as designed.  But see "I found a bug!".

- Q: Can you please add plugin XYZ?
> A: Nope.  But you can.  `mkdir contrib/contribname; git clone GITURL-of-plugin.git contrib/XYZ/source/;  cd contrib/XYZ; ln -s ../../jar; cp ../Makefile Makefile; vim Makefile` and create a proper Makefile to wrap the build and install stages from `source/`.  Note that the plugin then is installed as `~/bukkit/plugins/XYZ.jar`
> See `compile/dynmap/Makefile` for an example how it may look like.  If you think it's worthwhile, perhaps send a pull-request.

- Q: So what are `turmites`?
> A: Just a working-name in that case here.  For more background please see Wikipedia.

- Q: License?
> A: Are you kidding?  This?  Free, what else!  Parts of the software linked here is Open Source with different licenses, of course.

- Q: Author?
> A: Really not important.  This only assembles many things done by others.  Read the source for more information.


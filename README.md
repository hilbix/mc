In short what this does:

Just type `make`, then you will find following in `jar/`:

- `jar/craftbukkit-1.8.jar` - by invoking the Spigot build process
- `jar/worldedit.jar` suitable for this Craftbukkit 1.8
- `jar/turmites.jar`

Terribly incomplete:

- `make install`:  It prepares the environment, but it not yet creates a workable `~/bukkit/` directory
- `turmites` plugin to CraftBukkit

Turmites currently just can do:

- load/save books (see `/t load` and `/t save`)
- set fly and walkspeed (see `/t set`)

Note that when `turmites` starts to become really working inclusion of WorldEdit will be droped as it is mostly redundant.


# MCbuild

Setup runnable CraftBukkit by running `make`, as it ought to be.

Thanks to spigotmc.org for doing 99.99% of the really hard work.

> **WARNING!**
> This assumes that it is installed and run from an empty home.
> Also this probably only works if you do not tweak things too much.
> So always have a good current backup handy, as I cannot help you.
> This might break seriously.  **Use at own risk.**  You have been warned.

This here runs on a nonpublic 1-2 user VM with 4 GB RAM, 3 CPU threads of a 3.4 GHz i7

## Usage

This needs around 1 GB in `mc/`, and a lot more in `bukkit/`

Prepare a fresh Debian like following:

```bash
sudo apt-get install git gawk build-essential wget socat
sudo apt-get install openjdk-7-jdk
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

This installs a `cron` job as well which starts a start script to launch Bukkit in background.  However this is not active by default.

To run bukkit:

```
bukkit run
```

Perhaps you need to do a relogin for the command to work.


## Later

- To update the version of spigot: `cd && cd mc && make update && bukkit stop` (assumes autostart is on)

- If `make update` fails, try `make clean update` instead

- To access the server console, run `bukkit` without parameters.  `bukkit` gives some good login-shell for Bukkit admins.  Execute from `.ssh/authorized_keys`

- Some logging is done in '/var/tmp/autostart/mc/bukkit.out'.  You can clean up this directory by removing `*.log` and `*.out` any time.


# FAQ

- Q: I have a FAQ
> A: try https://hydra.geht.net/pager.php and, perhaps, I will listen.  And BTW if you mark such things "important" you demonstrate me spectacularily that your are an irresponsibe person.

- Q: `bukkit` gives something like `blah socat blah: Connection refused`
> A: look in `crontab -l` if `bin/autostart.sh`. Try `bash -x bin/autostart.sh` to diagnose.

- Q: `bukkit cmd` outputs a lot of old server output, too.
> A: There is no workaround known for this, yet.

- Q: `bukkit cmd` delays a second and if commands are given in parallel, the output is mixed.
> A: There is no workaround known for this, and probably will never be.
  There is only a single bukkit console which is shared across all parallel running accesses.
  It's like a small chat system where everybody sees what others say.
  And there is no way to know when output of a command ends, so this is "detected" via silence.

- Q: How do I run Minecraft?
> A: This is not the Minecraft game.  This prepares a CraftBukkit 1.8 Minecraft Server.  Only.  If you do no know what this means, you are probably wrong here.

- Q: But I want to run Minecraft!
> A: Buy it.

- Q: I want Spigot.
> A: Look elsewhere.  I do not know anything about Spigot yet.

- Q: It does not work.
> A: I cannot help you.

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

- Q: License?
> A: Are you kidding?  This?  Free, what else!  Parts of the software linked here is Open Source with different licenses, of course.

- Q: Author?
> A: Not important.  This only assembles many things done by others.  Read the source for more information.


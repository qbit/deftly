author: Aaron Bieber <aaron@bolddaemon.com>
title: Using cabal on OpenBSD
description: Quick rundown for using cabal in a W^X'd world.
tags: OpenBSD,Software,Haskell
date: Tue, 12 Sep 2017 16:35:00 MDT

Since [W^X became
mandatory](https://undeadly.org/cgi?action=article&sid=20160527203200)
in OpenBSD, W^X'd binaries are only allowed to be executed from
designated locations (mount points). If you used the auto partition
layout during install, your `/usr/local/` will be mounted with
`wxallowed`. For example, here is the entry for my current machine:

```
/dev/sd2g on /usr/local type ffs (local, nodev, wxallowed, softdep)
```

This is a great feature, but if you build applications outside of the
`wxallowed` partition, you are going to run into some issues,
especially in the case of `cabal` (python as well).

Here is an example of what you would see when attempting to do `cabal
install pandoc`:

```
qbit@slip[1]:~λ cabal update
Config file path source is default config file.
Config file /home/qbit/.cabal/config not found.
Writing default configuration to /home/qbit/.cabal/config
Downloading the latest package list from hackage.haskell.org
qbit@slip[0]:~λ cabal install pandoc
Resolving dependencies...
.....
cabal: user error (Error: some packages failed to install:
JuicyPixels-3.2.8.3 failed during the configure step. The exception was:
/home/qbit/.cabal/setup-exe-cache/setup-Simple-Cabal-1.22.5.0-x86_64-openbsd-ghc-7.10.3: runProcess: runInteractiveProcess: exec: permission denied (Permission denied)
```

The error isn't actually what it says. The untrained eye would assume
permissions issue. A quick check of `dmesg` reveals what is really
happening:

```
/home/qbit/.cabal/setup-exe-cache/setup-Simple-Cabal-1.22.5.0-x86_64-openbsd-ghc-7.10.3(22924): W^X binary outside wxallowed mountpoint
```

OpenBSD is killing the above binary because it is violating W^X and
hasn't been safely kept in its `/usr/local` corral!

We could solve this problem quickly by marking our `/home` as
`wxallowed`, however, this would be heavy handed and reckless (we
don't want to allow other potentially unsafe binaries to
execute.. just the cabal stuff).

Instead, we will build all our cabal stuff in `/usr/local` by using
a symlink!

```
doas mkdir -p /usr/local/{cabal,cabal/build} # make our cabal and build dirs
doas chown -R user:wheel /usr/local/cabal    # set perms
rm -rf ~/.cabal                              # kill the old non-working cabal
ln -s /usr/local/cabal ~/.cabal              # link it!
```

We are almost there! Some cabal packages build outside of
`~/.cabal`:

```
cabal install hakyll
.....
Building foundation-0.0.14...                                                   Preprocessing library foundation-0.0.14...
hsc2hs: dist/build/Foundation/System/Bindings/Posix_hsc_make: runProcess: runInteractiveProcess: exec: permission denied (Permission denied)
Downloading time-locale-compat-0.1.1.3...
.....
```

Fortunately, all of the packages I have come across that do this all
respect the `TMPDIR` environment variable!

```
alias cabal='env TMPDIR=/usr/local/cabal/build/ cabal'
```

With this alias, you should be able to cabal without issue (so far
pandoc, shellcheck and hakyll have all built fine)!

---

## TL;DR

```
# This assumes /usr/local/ is mounted as wxallowed.
#
doas mkdir -p /usr/local/{cabal,cabal/build}
doas chown -R user:wheel /usr/local/cabal
rm -rf ~/.cabal
ln -s /usr/local/cabal ~/.cabal
alias cabal='env TMPDIR=/usr/local/cabal/build/ cabal'
cabal install pandoc
```
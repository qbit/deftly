author: Aaron Bieber <aaron@bolddaemon.com>
title: pledge(2)'ing Xmonad
description: Bringing OpenBSD's pledge(2) to Xmonad
tags: OpenBSD
date: Sun, 06 Mar 2016 12:00:00 MST

## Background

For those that don't know, [pledge(2)](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man2/pledge.2?query=pledge&arch=i386) is an OpenBSD specific feature that allows applications to "promise" to use a subset of system calls. If an app has promised to only use, say, `rpath` (obviously this is a contrived example) it would only be allowed to run this subset of system calls: `chdir(2)`, `getcwd(3)`, `openat(2)`, `fstatat(2)`, `faccessat(2)`, `readlinkat(2)`, `lstat(2)`, `chmod(2)`, `fchmod(2)`, `fchmodat(2)`, `chflags(2)`, `chflagsat(2)`, `chown(2)`, `fchown(2)`, `fchownat(2)`, `fstat(2)`, `getfsstat(2)`. If the app tries to access a system call other than these, the kernel will kill the app with a SIGABRT.

Since the addition of pledge(2) a handful of OpenBSD ports (including ghc) have added support for it! This means we can use pledge(2) in haskell apps like Xmonad!

When you pledge an app, you need to read through and understand what it is doing so that you can properly set the promises it will use. In larger apps you can make successive calls to pledge(2) from various parts of the app, this allows you to conditionally ratchet down the required promises.

For example, you could make an initial loose pledge of `stdio rpath wpath cpath proc exec unix`, then later remove a few calls like so: `stdio rpath wpath cpath unix`.

The second set of promises listed above is a fairly bad example in this case, as window managers will need `proc` and `exec` to start new programs.

## Hello Pledge!

Lets write an extremely limited app that can only make calls from the `stdio` set.

```
import System.OpenBSD.Process ( pledge )

main = do
    _ <- pledge "stdio" Nothing
    putStrLn "Hello, World!"
```

As a test, you can run with `tty` specified instead of `stdio`. ghc will be able to build the binary, but upon execution you will see something like following in dmesg:

```
hello(21115): syscall 92 "stdio"
```

## Pledged Xmonad

Finally on to Xmonad! Here is an extremely basic example of a `xmonad.hs` file you could use.

```
import XMonad
import System.IO
import System.OpenBSD.Process ( pledge )

main = do
    _ <- pledge "stdio rpath proc exec unix" Nothing
    xmonad $ defaultConfig
```

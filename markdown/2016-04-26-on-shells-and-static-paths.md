author: Aaron Bieber <aaron@bolddaemon.com>
title: On Shells and Static Paths
description: How static paths are actively harming the industry.
tags: Shell,OpenBSD
date: Tue, 26 Apr 2016 00:00:00 UTC

> ***In a previous post, I told people not to start their scripts with
`#!/bin/bash`. In this post, I will explain in more detail why you
shouldn't do this if you want your script to be portable!***

Operating systems, they are neat, aren't they? So much diversity, so
many options! Don't like the shell that comes stock on your OS because
it doesn't connect to the internet, download a list of packages that
*might* be similar to a mistyped command you haphazardly pasted into
your terminal? Great, you can install one that does! So many options!

With all these options available to us, how can someone settle on a
single PATH to contain all this greatness? Why put `bash` in `/bin`?
Why not `/opt/fancy/oh-bash-my-face/bin`?

Well.. lets not get crazy here... That's clearly a terrible location
for `bash`, no way it's standard!

# Right!

Lets talk about a specific set of standards, [The Single UNIX®
Specification](http://pubs.opengroup.org/onlinepubs/7990989775/index.html)
and [POSIX IEEE Std 1003.1](http://pubs.opengroup.org/onlinepubs/9699919799/)

It's true that not all Unixie operating systems conform to these
standards, but all of them implement enough to solve the problem of a
given shell not being installed in `/bin`!

# The wisdom of The Grey Ones

Long ago, the Great Grey Ones knew that not everyone would put things
in `/bin`. They also knew that for a script/binary to be usefull.. it
needed to be in your PATH environment variable! Because of this.. they
made statements like: 

> Applications should note that the standard PATH to the shell cannot
be assumed to be either /bin/sh or /usr/bin/sh, and should be
determined by interrogation of the PATH returned by getconf PATH,
ensuring that the returned pathname is an absolute pathname and not a
shell built-in.

Both POSIX and SUS define this.

I know what you are thinking: "Surely this applies only to `sh`, `bash`
is the new standard, `bash` is everywhere! Anything that doesn't have
`bash` is old and therefore not used! My `bash` is in `/bin/bash` -
yours **MUST** be as well!" 

## No!

What if I told you, some systems like [OpenBSD](http://openbsd.org) and
[FreeBSD](http://freebsd.org) do things a little differently. They have
a clear distinction between "base" applications and applications that
are installed via their respective `ports` systems.

For various reasons, things like `bash` and `zsh` are not included in
"base". This means they will be installed outside of the typical "/bin,
/usr/bin" directory structure. Which means when you put lines like:
`#!/bin/bash` at the top of your script you are ensuring that your
script will not run on OpenBSD or FreeBSD (or any other system that has
`bash` installed somewhere else)!

# Back to The Grey Ones

They planned for this! They gave us nifty tools that allow us to
invoke these these shells without knowing the explicit path for said
shell!

Tools like `/usr/bin/env` which:

> executes utility after modifying the environment as specified on the
command line.

Simply calling `env` will spit out a list of all your currently set
variables! These vars get passed to `utility` when you execute
something like `env bash` (where `bash` is the utility).

This means if we have our scripts execute `#!/usr/bin/env bash` as the
first line of our script, the PATH variable will be set to something
that is more likely to contain `bash` than an explicit declaration
like `/bin/bash` which, as we learned, doesn't exist on some systems!

# Conclusion

Don't be ***that guy***. If your script is meant to run on a variety
of systems, follow the advice of The Grey Ones, use something like
`env` to make your scripts portable. I have yet to see a *NIX OS that
lacks `/usr/bin/env`. This includes things like True64.


author: Aaron Bieber <aaron@bolddaemon.com>
title: Tab completion in OpenBSD's ksh
description: How did I not know about this until now!?
tags: OpenBSD,ksh
date: Mon, 01 May 2017 17:18:00 MST

# OpenBSD's ksh

..is the little shell that could. In ~20k lines of code, it has many
of the same features as more popular shells like zsh and bash. Plus it
has the added bonus of being [pledge(2)'d](http://man.openbsd.org/pledge)!

One of the features OpenBSD's ksh shares with its more popular
friends is user definable completions! Something that sets it apart,
however, is the simplicity of these completions. From the man page:

```
Custom completions may be configured by creating an array named
‘complete_command’, optionally suffixed with an argument number
to complete only for a single argument.
```
For example, here is a completion for
[vmctl(8)](http://man.openbsd.org/vmctl) with expansion of defined VM
names:

```
# vmctl
set -A complete_vmctl -- console load reload start stop reset status
set -A complete_vmctl_2 -- $(vmctl status | awk '!/NAME/{print $NF}')
```

Hats off to Nicholas Marriott nicm@ for implementing it and to
brynet@ for pointing it out to me! I was close to switching to
[fish](https://fishshell.org) in an attempt to save my wrists.. but
the ~180k lines of extra (yeah, on top of the 20k!) code in fish was
kinda scaring me!

For anyone interested, here is a quick comparison of CLOC for a few
popular shells:

Shell | Version | Total Lines (cloc)
:-----|:--------|---------:
ksh|Mon May  1 07:17:54 UTC 2017|19680
zsh|5.3.1|127246
fish|2.5.0|207597
bash|4.4|351043

I understand LOC isn't a good measure of quality, but it sure does
mean you have a lot more reading to find that quality!

A full list of my completions can be found [here](https://github.com/qbit/dotfiles/blob/master/common/dot_ksh_completions)!
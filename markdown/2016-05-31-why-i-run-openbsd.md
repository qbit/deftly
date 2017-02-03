author: Aaron Bieber <aaron@bolddaemon.com>
title: Why I Run OpenBSD
description: A story of how OpenBSD came to be my favorite OS.
tags: OpenBSD,Linux
date: Tue, 31 May 2016 15:04:05 MST

This post is about my journey down the OS rabbit hole and how it
landed me in OpenBSD land as a happy and productive user.

It contains information that is highly opinionated, wildly
inaccurate, mostly speculation. It is, after all, on the internet!

### UPI

One thing I learned during my travels between OSs: consistency is
everything.

Most operating systems seem to, at least, keep a consistent interface
between themselves and binaries / applications. They do this by keeping
consistent APIs (Application Programming Interfaces) and ABIs
(Application Binary Interfaces). If you take a binary from a really old
version of Linux and run or build it on a brand-spanking new install of
Linux, it will likely *Just Work™*. This is great for applications
and developers of applications. Vendors can build binaries for
distribution and worry less about their product working when it gets
out in the wild (sure this binary built in 2016 will run on RedHat
AS2.1!!).

With all this catering to applications and developers, one would think
that a similar level of attention would be applied to the *users* of
the applications and systems: User Program Interfaces (UPI) as I like to
call them!

A good example of a poor UPI is (was?) `ifconfig(8)` on Linux. From a
user's perspective, `ifconfig`, a command to "configure network
interface parameters" should work on... well, network interfaces!
This includes wireless, hard-wired, cell based... etc.

On Linux, however, this is no longer the case (at least for some devices).

This inconsistency seems to have come to be when Linux started getting
wireless support. For some reason someone (vendors, maybe?) decided
that `ifconfig` wasn't a good place to let users interact with their
wireless device. Maybe they felt their device was special? Maybe there
were technical reasons? The bottom line is, someone decided to create
a new utility to manage a wireless device... and then another one came
along... pretty soon there was `iwconfig(8)`, `iw(8)`, `ifconfig(8)`,
some funky thing that let windows drivers interface with Linux..  and
one called `ip(8)` I am sure there are others I am forgetting, but I
prefer to forget. I have moved onto greener pastures and the knowledge
of these programs no longer serves me.

Simply configuring a wireless network on Linux became a huge hassle:

- **User**: Which tool do I use to configure my wireless? `ifconfig`
doesn't seem to be able to help me.
- **Google[1]**: Well it depends on what driver you are using.
- **User**: Intel blablablbla.
- **Google[1] -> Intel Site**: `iwconfig`! The command is going to look
very similar to `ifconfig` but don't let that fool you! It's very
different and only works with one very specific type of wireless
device!

**[1]** Note, the use of google here. This is very crucial, and the
very first sign of poor UPI, if the user has to go somewhere outside
the system to find information on the system, you have already lost.
Your UPI sucks.

### The Double Drill Set

All of this inconsistency with the wireless stuff left me with a
dirty, uneasay feeling. Where else is this disregard for users
manifesting? Is there no process that looks at tooling and says:
"Wait, these tools do very similar things from a users
perspective. Let's not clutter the environment with more tools that do
_almost_ the same thing."

It's like having two drills, one that drives screws in, and another
that take them out.

Maybe none of this is Linux (the kernel)'s fault, maybe it's because
userland is built over here by these people... and the kernel over
there by those people. Perhaps it's the job of a distributor like
Debian or RedHat to keep things consistent for the end user. I don't
really know, but at this point, it didn't seem like it's a high
priority for any of them.

### Back and Forth

Throughout my OS travels, I have consistently gone back and forth
between Linux and the BSDs. At least yearly, I would have FreeBSD,
OpenBSD or NetBSD on my main system. Usually this would end after a few
months because one tiny thing that worked in Linux was missing. Be it
an application or a driver.

But then something changed. I decided that I had enough of this dirty
feeling. I was going to abandon Linux and use one of the BSDs full
time. If something didn't work, I was going to fix it. If I didn't
have an application I needed, I was going to port it. But I didn't
know which BSD to choose. All of them had issues with at least one
thing I needed, so all were candidates for adoption!

### The Showdown

One month, one BSD. Starting with FreeBSD, then OpenBSD, then NetBSD.

Since none of the BSDs completely worked for me, I knew it would be a
tough journey. There would be sacrifices, there would be work that
needed to be done.

A few things were clear:

1) If I found myself googling for information that the system should
have provided, that system was not the one for me.
2) If the system had glaring UPI violations, it wasn't the system for me.
3) If system simplicity was created via overly complex mechanisms, the
system was not for me.

### Long Story Short

OpenBSD won the showdown. It was the most complete, simple, and
coherent system. The documentation was thorough, the code was easy to
follow and understand. 

It had one command to configure all of the network interfaces!

I didn't have wireless, but I was able to find a cheap USB adapter
that worked by simply running `man -k wireless` and reading about the
USB entries.

It didn't have some of the applications I use regularly, so I started
reading about ports (intuitively, via `man ports`!).

### The Test

Shortly after selecting OpenBSD, I switched my ISP from Comcast to
Century Link. Early on I decided I would run my modem in "bridge"
mode, and have OpenBSD doing all the PPPoE stuff. To test my metal
(and OpenBSD's) I was going to configure everything without consulting
the internet!

Armed with ONLY OpenBSD and its excellent documentation, I was able to
configure an OpenBSD router doing PPPoE, NAT, DNS and DHCP. All
without installing a single thing outside of the base OS (which, I
might add, was installed on a 2G CF card with room to spare!) and not
a single search engine query (no internet, remember? :P)!

### FastForward to Now

OpenBSD is my main OS and the only OS I truly enjoy running. With
every release it gains new, awesome features that embody simplicity,
security, and consistency.

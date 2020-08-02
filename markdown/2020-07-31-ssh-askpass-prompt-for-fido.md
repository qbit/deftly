author: Aaron Bieber <aaron@bolddaemon.com>
title: Unlocking SSH FIDO keys on device connect.
description: Tired of typing 'ssh-add -K'? Me too!
tags: OpenSSH YubiKey OpenBSD
date: Fri, 31 Jul 2020 16:43:38 MST

# The problem

As a lazy type, I often find it trying to type "ssh-add -K" over and over. I
even felt depleted typing it here!

Fortunately for me, OpenBSD makes it trivial to resolve this issue. All we need
is:

  - [hotplugd](https://man.openbsd.org/hotplugd)
  - [pkill](https://man.openbsd.org/pkill)
  - Some shell foo.
  
## The adder

This script will run our ...hnnn`ssh-add -K`.. command:

```
#!/bin/sh

trap 'ssh-add -K' USR1

while true; do
	sleep 1;
done
```

Notice the `trap` line there? More on that later! This script should be called
via `/usr/local/bin/fido &` from `~/.xsession` or similar. The important thing
is that it runs _after_ you log in.

## The watcher

`hotplugd` (in OpenBSD base) does things when stuff happens. That's just what we
need!

This script (`/etc/hotplugd/attach`) will be called every time we attach a
device:

```
#!/bin/sh

DEVCLASS=$1
DEVNAME=$2

case "$DEVNAME" in
	fido0)
		pkill -USR1 -xf "/bin/sh /usr/local/bin/fido"
	;;
esac
```

Notice that `pkill` command with `USR1`? That's the magic that hits our `trap`
line in the adder script!

Now enable / start up hotplugd:

```
# rcctl enable hotplugd
# rcctl start hotplugd
```

## That's it!

If you have all these bits in place, you should see `ssh-askpass` pop up when
you connect a FIDO key to your machine!

Here is a video of it in action:

<video width="620" controls>
  <source src="/fido-add.mp4" type="video/mp4">
  <p>Your browser doesn't support HTML5 video. Here is
     a <a href="myVideo.mp4">link to the video</a> instead.</p>
</video>

Thanks to kn@ for the `USR1` suggestion! It really helped me be more lazy!


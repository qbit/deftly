author: Aaron Bieber <aaron@bolddaemon.com>
title: Using a picoLCD 256×64 on OpenBSD 4.7
description: Bit of hacking to get the picoLCD working on OpenBSD
tags: OpenBSD
date: Thu, 12 Jan 2012 12:00:00 MST

The first thing you will notice if you connect your fancy picoLCD 256×64 to your OpenBSD box, is that it shows up as a Human Interface Device.

Unfortunately libusb doesn’t know what to do with devices on bsd systems that are NOT using the **ugen** driver:

     464     if (strncmp(di.udi_devnames[0], "ugen", 4) != 0)
     465       /* best not to play with things we don't understand */
     466       continue;
     
     
Fine libusb!  We will have to come up with another way to use this screen!  OR!  We could tell OpenBSD to use ugen when ever it sees the lcd! :D

To do that – you need the the OpenBSD source, knowledge of how to build Open’s kernel, and my patch!  Getting the source is beyond the scope of this little post.. so you will have to rtfm that action.

1. cd to the usb source directory: cd /usr/src/sys/dev/usb
2. Download the patch ( md5: 85e7498826635c612ede672f5e295e7a ): [picoLCD256x64.patch]( http://qbit.devio.us/picoLCD256x64.patch)
3. Apply said patch: patch -p1 < picoLCD256x64.patch
4. pkg_add libusb
5. Compile your kernel, install and reboot!
6. Once you are running your freshly compiled kernel, download the lcd4linux-256×64 source from http://picolcd.com/drivers/ .  Apply this patch ( md5: 3852103e3e5a13a3cd6b0c49389688f6 ): [lcd4linux-256×64.patch](http://qbit.devio.us/lcd4linux-256x64.patch), compile ( You will have to play around with the plugins as some of them use linux’s proc fs and are not compatible with OpenBSD ).

Now check out the sample config files and have fun!

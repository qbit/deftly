author: Aaron Bieber <aaron@bolddaemon.com>
title: Setting up networking on OpenBSD hosted VMs
description: Quick tutorial on networking OpenBSD VMs
tags: OpenBSD
date: Sat, 14 Nov 2015 12:00:00 MST

With OpenBSD getting a [native hypervisor](http://undeadly.org/cgi?action=article&sid=20151101223132), I figured I would quickly describe my setup for allowing the VMs to access network resources!

This setup is using NAT and IP forwarding.

First thing, enable forwarding:

    doas echo "net.inet.ip.forwarding=1" >> /etc/sysctl.conf 
    # Only run the above if you want this all to start at boot
    sysctl net.inet.ip.forwarding=1

Next we need to configure a [tap](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man4/tap.4?query=tap) interface at `tap0`.

`cat /etc/hostname.tap0`:

    inet 10.10.10.1 255.255.255.0
    up

Now tell `pf` what to do with the packets coming from the `tap0` interface:

    match out on $ext_if inet from tap0:network nat-to ($ext_if)

At this point, you could just manually assign ips to your VMs when booting / installing.

For a bit more automation, we can run `dhcpd` on the `tap0` interface:
`cat /etc/dhcpd.conf`

    option  domain-name "vm.bolddaemon";
    option  domain-name-servers 8.8.8.8, 8.8.4.4;

    subnet 10.10.10.0 netmask 255.255.255.0 {
    	option routers 10.10.10.1;
    	range 10.10.10.5 10.10.10.30;
    }

Pretty nifty, and all of it is in base (on amd64 and i386)!!

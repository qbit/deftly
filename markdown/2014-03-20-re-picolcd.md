author: Aaron Bieber <aaron@bolddaemon.com>
title: Revisiting the PicoLCD 256x64
description: Officially added the code to make picoLCD work!
tags: OpenBSD
date: Thu, 20 Mar 2014 12:00:00 MST

![OpenBSD Banner](/images/banner1.gif)

Today marks my first commits ([1](http://www.openbsd.org/cgi-bin/cvsweb/src/sys/dev/usb/usbdevs.diff?r1=1.626;r2=1.627;f=h), [2](http://www.openbsd.org/cgi-bin/cvsweb/src/sys/dev/usb/usbdevs.h.diff?r1=1.638;r2=1.639;f=h), [3](http://www.openbsd.org/cgi-bin/cvsweb/src/sys/dev/usb/usb_quirks.c.diff?r1=1.72;r2=1.73;f=h)) to the OpenBSD `src` tree (up until now it has all bee in `ports` and one in `www`)!

    add USB_PRODUCT_ITUNER_USBLCD256x64 as UQ_BAD_HID so libusb can talk via
    interrupt transfers

    OK sthen@

The last commit makes the PicoLCD 256x64 not attach as a `HID`, so that it can be used by applications that talk to usb devices with `libusb`!

The next step is to finish up the lcdproc driver for it - currently I can only turn on or of the backlight and +,- the contrast!

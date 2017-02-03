author: Aaron Bieber <aaron@bolddaemon.com>
title: Hey Kid, I'ma Interpreter!! Stop all the static interpreter referenci'n!
description: Please stop using '/bin/bash'!
tags: Scripting,OpenBSD
date: Mon, 17 Mar 2014 12:00:00 MST

If you have ever explicitly set the path of an interpreter at the top of a script.. This post is about you.

# STOP IT!

Not every system has binaries in the same location!

    #!/bin/bash

The above might *seem* awesome, and it might be tempting to use it, but if you do, and your project is something that I am interested in, you will receive a pull request ([here](https://github.com/JuliaLang/julia/pull/5493) are [some examples](https://github.com/nitrogen/nitrogen/pull/67)) to change it to:

    #!/usr/bin/env bash

On OpenBSD, bash is not in base, meaning it is not installed in `/bin` or even `/usr/bin`.  It gets plopped right into `/usr/local/bin`. Almost all users will have `/usr/local/bin` set in their `PATH` variable, so use the above and do not be a turdburgler!

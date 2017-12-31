author: Aaron Bieber <aaron@bolddaemon.com>
title: Passing off the Complexity
description: How I have settled into the pass ecosystem.
tags: OpenBSD,Passwords
date: Fri, 29 Dec 2017 08:00:00 MST

# The Password Dilemma

For quite some time I was a user of KeePass. Life was great I had a
client that worked on every platform (OpenBSD via `mono`, Android and
iOS via 3rd party apps). Every now and then I would manually copy the
file from my "main" machine to all the others.

After a while the syncing process became tedious. I attempted to find
things that would aid in the process.. Tools like `syncthing`,
`unison`, dropbox.. etc. They all had issues. With `syncthing` the
synchronizing was unreliable. Most of the time it couldn't find other
hosts on my network.. and when it finally did I would end up needing
to tell it how to resolve conflicts. Dropbox didn't have a native
client for OpenBSD - not to mention putting your password database
online is a terrifying proposition (my main issue with LastPass)!

Out of all the management methods I tried - LastPass was the most
"complete":

| Name | Syncing | Browser | OpenBSD | iOS/Android | My Trust |
| ---- | ---- | ---- | ---- | ---- | ---- |
| LastPass | ✓ | ✓ | ✓ | ✓ | ✗ |
| KeePass | ✗ | ✗ | ✓ | ✓ | ✓ |
| Password-Gorilla | ✗ | ✗ | ✓ | ✓ | ✓ |

# Enter pass

`pass` is touted as "the standard Unix password manager". It works
by keeping your passwords in individual PGP encrypted files. For
example, the entry `Web/google.com` would hold my "google.com"
password. An entry can contain more than just your passwords (I
have `username: ....` set on the 2nd line.), the first line
is always expected to be the password.

Out of the box, pass supports syncing via git, multiple recipients
(meaning it can encrypt a password file for multiple people),
random password generation and copying to clipboard with
auto-clear!

It doesn't, however, work out of the box on iOS/Android or my
browser. Fortunately for me - pass has a fantastic ecosystem
with a multitude of 3rd party browser extensions, iOS/Android apps.. best
all, they are open source! There are even full replacements for
pass itself! One such replacements is [gopass](https://github.com/justwatch/gopass).

`gopass` extends pass a bit further, it's written in Go,
seamlessly supports multiple "stores" (allowing me to have an
extra level of privledge separation for sensitive passwords),
is pledge()'d, AND can run on every OS I use!

For browsers, I have settled on [browserpass](https://github.com/dannyvankooten/browserpass). It's also written
in Go, pledge()'d, works on all my systems* (OpenBSD, Windows
macos), has auto-fill and easy to grok source code!

For iOS/Android there are [passforios](https://github.com/mssun/passforios) and [Android-Password-Store](https://github.com/zeapo/Android-Password-Store). All of which support
syncing via git!

Couple all this together and I get:

| Name | Syncing | Browser | OpenBSD | iOS/Android | My Trust |
| ---- | ---- | ---- | ---- | ---- | ---- |
| gopass/browserpass/mobile app | ✓ | ✓ | ✓ | ✓ | ✓ |

# A few hurdles

## Key management

PGP key management was an initial hurdle for me. Having to copy keys
from one computer to another put me back in the same situation I had
with KeePass.. syncing.

My solution to this problem is to store my PGP keys on a SmartCard
(Yubikey 4 in this case). This lets me "transfer" my PGP key between my
main computers without issue. It also has the added advantage of
giving me an ssh key I can use on less trusted machines!

For me, the Yubikey is ideal because of the form factor, however,
there are other alternatives such as NitroKey.

## Remote access

Because pass and friends sync by way of git, you must expose your git
repo to be able to use the sync mechanism. I didn't want to expose my
main repo to the world (even though it is only available via ssh), so
it is only accessible via my home network.

I have an ssh key per device, and use the `command=` option in
`~/.ssh/authorized_keys` to force git-only ssh access to less trusted
devices.

For example, my phone is less trusted than my OpenBSD laptop, so I
have an entry like this:

```
command="git-shell -c \"$SSH_ORIGINAL_COMMAND\"",no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty ssh-rsa ........ dumbdevice
```

This limits the device `dumbdevice` to only executing `git-shell`!

# Conclusion

All things considered, this setup takes a little bit to configure
initially (with keys and git repos.. etc), but its advantages
out weigh that hurdle for me:

1. It's very simple. No databases, no extra exposed services.. etc.
2. It uses existing tools to manage / sync my passwords. I trust ssh way
more than I trust a web server!
3. The ecosystem is very active.
4. If need be, I can operate entirely without the "pass" tools via
something like:
`gpg -d ~/.password-store/Web/google.com | head -n1 | xclip`

\* Currently there is a bug in Firefox on OpenBSD that prevents
native extensions from functioning.. I hope to get this fixed
soon! Chromium works fine, however.

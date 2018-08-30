author: Aaron Bieber <aaron@bolddaemon.com>
title: Test packages for Node on OpenBSD
description: Have your nodes and eat them too!
tags: OpenBSD,Node.js
date: Thu, 30 Aug 2018 08:00:00 MST

# Test builds for node

In an attempt to get a wider range of testing for `lang/node`, I have decided
to make test builds available here on [deftly.net](https://deftly.net/pub/OpenBSD).

If you want to test node, but don't want to build the package yourself, you
can simply run the following to upgrade your current install:

```
env PKG_PATH=https://deftly.net/pub/OpenBSD/snapshots/packages/$(machine) pkg_add -u node
```

All the packages pushed here will be signed via [signify(1)](https://man.openbsd.org/signify).

To make use of the signing, you will have to copy the below pub key to
`/etc/signify/abieber-pkg.pub`

```
untrusted comment: signify public key
RWRaFou/737fpovRq3OP3lZnz/97lbq2wYXFFk90nYUaW8xbc2HTd2xj
```

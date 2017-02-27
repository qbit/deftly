author: Aaron Bieber <aaron@bolddaemon.com>
title: SSH Fingerprint Verification via Tor
description: Using Tor to validate SSH fingerprints.
tags: SSH,Tor
date: Mon, 27 Feb 2017 09:30:00 MST

# The Problem

OpenSSH (really, are there any other implementations?) requires [Trust
on First Use](https://en.wikipedia.org/wiki/Trust_on_first_use) for
fingerprint verification.

Verification can be especially problematic when using remote services
like VPS or colocation.

How can you trust that the initial connection isn't being [Man In The
Middle'd](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)?

# My Solution

.. for remote hosts, is to use Tor as supplemental
verification. Fortunately OpenSSH makes this very easy as connections
can be proxied (`ProxyCommand`) via arbitrary commands (`socat` in
this case).

```
#!/bin/sh

# To make use of this, you need:
# - Tor installed / running
# - socat installed
# - Line 1 of your ~/.ssh/config should have: 'Include ~/.ssh/torify'

if [ $# -lt 1 ];then
        echo "Please specify hostname to check!"
        exit 1;
fi

TFILE=~/.ssh/torify
HOST=$1

CONF=$(cat <<'EOF'
Host *
        ProxyCommand socat STDIO SOCKS4A:localhost:%h:%p,socksport=9050
EOF
);

echo "$CONF" > "${TFILE}"
IP=$(tor-resolve "${HOST}")
for i in 1 2 3 4 5; do
        ssh "${IP}" & sleep 3; kill $!
done

echo "" > "${TFILE}"
ssh "$HOST" & sleep 3; kill $!
```
*Latest version of this script can be pulled from
[here](https://github.com/qbit/dotfiles/blob/master/bin/verify_ssh_fp)*

The above script makes five cut-short ssh connections (waiting 3
seconds before cutting the connection by killing the ssh pid) to an IP
address that is resolved using Tor. It then makes a single non-Tor'd
cut-short connection to print the fingerprint as seen from your
default outbound connection.

If all six of the output fingerprints match, it's a bit more safe to
assume that your connection to the remote host isn't being tampered
with!

Obviously, this solution isn't 100%. Your Tor connection could be
compromised.. Snakes could be on planes... etc. So use it at your own risk.
author: Aaron Bieber <aaron@bolddaemon.com>
title: OpenSSH - Configuring FIDO2 Resident Keys
description: Configuring a YubiKey for ssh resident keys
tags: OpenSSH YubiKey
date: Thu, 04 Jun 2020 16:43:38 MST

# Table of Contents

1.  [The Setup](#orgeb6aa34)
2.  [Creating keys](#org3b8793a)
    1.  [Generating the non-resident handle](#orgbc1a8c9)
    2.  [Generating the resident handle](#org05f4053)
3.  [Using the token](#org2df8b52)
    1.  [Resident](#org4f9e2ec)
        1.  [Transient usage with ssh-add](#orgd43612b)
        2.  [Permanent usage with ssh-agent](#org42b60c7)
    2.  [Non-resident](#org819b5f5)



<a id="orgeb6aa34"></a>

# The Setup

If you haven't heard, OpenSSH recently (<span class="timestamp-wrapper"><span class="timestamp">[2020-02-14 Fri]</span></span>) [gained support for
FIDO2/U2F hardware authenticators](https://www.openssh.com/txt/release-8.2) like the YubiKey 5!

This allows one to log into remote hosts with the touch of a button and it
makes me feel like I am living in the future!

Some of these hardware tokens even support multiple slots, allowing one to
have multiple keys!

On top of all that, the tokens can do "resident" and "non-resident"
keys. "Resident" means that the key is effectively retrievable from the
token (it doesn't actually get the key - it's a handle that lets one use the
hardware key on the device).

This got me thinking about how I could use a single token (with two keys) to
access the various machines I use.

In my use case, I have two types of machines I want to connect to:

-   **greater security:** machines I want to grant access to from a very select
    number of devices.

The `greater` key will require me to copy the "key handle" to the machines I
want to use it from.

-   **lesser security:** machines I want to access from devices that may not be as
    secure.

The `lesser` key will be "resident" to the YubiKey. This means it can be
downloaded from the YubiKey itself. Because of this, it should be trusted a
bit less.


<a id="org3b8793a"></a>

# Creating keys

When creating FIDO keys (really they are key handles) one needs to explicitly
tell the tool being used that it needs to pick the next slot. Otherwise
generating the second key will clobber the first!


<a id="orgbc1a8c9"></a>

## Generating the non-resident handle

`greater` will require me to send the `~/.ssh/ed25519_sk_greater` handle to the
various hosts I want to use it from.

We will be using `ssh-keygen` to create our resident key.

    ssh-keygen -t ed25519-sk -Oapplication=ssh:greater -f ~/.ssh/ed25519_sk_greater


<a id="org05f4053"></a>

## Generating the resident handle

Because resident keys allow for the handle to be downloaded from the token,
I have changed the PIN on my token. The PIN is the only defense against a
stolen key. **Note**: the PIN can be a full passphrase!

Again via `ssh-keygen`.

    ssh-keygen -t ed25519-sk -Oresident -Oapplication=ssh:lesser -f ~/.ssh/ed25519_sk_lesser


<a id="org2df8b52"></a>

# Using the token


<a id="org4f9e2ec"></a>

## Resident

The resident key can be used by adding it to `ssh-agent` or by downloading
the handle / public key using `ssh-keygen`:


<a id="orgd43612b"></a>

### Transient usage with ssh-add

    ssh-add -K

This will prompt for the PIN (which should be set as it's the only defense
against a stolen key!)

No handle files will be placed on the machine you run this on. Handy for
machines you want to ssh from but don't fully trust.


<a id="org42b60c7"></a>

### Permanent usage with ssh-agent

    ssh-keygen -K

This will also prompt for the PIN, however, it will create the private key
handle and corresponding public key and place them in `$CWD`.


<a id="org819b5f5"></a>

## Non-resident

The non-resident key will only work from hosts that have the handle (in our case
`~/.ssh/ed25519_sk_greater`). As such, the handle must be copied to the machines
you want to allow access from.

Once the handle is in place, you can specify it's usage in `~/.ssh/config`:

    Host secretsauce
        IdentityFile ~/.ssh/ed25519_sk_greater


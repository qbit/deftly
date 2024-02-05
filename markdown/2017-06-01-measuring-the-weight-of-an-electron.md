author: Aaron Bieber <aaron@bolddaemon.com>
title: Measuring the weight of an electron
description: Electrons are small, should be easy. Right?!
tags: OpenBSD,Electron,Software
date: Thu, 01 Jun 2017 07:18:00 MST

I am going to "**Measure the weight of an electron**"! By "weight", I
mean what it takes to make
[Electron](https://github.com/electron/electron) work on OpenBSD.

*This is a long rant. A rant intended to document lunacy,
 hopefully aid others in the future and make myself feel better about
 something I think is crazy. It may seem like I am making an enemy of electron,
 but keep in mind that isn't my intention! The enemy here, is complexity!*


My friend Henry, a canary, is coming along for the ride!

# Getting the tools

At first glance Electron seems like a pretty solid app, it has decent
[docs](https://github.com/electron/electron/tree/master/docs), it's
consolidated in a single repository, has a lot of
[visibility](https://github.com/electron/electron/stargazers), porting
it shouldn't be a big deal, right?

First things first, clone that repo!

```
git clone git@github.com:electron/electron.git
```

If you want to follow along, we will be using the [build instructions
for
linux](https://github.com/electron/electron/blob/master/docs/development/build-instructions-linux.md)
doc.

Reading through the doc, right off the bat there are a few interesting
things:

* At least 25GB disk space

Huh, OK, some how this ~47M repository is going to blow up to 25G? ***I
glance at Henry, he gives me the "what?" look. We carry on.***

* Clang 3.4 or later.

This one isn't odd until we have more context. *More on this one later.*

Continuing along with the build, I know I have two versions of `clang`
installed on OpenBSD, one from ports and one in base. Hopefully I will
be able to tell the build to use one of these versions.

Indeed Electron has that
[ability](https://github.com/electron/electron/blob/master/docs/development/build-instructions-linux.md#using-system-clang-instead-of-downloaded-clang-binaries)!
Their example is even using the same prefix OpenBSD's clang port!

**So, we run the bootstrap:**

```
./script/bootstrap.py -v --clang_dir /usr/local
Traceback (most recent call last):
  File "./script/bootstrap.py", line 10, in <module>
    from lib.config import BASE_URL, PLATFORM,  enable_verbose_mode, \
  File "/home/qbit/dev/electron_wut/script/lib/config.py", line 17, in <module>
    }[sys.platform]
KeyError: 'openbsd6'
```

Dang. Looks like we need to tell bootstrap about OpenBSD. Easy enough:

```
diff --git a/script/lib/config.py b/script/lib/config.py
index 58f467b5b..646af08f7 100644
--- a/script/lib/config.py
+++ b/script/lib/config.py
@@ -14,6 +14,7 @@ PLATFORM = {
   'darwin': 'darwin',
   'linux2': 'linux',
   'win32': 'win32',
+  'openbsd6': 'openbsd',
 }[sys.platform]

 verbose_mode = False
 ```
We re-run the bootstrap, things seem to be going well.. ***Then the
 Henry squeaks: "whoa!!"***:

```
Synchronizing submodule url for 'vendor/requests'
git submodule update --init --recursive
Cloning into '/home/qbit/dev/electron_wut/vendor/boto'...
error: object c1eddff4ee3f62b6039f1083651b9118883e7f07: badTimezone: invalid author/committer line - bad time zone
fatal: Error in object
fatal: index-pack failed
fatal: clone of 'https://github.com/boto/boto.git' into submodule path '/home/qbit/dev/electron_wut/vendor/boto' failed
Failed to clone 'vendor/boto'. Retry scheduled
Cloning into '/home/qbit/dev/electron_wut/vendor/breakpad'...

```

We just failed to clone the `boto` repo, but the build is still
going.. does this mean it was an optional dependency and isn't needed
for the build?

***Henry doesn't look happy, none the less, he assures me it's OK to go
 on. What a trooper!***

```
Cloning into '/home/qbit/dev/electron_wut/vendor/requests'...
error: object 5e6ecdad9f69b1ff789a17733b8edc6fd7091bd8: badTimezone: invalid author/committer line - bad time zone
fatal: Error in object
fatal: index-pack failed
fatal: clone of 'https://github.com/kennethreitz/requests' into submodule path '/home/qbit/dev/electron_wut/vendor/requests' failed
Failed to clone 'vendor/requests'. Retry scheduled
Cloning into '/home/qbit/dev/electron_wut/vendor/boto'...
error: object c1eddff4ee3f62b6039f1083651b9118883e7f07: badTimezone: invalid author/committer line - bad time zone
fatal: Error in object
fatal: index-pack failed
fatal: clone of 'https://github.com/boto/boto.git' into submodule path '/home/qbit/dev/electron_wut/vendor/boto' failed
Failed to clone 'vendor/boto' a second time, aborting
```
Wait. Another repository failed to clone? At least this time the build
failed after trying to clone `boto`.. again. I am guessing it tried
twice because something might have changed between now and the last
clone? ***Off in the distance we catch a familiar tune, it almost sounds
like Gnarls Barkley's song Crazy, can't tell for sure.***

As it turns out, if you are using
[git-fsck](https://git-scm.com/docs/git-fsck), you are unable to
clone [boto](https://github.com/boto/boto/issues/3507) and
[requests](https://github.com/requests/requests/issues/3805). Obviously
the proper fix for his is to not care about the validity of the git
objects!

So we die a little inside and comment out `fsckobjects` in our
`~/.gitconfig`.

***I look at Henry, he assures me it's safe to go on.***

We re-run bootstrap... thousands of lines fly past.. "`npm
verb... something something`". I can only think npm is puking this
info for it's on benefit. It definitely isn't for ours!

Bah, another error:

```
subprocess.CalledProcessError: Command '['/usr/local/bin/python', '/home/qbit/dev/electron_wut/vendor/libchromiumcontent/script/download', '-s', '-f', '-c', '94c58176db175d72d88621afe8223b4175eecba5', '--target_arch', 'x64', 'https://s3.amazonaws.com/github-janky-artifacts/libchromiumcontent', '/home/qbit/dev/electron_wut/vendor/download/libchromiumcontent']' returned non-zero exit status 1
```

Looks like it's trying to download a pre-built `libchromiumcontent`,
we reference the doc again, finding the `--build_libchromiumcontent`
option. Re-run!

This time we are faced with `.`'s, I have no idea what is happening:

```
/usr/local/bin/python /home/qbit/dev/electron_wut/vendor/libchromiumcontent/script/update -t x64 --defines  make_clang_dir=/usr/local clang_use_chrome_plugins=0
.......
```

Looking in `top`, we can see a python process with a WAIT of `netio`,
maybe it's downloading something? Looking in the `electron_wut`
directory reveals a growing file named
`chromium-58.0.3029.110.tar.xz`. We let it finish downloading.

Out of curiosity we look at `vendor/libchromiumcontent/script/update`,
it seems its purpose is to download / extract chromium clang and node,
good thing we already specified `--clang_dir` or it might try to build
clang again!

544 dots and 45 minutes later, we have an error! The
`chromium-58.0.3029.110.tar.xz` file is mysteriously not there
anymore.. Interesting.

Scrolling up in the terminal points us to something disheartening:

```
Extracting...
Updating Clang to 296320-1...
Creating directory /home/qbit/dev/electron_wut/vendor/libchromiumcontent/src/third_party/llvm-build
Traceback (most recent call last):
File "/home/qbit/dev/electron_wut/vendor/libchromiumcontent/src/tools/clang/scripts/update.py", line 902, in <module>
    sys.exit(main())
    File "/home/qbit/dev/electron_wut/vendor/libchromiumcontent/src/tools/clang/scripts/update.py", line 898, in main return UpdateClang(args)
    File "/home/qbit/dev/electron_wut/vendor/libchromiumcontent/src/tools/clang/scripts/update.py", line 420, in UpdateClangi assert sys.platform.startswith('linux')
AssertionError
None
```

Wut. "**Updating Clang...**". Didn't I explicitly say ***not*** to
build clang?

At this point we have to shift projects, no longer are we working on
Electron.. It's `libchromiumcontent` that needs our attention.

# Fixing sub-tools

```
git clone git@github.com:electron/libchromiumcontent.git
```

Following the
[instructions](https://github.com/electron/libchromiumcontent) on this
repo, we run `script/bootstrap`.. it seems to complete without issue!

On to the next steps:

```
script/update -t x64
```

Ahh, our old friends the dots! This is the second time waiting 45+
minutes for a 500+ MB file to download. We are fairly confident it
will fail, delete the file out from under itself and hinder the
process even further, so we add an explicit exit to the `update`
script. This way we can copy the file somewhere safe!

```
diff --git a/script/update b/script/update
index 234e4b3..b2639bf 100755
--- a/script/update
+++ b/script/update
@@ -107,6 +107,7 @@ def download_source_tarball(version):
         sys.stderr.flush()
         t.write(chunk)

+  sys.exit()
   sys.stderr.write('\nExtracting...\n')
   sys.stderr.flush()
```

544 dots and 43 minutes later.... `chromium-58.0.3029.110.tar.xz` is
safe!

Fool me once...

```
mkdir safe_space
cp chromium-58.0.3029.110.tar.xz safe_space/
```

We remove the `sys.exit()` and re-run! Wut.. dots again!? Lets look
deeper into this `update` script:

```
if not args.no_download:
  version = chromium_version()
  if not is_source_tarball_updated(version):
    download_source_tarball(version)
else:
  print "Skipping Chromium Source Tarball Download"

```
Ok, lets try that.. We copy the tar.xz out of its safe_space...

```
Skipping Chromium Source Tarball Download
Traceback (most recent call last):
  File "/home/qbit/dev/libchromiumcontent/vendor/python-patch/patch.py", line 1136, in <module>
    patch.apply(options.strip, root=options.directory) or sys.exit(-1)
  File "/home/qbit/dev/libchromiumcontent/vendor/python-patch/patch.py", line 778, in apply
    os.chdir(root)
OSError: [Errno 2] No such file or directory: '/home/qbit/dev/libchromiumcontent/src/.'
```

Sigh. The above (or similar) was repeated about 50 times... The trend
here seems to be: **Ignore errors! They are stupid and meaningless
anyway!**

Since `def download_source_tarball` should actually be `def
download_source_tarball_then_extract`, we do that part for
it... and pat ourselves on the back for having a `safe_space`!

***As chromium extracts, Henry and I can't shake the feeling that
 everything until now was just the tip of the iceberg***

We remove the call to `update_clang`, because.. well.. we have two
copies of it already and the Electron doc said everything would be fine
if we had >= clang 3.4!

Re-run..

```
already patched  third_party/WebKit/Source/core/paint/ThemePainterMac.mm
already patched  third_party/WebKit/Source/platform/mac/KillRingMac.mm
qbit@slip[1]:libchromiumcontent[master *%=]λ
```

That `[1]` in my PS1 means that the update script exited with the
return code `1`... but there is no indication of why..

***Henry's lovely yellow plumage seems to be becoming a darker shade of
 yellow.. How much more of this can we take?!***

If we have learned anything so far, it has to be "errors don't matter!".
This one, however, warrants further investigation!

**We dig deeper into script/update**

`update_gn()`.. pulls down a binary `gn`.. which, interestingly, can
be generated with the code we have right below our feet... but for
some reason, they have this component already built. There is no
pre-built version for OpenBSD.

At this point, Henry and I are getting pretty irritated.. it's time to
bring in some big guns! We are going to leverage the countless hours
of work that have already been put into properly building these
components! (novel, right?!)

We quickly move to `/usr/ports/www/chromium`, low and behold, it's the
*exact* version that `libchromiumcontent` is trying to build! We
review the `Makefile` to find this gem: `2. bootstrap gn, the tool to
generate ninja files`

Running `make configure` quickly gets us a usable `gn` binary, we make
the appropriate directories under src/buildtools, copy `gn` in, modify
our `script/update` file:

```
diff --git a/script/update b/script/update
index 234e4b3..b5c4afc 100755
--- a/script/update
+++ b/script/update
@@ -52,9 +52,9 @@ def main():

   return (apply_patches() or
           copy_chromiumcontent_files() or
-          update_clang() or
-          update_gn() or
-          update_node() or
+          #update_clang() or
+          #update_gn() or
+          #update_node() or
           run_gn(target_arch, args.defines))


@@ -248,6 +248,8 @@ def run_gn(target_arch, defines):
     gn = os.path.join(SRC_DIR, 'buildtools', 'linux64', 'gn')
   elif sys.platform == 'darwin':
     gn = os.path.join(SRC_DIR, 'buildtools', 'mac', 'gn')
+  elif sys.platform == 'openbsd6':
+    gn = os.path.join(SRC_DIR, 'buildtools', 'openbsd', 'gn')

   env = os.environ.copy()
   if sys.platform in ['win32', 'cygwin']:
```

Re-run!

```
ERROR at //build/config/sysroot.gni:95:5: Assertion failed.
    assert(
    ^-----
Missing sysroot (//build/linux/debian_wheezy_amd64-sysroot). To fix, run: build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
See //build/config/sysroot.gni:96:9:
        exec_script("//build/dir_exists.py",
        ^-----------------------------------
```

Wheezy?! Where is that getting set?! ***We stop and ponder.. how the
hell did we get here? What could have possibly warranted abandoning
makefiles and shell scripts in favor of this monstrosity!?***

Just for fun..  lets try to run the second step (after all, the first
step only produced a `1`, right!?)

```
script/build -t x64
```

FML:

```
qbit@slip[1]:libchromiumcontent[master *%=]λ script/build -t x64
Unsupported OS OpenBSD
No prebuilt ninja binary was found for this system.
Try building your own binary by doing:
  cd ~
  git clone https://github.com/martine/ninja.git -b v1.7.2
  cd ninja && ./configure.py --bootstrap
Then add ~/ninja/ to your PATH.
Traceback (most recent call last):
  File "script/build", line 57, in <module>
    sys.exit(main())
  File "script/build", line 43, in main
    subprocess.check_call([NINJA, '-C', os.path.relpath(out_dir), target], env=env)
  File "/usr/local/lib/python2.7/subprocess.py", line 186, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/home/qbit/dev/libchromiumcontent/vendor/depot_tools/ninja', '-C', 'src/out-x64/static_library', 'chromiumcontent:chromiumcontent']' returned non-zero exit status 1
qbit@slip[1]:libchromiumcontent[master *%=]λ which ninja
/usr/local/bin/ninja
qbit@slip[0]:libchromiumcontent[master *%=]λ
```

Clearly we are dealing with a beast that is too smart for its own
good.

# Fixing sub-sub-tools

Since `depot_tools` is a Google project, it's easier to edit the files
in the `vendor` directory and pretend nothing ever happened.

```
diff --git a/ninja b/ninja
index 282cc276..e22cbb9a 100755
--- a/ninja
+++ b/ninja
@@ -37,7 +37,5 @@ case "$OS" in
   Darwin)    exec "${THIS_DIR}/ninja-mac" "$@";;
   CYGWIN*)   exec cmd.exe /c $(cygpath -t windows $0).exe "$@";;
   MINGW*)    cmd.exe //c $0.exe "$@";;
-  *)         echo "Unsupported OS ${OS}"
-             print_help
-             exit 1;;
+  *)         exec "/usr/local/bin/ninja" "$@";;
 esac
```

Sigh. So many assumptions, lets continue the trend!

```
cd ../../
```

Re-run `script/build -t x64`...

No luck. At this point we are faced with a complex web of python
scripts that execute `gn` on GN files to produce ninja files... which
then build the various components and somewhere in that cluster,
something doesn't know about OpenBSD...

***I look at Henry, he is looking a photo of his wife and kids. They
   are sitting on a telephone wire, the morning sun illuminating their
   beautiful faces. Henry looks back at me and says "It's not worth
   it."***

***We slam the laptop shut and go outside.***

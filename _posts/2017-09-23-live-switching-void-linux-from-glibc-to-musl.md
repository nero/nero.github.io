---
layout: post
title:  Live switching Void Linux from glibc to musl
---

**Update: I haven't been using void for over 3 years now, i dont know if this post is still accurate. Check out [this post](https://www.ch1p.io/void-linux-musl-glibc/) from 2021**.

## Background

glibc is used as standard C library on most bigger Linux distributions.
Alternatives exist, like dietlibc and musl.
Void Linux is offered in two variants, one with the standard glibc and one with the alternative musl libc. 

Until today i was using the glibc variant.
A notable difference between my system and stock void linux is that i manage my /boot myself, therefore i use `base-voidstrap` instead of `base-system`.

THIS MEANS THIS WILL LIKELY WORK DIFFERENTLY ON YOUR MACHINE.

## Creating musl rootdir

I created a chrootable musl rootdir at `/musl` using the following command:

`XBPS_ARCH=$(uname -m)-musl xbps-install --repository=https://repo.voidlinux.eu/current/musl -r /musl -S base-voidstrap`

I bind-mounted `/var/cache/xbps` to `/musl/var/cache/xbps` to reuse the host systems package cache.
This only has effect for noarch-packages, you'll still need to download all the musl-specific packages.

## First test

Research showed that almost all architecture-specific data resides in `/usr`.
Seach for 'lennart poettering vendor tree' in the search engine of your choice to see why.
To estimate breakage, i modified my `/etc/runit/core-services/03-filesystems.sh` to bind mount `/musl/usr` over `/usr`.

The system survived the reboot, most breakage was caused by packages missing from /musl.
I manally bind mounted `/musl/var/db/xbps` over `/var/db/xbps` to let xbps use the package state of `/musl` and added packages required for graphical stuff and wifi.

Then it worked.

One of the maintainers told me to check for files in `/etc` that only exist on musl.
I did not find things that might cause trouble.

I undid the bind mounts and used glibc as usual for a while without noticable breakage.

## Final replacement

When i felt like it was time to do the actual switch, i installed `busybox-static`, su'ed to `root` and went to `/`.
Because there wont be a `mv` available after you removed `/usr`, i copied the static busybox binary with `cp /usr/bin/busybox.static /`.
The removal was done with `mv /usr /usr-old; /busybox mv /musl/usr /usr`.
Likewise did i remove `/var/db/xbps` and replace it with its musl counterpart.
You need to do this BEFORE invoking xbps-install or you will confuse xbps about your current system state.
I removed `/musl` after this step.

## Disappointment

I was using an x86_64 host with multilib.
Musl Void does not have an i686 architecture and therefore no multilib.
This left me unable to play my beloved 32bit wine games.

### Program to the rescue

I recreated a glibc rootdir on `/glibc`, chrooted there and installed my multilib and wine stuff.
I wrote the following program to create a new mount namespace and move the glibc facilities over `/usr` and `/var/db/xbps`:

```
#define _GNU_SOURCE

#include <stdio.h>
#include <sched.h>
#include <sys/mount.h>
#include <unistd.h>

#define e(n,f) if (-1 == (f)) {perror(n);return(1);}
#define SRC "/glibc"

int main(int argc, const char const *argv[]) {
	const char const *shell[] = { "/bin/sh", NULL };

	// move glibc stuff in place
	e("unshare",unshare(CLONE_NEWNS));
	e("mount",mount(SRC "/usr", "/usr", NULL, MS_BIND, NULL));
	e("mount",mount(SRC "/var/db/xbps", "/var/db/xbps", NULL, MS_BIND, NULL));

	// drop the rights suid gave us
	e("setuid",setreuid(getuid(),getuid()));
	e("setgid",setregid(getgid(),getgid()));

	argv++;
	if (!argv[0]) argv = shell;
	e("execv",execvp(argv[0], argv));
}
```

Since the rest of the host rootdir is reused, all user id's and homedirs and even the current working directory can stay in-place.

I compiled the code with `gcc -o glibc main.c`.
To work properly, it requires to be owned by root (`sudo chown root:root glibc`).
Also suid is required (`sudo chmod +x glibc`).
For comfort it should be placed in a directory referenced by `$PATH`.

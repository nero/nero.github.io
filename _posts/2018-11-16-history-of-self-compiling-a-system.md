---
layout: post
title: History of me self-compiling a system
---

Without reason, all my own attempts of systematically building software were named tonic.
This name is reflected in repository names and figlet artworks in the motd.

This post is an recollection of different attempts of it.

## Autuum 2016 "Isotonic"

Sabotage Linux was my first entry into self-compiling a bootable system.
It started as grabbing binaries from sabotage, putting them into an cpio, and generate an bootable iso file in it.

Code of this iteration partially lives on as initramfs code in Sabotage Linux, which i maintained until early 2018.

## End 2016 "Futro"

Around this time, i rescued an Siemens Futro S300 Thin Client.
Because it is i586, which none of the distros at that time seemed to support, i modified the recipe for the i686 toolchain from void linux to generate an i586 toolchain.
Using that, i build a static busybox, packed it into an cpio, and built it directly into an kernel appropiate for the futro.

The code for this was reused for another project, to generate a single-binary boot image (kernel + initramfs) for one of my laptops.
While the original code was lost, the code from this remake is [still available](git://git.w1r3.net/nero/nyu.git).

## Mid 2017 "Makefile"

Makefile-based approach. Essentially, there was an top-level makefile, which had all the sources and build results as target.
Still depended on an pre-existing toolchain, but was able to cross-compile a tiny base system with busybox, both dynamically and statically.

I discovered the way of using user namespaces to create [unprivileged chroots]({% post_url 2018-01-13-containers-with-shell-and-unshare %}).
This iteration was the first one to properly make use of CPPFLAGS and LDFLAGS to compile against a different sysroot.

The code for this was lost.

## Mid 2017 "Submodules"

I improved the makefile approach by including the upstreams as git submodules.

I maintained this code until early 2018.
I used this several times as method of quickly generating a tiny rootfs from scratch.

The code is [still available](git://git.w1r3.net/nero/tonic-submodules.git).

## Late 2018 "Tesla"

After taking a look at Exherbo Linux, i got much into the idea of using `/usr/<host_touple>` as prefix.
This would have made cross-compiling much easier.

I wrote a [PoC](git://git.w1r3.net/nero/tesla.git), but [after researching]({% post_url 2018-10-01-sane-cross-compiling-environment %}), i felt like its just too much complexity, when sane cross-compiling could be achieved otherwise.

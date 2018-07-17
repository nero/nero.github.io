---
layout: post
title: "Automated provisioning using apkovl"
---

## How apkovl works

To make things easier at first, we will focus on Alpine Linux (AL from now on) diskless mode.
Diskless mode means that there will be no block device or disk image mounted as rootfs.
Instead, the initramfs will mount a tmpfs and bootstrap the rootfs, downloading the binaries from the alpine repo.
The AL boot media use this mechanism.
Using the ISOs from the download page provide a quick method to run a diskless system in qemu.

Because this creates a fresh AL install on every boot, AL has a local backup mechanism.
Alpine Local Backup collects files from /etc and optionally other places and creates a tarball from it.
The tarball can then be stored on some writable media or uploaded to an SSH server.
Per convention, the tarball has a `${HOSTNAME}.apkovl.tar.gz` filename format and is usually only called "apkovl".

To restore your system from an apkovl, the initramfs can be instructed to pre-seed the rootfs with the data contained in the apkovl.
This can be done by specifying `apkovl=` in the kernel command line.
The location can be given as http or ftp url, or directly as file path.
If no apkovl is specified, the initramfs will use `nlplug-findfs` to mount block devices and search them for available apkovl's.

The structure in the apkovl is identical to the actual location on the rootfs, `/etc/hostname` in the apkovl will extracted to `/etc/hostname` in the rootfs.
Thus it is possible to include files from other filesystem locations.

Since an apkovl is just a gzipped tarball, its trivial to generate it from scratch.
Because the apk package manager stores the list of manually installed packages in `/etc/apk/world`, its possible to define the packages to be installed from an apkovl.
Same goes with the repository list and trusted repository keys.

In essence, an apkovl can be used to specify the payload of a running system, as in a configured webserver or other applications.
Instead of having to edit configs on a running system, this allows to completely define a machine before actually having to execute it.
This is an huge advantage over two-step systems like ansible, which need to be triggered externally to bring the system into production state.

## Creating an apkovl from scratch

Because im a friend of Makefile-based build systems, i wrote a collection of Makefile snippets to generate the config files and apply the necessary transformations.

Its intended to be specific to my own infrastructure, i want to encourage my readers to invent mechanisms of their own.

### Secrets management

In theory its possible to pre-generate keypairs (like ssh server keys) and place credentials in the apkovl.
This taints the apkovl as sensitive data, transferring it over the network must be secured accordingly.

## Persistence

Until now, we were talking about diskless/RAM-based systems.
Using Alpine's `setup-disk` utility we can bootstrap an alpine rootfs from an apkovl.
As a result, we will have an conventional disk install (AL "sys mode") which can then host persistent data.
This might be the preferred setup for people who dont get RAM for free.

## One-shot execution

Alpines `/etc/init.d/local` mechanism allows to run scripts at the end of init.
This is useful to create an installer, which will in turn setup the local disk like mentioned in the previous section.

## Use case: Raspberry Pi

AL on the RPi has an quite different [setup procedure](https://wiki.alpinelinux.org/wiki/Raspberry_Pi#Preparation) than x86 systems.

The boot tarball for AL contains everything necessary to launch an diskless system.
There is even an default apkovl included.

Deploying an apkovl on a RPi is as easy as removing the default apkovl and placing the own in the same directory.
Because the initramfs searches for apkovl based on their *.apkovl.tar.gz extension, the exact name does not matter.

This is useful for an kiosk system, utilizing one of my excess monitors to display potentially useful information like public transport departure times.

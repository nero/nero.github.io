---
layout: post
title: "Valid reasons for not using systemd"
---

## Embedded Systems

Embedded systems have flash size constraints.
Systemd depends on dbus, journald and udev, which are several megabytes in size.
Busybox is a popular alternative here, which contains a bootable userspace (including init) in less space than Systemd's init code alone.
The cost difference is significant for mass production.

## Servers and containers

The size overhead affecting embedded systems also affects areas where size is limited due to scalability concerns.
No server needs udev or D-Bus, the necessary hotplug functionality can easily achieved by mounting devtmpfs.
I want to remind that D-Bus stands for "Desktop Bus".

Alpine Linux got much popularity for being a smaller alternative for Systemd-based Linux systems (especially in docker, hah!).
FreeBSD also showed to be popular, but i avoid that project due to [other reasons](/2018/05/22/how-i-choose-software.html).

## Non-GNU systems

Alternative libc's like Musl are not supported by Systemd.
Poettering considers musl a [non-useful libc](https://lists.freedesktop.org/archives/systemd-devel/2014-October/023869.html).
Despite that, embedded applicances (like Busybox or OpenWRT) and Alpine Linux (which all target the Musl libc) are in widespread use.

There haven't been any production-ready ports to BSD yet.

Void Linux dropped Systemd in 2015 to improve Musl support.

## High reliability platforms

Systemd still suffers from an amount of race-conditions, as the amount of [issues](https://github.com/systemd/systemd/issues?page=1&q=is%3Aissue+is%3Aopen+race) on github indicate.
Race conditions are a frequent cause for non-deterministic behavior of complex programs.

For medical or aviation appliances, using Systemd is a risk many companies dont want to take.

## Maintainer Trust

At last, there are People who dont want to trust their data to software whose maintainer considers `rm -rf /`'ing your systems not [much of a problem](https://github.com/systemd/systemd/issues/5644#issuecomment-290345033).
Maintainers should take responsible for [things they break](https://bugs.freedesktop.org/show_bug.cgi?id=76935), and not expect others to change their software to restore functionality.

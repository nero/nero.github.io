---
layout: post
title: "Getting CRDA to work on Alpine Linux"
---

CRDA is an user-space program to feed regulatory data into the linux kernel.
This data is used to restrict usage of wifi chips to frequencies allocated for such kind of use.

Per default, attempting to set the regulatory domain via `iw regdb set DE` results in no changes:

```
$ iw regdb get 
country 00: DFS-UNSET
	...
```

Installing `crda` and `wireless-regdb` provides the necessary helpers and databases to supply the regulatory information.
It also needs to be registered with the device node manager.
Depending on your system, this might be either `udev` or `mdev`.

To register it with `mdev`, add the following line to `/etc/mdev.conf`:

```
$COUNTRY=.. root:root 0660 */sbin/crda
```

This was discussed previously [on alpine-devel](http://lists.alpinelinux.org/alpine-devel/5092.html).

To register it with `udev`, create an udev rule as follows:

```
$ cat /etc/udev/rules.d/regdb.rules 
KERNEL=="regulatory*", ACTION=="change", SUBSYSTEM=="platform", RUN+="/sbin/crda"
```

Attemping to set the regulatory domain afterwards will trigger the device manager via hotplug mechanism, so no restart/reboot is necessary.

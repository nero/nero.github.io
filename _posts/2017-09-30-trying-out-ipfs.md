---
layout: post
title: First experiments with IPFS
---

## Installation

Im on Void Linux (musl).
The installation was done on two workstations (one headless) in parallel.

```
$ xbps-query -Rs go-ipfs
[*] go-ipfs-0.4.10_3 Global versioned P2P merkle DAG file system
$ sudo xbps-install -Sy go-ipfs
...
go-ipfs-0.4.10_3: installed successfully.
...
$ xbps-query -f go-ipfs
/usr/bin/ipfs
/usr/share/bash-completion/completions/ipfs
/usr/share/licenses/go-ipfs/LICENSE
/usr/share/doc/go-ipfs/README.md
/usr/share/doc/go-ipfs/CHANGELOG.md
```

## Setup

After reading some docs, i realized i need to have an IPFS daemon running.
I added a dedicated ipfs user via `useradd -d /var/ipfs ipfs`, created a
directory named `/etc/sv/ipfsd/`, and added the following contents to
`/etc/sv/ipfsd/run`:

```
#!/bin/sh
export IPFS_PATH=/var/ipfs
exec chpst -u ipfs ipfs daemon --init
```

Dont forget to make the runfile executable.
I permanently enabled the daemon with `ln -s /etc/sv/ipfsd /var/service/ipfsd`.

## In Action

With the daemon active, i went to the web, searched for the next ipfs hash 
available, and did a successful cat of that file.

I noticed that my "Network Activity" LED on my workstation did not stop 
flashing, so i checked the output of `lsof(8)` to see that ipfs had 
approximately 200 sockets in the `ESTABLISHED` state.
A quick check with `tcpdump(1)` confirmed those sockets were causing that 
traffic.

The data volume in idle seemed to be around 10kB/s, both up and down.
A calculation showed that this would yield around 51GB of traffic per month, 
while being idle.

My monthly data plan is 50GB. Currently im rarely using more than 30GB of it, 
but using IPFS (not just having it idle) would definitly exceed my data volume.

I cant use the "Interplanetary" FS on earth, due to my network resource 
constraints.
Which is ironic, because tight network resource constraints are why 
communication in space is that difficult in the first place.

[Here](https://github.com/ipfs/go-ipfs/issues/1482) is an issue related to its 
excessive resource usage:

>Although @jbenet suggests we can have this done on a higher level, a 
>long-running actively used IPFS daemon will currently eat all memory available 
>on a system which basically means that, without memory constraints it will not 
>be stable.

As of writing this, these issues are not solved.

## Summary

IPFS does not hold up to its name.

Crap software that sounds good in theory, but fails miserably in practice is an 
antipattern i've seen much lately.

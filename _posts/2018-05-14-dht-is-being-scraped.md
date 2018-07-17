---
layout: post
title: "The DHT is being scraped"
---

Some of my (non-announced) torrents leaked onto some shady torrent sites on the web.
The data wasn't sensitive (music), my primary bother is that my torrents became discoverable via web means.

The idea was to have an read-only storage of data shared across machines.
When adding new machines, i import the list of magnet urls and it will synchronize.
This abstracts the source of the files away, the data itself is defined by its hashes, which also ensures integrity.

I dont use trackers, my devices find each other via DHT and LDP.
LDP is local peer discovery via UDP broadcasts in the local network (they cant traverse routers).
The DHT is an global distributed hash tables, and its possible that other people scrape it.

Not just possible, actually, there is a whole bunch of websites that do scrape the DHT and list its contents.
And displaying some ads with asian girls, thats why i said "shady" in the first paragraph.

I discussed this in my hackspace, and as a result i put my eye on IPFS and DAT.
I tried IPFS previously, but was put off by its excessive bandwidth, memory and CPU usage.
[DAT](https://datproject.org/) is an distributed data "community" written in JS, so its probably as bad as IPFS.

Still evaluating.

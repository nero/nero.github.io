---
layout: post
title: "ModemManager Crap"
---

A while ago, i bought a Laptop with an integrated broadband modem.
I messed around with pppd and alpine on it, but i found messing with pppd cumbersome and tried using some more featured thing.
I heard of ModemManager, so i installed Ubuntu on that machine, which ship it per default.

Setting it up was less difficult, and the NetworkManager applet provide a GUI to switch it on and off.
Having to do that using the ThinkPad [nipple mouse](https://xkcd.com/243/) for that isn't too nice, tho.

That this Laptop is a mobile device now also means that i use it as terminal for serial console access or rom flashing.
And thats where the trouble begins.

ModemManager scans per default newly appearing tty devices.
Scanning means, `open()`'ing it and sending AT commands to it.
While it may be useful for Modems, it sort of breaks almost all non-Modem TTY devices.

For example, i have an 8-channel relay card for home control.
Plugging it into a machine running ModemManager causes it to turn channel 0 and 1 on.
Other popular case are AVR programmers or direct serial terminals like every router has.
Yes, in that case ModemManager is spewing garbage into the root shell of an embedded device.
[Here is the upstream bug](https://bugs.freedesktop.org/show_bug.cgi?id=85007).

Official solution is to blacklist every single device manually via udev rules.
That is done via the USB vendor and product id, which you find out .... by plugging it in.
As of Ubuntu 18.04, there is no method to switch it to whitelist behavior.

And of course, its a RedHat project.
I semi-expected the Maintainer to pull an "I dont consider this much of a Problem".
I rather fiddle around everything together manually with pppd instead of having to deal with those "features".

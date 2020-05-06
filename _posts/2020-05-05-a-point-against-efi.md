---
layout: post
title: "A point against EFI and GPT"
---

Im writing this post mostly because im annoyed by the EFI-Ethusiast crowd.

*tl;dr:* If your standards are high enough that you dont run Windows, you shouldnt run EFI either.

## GPT UUID endianness

While most of the worlds uuids are big-endian, Microsoft went another way.
Not even little endian, but both big and little endian in the same uuid, also called 'mixed endian'.

This causes an ambivalence how a binary uuid is represented in ascii characters.

For DMI and PXE uuids, this was never specified, so depending on the software reading those values, you might get one of two different values.
This broke the neck of most attempts of using these uuid's for identifying machines during PXE boot.

## File system

FAT is actually pretty portable, since its supported by many operating systems.

Except for its Bios Parameter Block, which, despite its name, is still used from EFI.
[Wikipedia](https://en.wikipedia.org/wiki/BIOS_parameter_block) lists 7 different version for the BPB.
Some of them are incompatible.
They dont have a field specifiying their version.
The later versions have signatures, but you cant rely on them, since earlier versions might have their boot code at the exact same place and might accidentally test positive because the signatures are only one byte long.
For FAT16 and FAT32, the signatures are at different locations, even.
There are other caveats like the subtle changing of the "Partition Offset" field between DOS 3.0 and 3.31.
Dont get me started on how filenames larger than the 8.3-names from DOS times are implemented.
Judging from that, FAT is mediocre design and not really reliable, mandating it for EFI was a grave mistake.

## Executables

EFI aplogists usually have the balls to call the BIOS-based boot "legacy".
This is already a bold move considering the legacy cruft that FAT is.

This goes on with the presense of the MZ DOS executable header that every PE executable has.
And EFI binaries are PE executables, by specification.
So if you do a hexdump on EFI binaries, you can see that they start with the magic number for 16-bit DOS binaries.
The 32bit/64bit code is hacked on top.

At least the EFI people went forward in time by omitting the 16-bit "This Program cannot be run in DOS Mode"-stub code and leaving that area of EFI binaries zeroed out.

## Windows-Specific

All three of the previous sections refer to some quirks that are specific to DOS and Windows.
By adding a "U" for "Universal" infront of its name, EFI people tried to make it look like EFI is not a bootloader designed by Microsoft for booting Windows.
In my opinion, this is a highly deceptive move.

## Statefulness

With EFI, its now standard to write OS-specific information to the CMOS.
The Firmware has now even more state that can possibly be disrupted.
This enables `rm -rf` to not only wipe your system, but also [permanently brick your hardware](https://lwn.net/Articles/674940/).

## Reliability

Despite all the changes and "improvements" over the last years, the Hardware is not much more reliable than 20 years ago.
Insteads of messing with the whacky bootsectors, people now mess around with the whacky efi boot vars.
Support for graphics card during early boot was mediocre to catastrophic, since many EFI option roms didnt really work.
I have yet to observe a reliable PXE boot for EFI.

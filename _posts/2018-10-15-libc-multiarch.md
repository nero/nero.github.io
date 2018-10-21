---
layout: post
title: Multiarch support with dynamic linking
---

Previously, i was exploring how to have the equivalent of different root file systems under the same `/`.

To enable binaries from other systems to run in your system, you need to register the paths of their libaries in your host system.

Take note that libraries of different architectures or different libcs are not binary compatible and cannot be loaded by the same process.

## Musl libc

The `INSTALL` file from the musl source tree explains the behavior on dynamic linking.
The default path for the dynamic linker is `/lib/ld-musl-$ARCH.so.1`, with `$ARCH` including the subarchitecture for endianess or hard float.
The list of library directories can be specified in `/etc/ld-musl-$ARCH.path`, separated by colons or newlines.

## Glibc

The procedure for glibc is explained in `ldso(8)` and `ldconfig(8)`.
The paths for the libraries are specified in `/etc/ld.so.conf` for *all* architectures, then running `ldconfig` collects the library data in 
`/etc/ld.so.cache`, including architecture information. `ldconfig` is part of glibc distributions and statically linked, it also works for 
cross-architectures.

## Caveats

While it works fine for most simple applications, there are edge cases that blow up horribly:

- Some other programs like `lddtree` or `scanelf` are reading the glibc-specific files even on musl systems.
  This breaks the initramfs generation for Alpine Linux. I submitted a patch to lddtree there.
- Interpreted Languages like Perl have files in /lib, where they try to access them by absolute path.
  Simply does not work in this constellation.
- Global data in /usr, including fonts

To troubleshoot issues, one can run `ldd` or `lddtree` on binaries that fail to load their shared libraries.

There is much more on this topic, so own research will be useful to the readers.

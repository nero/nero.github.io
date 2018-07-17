---
layout: post
title: "Debugging ld: cannot find -lglib-2.0"
---

Today i tried to compile a statically linked irssi on sabotage linux.

`./configure ...` failed with the following:

```
checking for GLIB - version >= 2.28.0... no
*** Could not run GLIB test program, checking why...
*** The test program failed to compile or link. See the file config.log for the
*** exact error that occurred. This usually means GLIB is incorrectly installed.
*** trying without -lgmodule
```

Further research showed, that glib was indeed present:

```
$ ls /lib/libglib*
/lib/libglib-2.0.la           /lib/libglib-2.0.so.0
/lib/libglib-2.0.so           /lib/libglib-2.0.so.0.5400.2
```

`config.log` for irssi revealed:

```
configure:13485: gcc -o conftest -D_GNU_SOURCE -fdata-sections -ffunction-sections -Os -g0 -fno-unwind-tables -fno-asynchronous-unwind-tables -Wa,--noexecstack -mtune=generic -Wall -I/include/glib-2.0 -I/lib/glib-2.0/include -I/include    -s -Wl,--gc-sections -Wl,-z,relro,-z,now -Wl,-rpath-link=/lib -lcurses -lterminfo -static --static conftest.c  -L/lib -lglib-2.0
/bin/ld: cannot find -lglib-2.0
collect2: error: ld returned 1 exit status
configure:13485: $? = 1
configure: failed program was:
| /* confdefs.h */
| #define PACKAGE_NAME "irssi"
| #define PACKAGE_TARNAME "irssi"
| #define PACKAGE_VERSION "1.0.5"
| #define PACKAGE_STRING "irssi 1.0.5"
| #define PACKAGE_BUGREPORT ""
| #define PACKAGE_URL ""
| #define STDC_HEADERS 1
| #define HAVE_SYS_TYPES_H 1
| #define HAVE_SYS_STAT_H 1
| #define HAVE_STDLIB_H 1
| #define HAVE_STRING_H 1
| #define HAVE_MEMORY_H 1
| #define HAVE_STRINGS_H 1
| #define HAVE_INTTYPES_H 1
| #define HAVE_STDINT_H 1
| #define HAVE_UNISTD_H 1
| #define HAVE_DLFCN_H 1
| #define LT_OBJDIR ".libs/"
| #define HAVE_UNISTD_H 1
| #define HAVE_DIRENT_H 1
| #define HAVE_SYS_IOCTL_H 1
| #define HAVE_SYS_RESOURCE_H 1
| #define HAVE_SYS_SOCKET_H 1
| #define HAVE_SYS_TIME_H 1
| #define HAVE_SYS_UTSNAME_H 1
| #define SIZEOF_INT 4
| #define SIZEOF_LONG 8
| #define SIZEOF_LONG_LONG 8
| #define SIZEOF_OFF_T 8
| #define PRIuUOFF_T "lu"
| #define UOFF_T_LONG 1
| /* end confdefs.h.  */
|
| #include <glib.h>
| #include <stdio.h>
|
| int
| main ()
| {
|  return ((glib_major_version) || (glib_minor_version) || (glib_micro_version));
|   ;
|   return 0;
| }
configure:13546: error: GLIB is required to build irssi.
```

I extracted the echo'ed c program and ran the gcc command again and was able to reproduce the problem outside of the autoconf process.

Adding `-Wl,--verbose` to the gcc invocation caused the linker to be more verbose, which revealed:

```
attempt to open /lib/libglib-2.0.a failed
attempt to open /opt/gcc630/bin/../lib/gcc/x86_64-unknown-linux-musl/6.3.0/libglib-2.0.a failed
attempt to open /opt/gcc630/bin/../lib/gcc/libglib-2.0.a failed
attempt to open /opt/gcc630/bin/../lib/gcc/x86_64-unknown-linux-musl/6.3.0/../../../../x86_64-unknown-linux-musl/lib/libglib-2.0.a failed
attempt to open /opt/gcc630/bin/../lib/gcc/x86_64-unknown-linux-musl/6.3.0/../../../libglib-2.0.a failed
attempt to open /x86_64-unknown-linux-gnu/lib64/libglib-2.0.a failed
attempt to open /usr/local/lib64/libglib-2.0.a failed
attempt to open /lib64/libglib-2.0.a failed
attempt to open /usr/lib64/libglib-2.0.a failed
attempt to open /x86_64-unknown-linux-gnu/lib/libglib-2.0.a failed
attempt to open /usr/local/lib/libglib-2.0.a failed
attempt to open /lib/libglib-2.0.a failed
attempt to open /usr/lib/libglib-2.0.a failed
```

The right path would probably be `/lib/libglib-2.0.a`, because that where the libraries are on sabotage linux.
GLib was compiled for dynamic linking and therefore did not include the *.a library files required for static linking.

The fix was to compile glib with `./configure --enable-static`, which also produced a *.a lib then:

```
$ ls /lib/libglib*
/lib/libglib-2.0.a            /lib/libglib-2.0.so.0
/lib/libglib-2.0.la           /lib/libglib-2.0.so.0.5400.2
/lib/libglib-2.0.so
```

---
layout: post
title: A sane cross-compiling environment
---

I recently had experimented with exherbo.
I was not pleased with some things i saw there, including some sort of bugs that don't give me confidence about the codes correctness.
Some thing i really liked was how the architecture-specific files are structured.

Stuff like `/bin`, `/lib` and so on are symlinks to `/usr/host`, which itself is a symlink to user `/usr/$touple`.
The touple is a short descriptor for the binary architecture.
It looks something like `x86_64-linux-musl` and describes the CPU/ISA type, the kernel (essentially always "linux") and the libc used.

This is rather useful for cross-compiling without requiring the use of chroot or comparable engines (like docker).
Such engines have several disadvantages:

- Different uid/gid scope because of different `passwd` and `group` file.
  This breaks shared directories (`volumes` in docker slang).
  One can fix this with bind mounts, but this overwrites previous entries on the guest side.
- `resolv.conf` requires special handling - sometimes a bind mount suffices, but when its actually a symlink into `/run` or you switch networks often it becomes a painful trouble
- `binfmt_misc` works on absolute paths that are specific to the current root.
  The user needs to make sure the qemu binaries are in the same path inside as well as outside of the chroot.
  Because the hardcoded global paths for the dynamic linker now also pointing to a different directory, one must use a statically linked qemu inside of the chroot.

By putting the architecture-dependent files into separate directories, we can share the whole system between the different architectures.
This means that there will be a single global `passwd` files, the `resolv.conf` integration will work natively, and `binfmt_misc` can link to dynamically linked qemu binaries.

To keep the dynamic linking working in this situation, there are two approaches:

- Hardcode the dynamic linker path to `/usr/$touple/lib/...` at compile-time.
  This requires compiling everything from scratch, but doesn't require support files outside of `/usr/$touple/`.
  This breaks binary compatibility with the rest of the linux world.
  Rich Felker (Author of musl libc) discouraged me from doing this.
  Something about standards and reinventing stuff.
  Nix is based on this.
- Setup symlinks for the dynamic linker in `/lib` to their respective binaries in `/usr/$touple/`.
  Less intrusive, but does require to setup support for each architecture globally, and dynamic linker paths for different architectures might conflict.
- When using `binfmt_misc` with qemu, qemu has option to override the path for the dynamic linker.
  This way, the interpreter can be specified when setting up `binfmt_misc` and no setup in `/lib` is necessary.

Because the dynamic linker will per default search libraries in the global `/lib` and `/usr/lib`, there is additional configuration necessary:

- Hardcoding the `RPATH` value at compile time.
  This breaks binary compatibility with the rest of the linux world.
  Nix does this.
- Global configuration in `/etc`.
  Both glibc and musl support this.
  This had the advantage of being able to natively use libraries from a mounted system root.

At first, i tried the 'hardcode everything' approach and built some shell scripts to calculate the appropiate compiler and configure flags.
I really liked that approach, but having to recreate and maintain package build recipes is a big amount of work.
The results of this are archived in [tesla.git](/projects.html#tesla).

With the newly gained knowledge, i found that there aren't much special effects necessary to get an cross-architecture binary with shared libraries running under the same root.
I dropped the idea of an special filesystem structure.

I'll outline the steps to make this work in a followup post.

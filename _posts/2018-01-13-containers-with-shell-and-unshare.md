---
layout: post
title:  Linux Containers with shell and unshare(1)
---

This requires the `CONFIG_USER_NS` enabled in the kernel.
You can check this with `grep USER_NS /boot/config*`.
You should see a `CONFIG_USER_NS=y`.

Arch Linux in particular has the unprivileged user namespace patched away, so this wont work on Arch.

Alpine Linux is using busybox 1.27.2, which still ships a broken `unshare`.
So this wont work on Alpine Linux either.

Known to work are Ubuntu 17.10 and Void Linux.

## Create a chroot directory

Create it with `mkdir` and run the following commands from inside the directory:

```
mkdir bin
arch=$(uname -m)
wget -O bin/busybox https://busybox.net/downloads/binaries/1.26.2-defconfig-multiarch/busybox-$arch
chmod +x bin/busybox
ln -s busybox bin/sh
```

This downloads a static busybox binary (depending on your architecture) and creates a `/bin/sh` symlink for it.
Busybox will behave like a shell if invoked through that symlink.

Now confirm `bin` is set up as intended:

```
$ ls -l bin
total 964
-rwxrwxr-x 1 nero nero 981520 Jan 11  2017 busybox
lrwxrwxrwx 1 nero nero      7 Jan 13 16:08 sh -> busybox
```

## Enter the chroot

Create a script `enter-chroot.sh` and fill it with following contents:

```
#!/bin/sh
mkdir -p proc dev
mount --rbind /proc proc
mount --rbind /dev dev
mount --bind . /
exec chroot . /bin/sh
```

The script may be inside or outside of the chroot directory.
Set the +x flag (`chmod +x enter-chroot`).

To enter the chroot directory, you `cd` to it and run the following command:

```
unshare -U -r -m --propagation slave path/to/enter-chroot.sh
```

The `-U` and `-r` flag for `unshare` first creates a new user namespace, then maps the current user to uid 0.
This is required to secure privileges to create the other types of namespace.

`-m --propagation slave` will create a new namespace for the mount table (inspectable via `cat /proc/mounts`).
This allows our script to do bind mounts later, without interfering with the hosts mount table.
This is required.

After the namespaces are setup, unshare forks off our shell script, which in turn will set up bind mounts for `dev` and `proc`.

Mounting `.` to `/` will update the current mount table to shift to the current directory, this also removes external mounts from visibility.

The final `chroot` will update the root directory reference of the current process to match the new value in the mount table.

## First time chroot

Without the full busybox symlink family set up, you will need to prefix regular commands with "busybox " to run them.
To get the coreutils functionality inside the chroot, you should run the following commands:

```
busybox mkdir -p sbin usr/bin usr/sbin
busybox --install
```

This setups the symlinks for busybox.

Have fun exploring the system from inside of the chroot!

## Security considerations

The security of user namespaces is quite controversial.
I recommend not to use it in production.

Also, kernel namespaces are not suitable to isolate different trust domains.
With exploits of the Spectre/Meltdown class, it will still be possible to read sensitive data from other processes, even in different namespaces or on the host.

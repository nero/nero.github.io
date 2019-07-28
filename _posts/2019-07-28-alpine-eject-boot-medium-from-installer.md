---
layout: post
title: "Eject boot medium from Alpine Linux installer"
---

When booting the Alpine Linux installer ISO, the modloop is directly loop-mounted from it and prevents the umounting of it.
Just umounting the modloop results in the kernel modules being inaccessible.

This is a quick cheatsheet how to copy the modloop into ram:

First, find the path of the modloop:

```
localhost:~# losetup -a
/dev/loop0: 0 /media/sdb/boot/modloop-vanilla
```

Copy it into the rootfs, which is in RAM:

`cp /media/sdb/boot/modloop-vanilla /`

Umount the disk-backed modloop:

`umount /dev/loop0`

And mount the copy in RAM in its place:

`mount -o loop /modloop-vanilla /.modloop`

Finally, umount the boot disk:

`umount /media/sdb`

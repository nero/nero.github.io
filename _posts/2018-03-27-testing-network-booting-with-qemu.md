---
layout: post
title: "Testing Network Booting with QEMU"
---

Usually, one would require a network bridge between QEMU's tap and the ethernet device, which is a rather unusual network setup for a laptop.

When dreaming around i came up with an idea how to do it without modifications to the network setup, and even root is not required.
The idea is to run qemu with SLIRP (User Networking) interface, and serve a prelimary pxelinux config that redirects to your actual, external server.
Because of pxelinux, this mechanism will only work for x86 platforms.

Setup a local directory to server tftp contents from and preseed it with the pxelinux bootloader:

```
mkdir tftp

# I know about shell globbing, but lets keep it explicit
cp /usr/share/syslinux/ldlinux.c32 tftp/
cp /usr/share/syslinux/libcom32.c32 tftp/
cp /usr/share/syslinux/libutil.c32 tftp/
cp /usr/share/syslinux/pxechn.c32 tftp/
cp /usr/share/syslinux/pxelinux.0 tftp/

mkdir tftp/pxelinux.cfg

cat <<EOF >tftp/pxelinux.cfg/default
PROMPT 0
DEFAULT chain
LABEL chain
	KERNEL pxechn.c32 1.2.3.4::pxelinux.0
EOF
```

The syslinux binaries come from the syslinux packages.
On Debian its spread out over multiple packages and placed in different directories.

Fill in the IP address of your actual TFTP server in the arguments of pxechn.c32.

Then start qemu like this:

```
qemu-system-x86_64 -m 1024 \
  -boot n \
  -option-rom /usr/share/qemu/pxe-rtl8139.rom \
  -device e1000,netdev=mynet0,mac=52:54:00:12:34:56 \
  -netdev user,id=mynet0,net=192.168.76.0/24,dhcpstart=192.168.76.9,tftp=/path/to/tftp,bootfile=pxelinux.0
```

The option rom is a bit messy to figure out and probably needs to be separately installed (some `qemu-foo...` or something).
Insert here the full path to the tftp server.

I tested this at the local hackspace, with the connection going via wifi.

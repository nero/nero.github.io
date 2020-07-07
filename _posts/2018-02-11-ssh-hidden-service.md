---
layout: post
title: "SSH as a hidden service"
---

**NOTE: This article features onion v2 addresses, which are obsolete as of 2020**

Connecting to a server via Tor is useful if:

- Your or the servers location (IP) must be hidden
- Your server is behind a NAT or worse, but still has access to the tor network
- You want to obscure what you are doing on the network or bypass an firewall

## Server Setup

You need to install using the package manager of your choice.
Assuming you already have sshd installed and running, only the package `tor` is required.

Edit the file `/etc/tor/torrc` as root and place the following lines near the other (probably commented-out) lines:

```
HiddenServiceDir /var/lib/tor/ssh/
HiddenServicePort 22 127.0.0.1:22
```

If you run your SSH daemon on a different port, you need to modify the second port number of the second line.
Reloading your Tor service will start the hidden service.

Copy the onion address from `/var/lib/tor/ssh/hostname`, you will need it in the client setup.

## Client Setup

On the client you need an running tor node with an open SOCKS5 proxy on port 9050 (this is the default).
In addition to an ssh client, you also need a netcat-like program.
Im using OpenBSD's netcat.
Other implementations will have a different command line syntax, consult your manpage then to determine the correct ProxyCommand.

Add the following to your SSH config (`.ssh/config`):

```
# Wildcard to match all tor hosts
Host *.onion *-tor
  ProxyCommand nc -X 5 -x 127.0.0.1:9050 %h %p
  CheckHostIP  no
  Compression  yes
  Protocol     2
```

You only need this section once.
Placing it at the top of your ssh config file will make sure the other sections wont overide it.

For each server you want to access via tor, you can create an dedicated config section.
Insert the onion domain from the previous section here:

```
Host host1
  Hostname host1.yourdomain
  # Other settings here
Host abcdefghijklmn.onion host1-tor
  Hostname abcdefghijklmn.onion
  # Other settings here
```

The following invocation syntaxes for ssh can now be used:

```
ssh host1 # Clearnet access
ssh host1-tor # Shortcut for onion access
ssh abcdefghijklmn.onion # Unmemorizable long form for onion access
```

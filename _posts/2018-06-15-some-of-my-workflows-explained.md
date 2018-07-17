---
layout: post
title: "Some of my workflows explained"
---

I have multiple user-end devices, and there isn't a distinct primary one.

## OpenVPN

Most of my end-user devices are connected via a VPN.
While the VPN itself has no route to the outside internet, it enables my machines to have direct routes even when behind a NAT.
Nodes in the VPN automatically get world-readable A and AAAA records to point to their internal addresses.
This way, each node in the VPN is able to access other nodes via domain name.

The VPN itself does not carry authentication significance, so im able to let other people join their nodes.
Its primarily a mean of NAT traversal.

## SSH Certificates

Most of the Nodes have a SSH server running and are set up to trust my SSH CA keypair.
I use that keypair to sign the ssh keypairs on the user-end machines.
By using certificates, i dont need to maintain the authorized_keys files.
This would be really messy in a N:M clients:servers situation.

Depending on security aspects, some nodes have different settings.
This is a mean to integrate with the security policy of other organisations.

## Mosh

Mosh provides good resilience against bad network connectivity.
It piggybacks on SSH for authentication.
The VPN goes over UDP, so it doesn't hurt the resilience of mosh.

## tmux

Tmux is the persistence layer.
Some nodes have tmux sessions running.

## Desktop Environment

I have my shell and desktop settins tracked in git, allowing me to reproduce the same working environment on different machines.
I use i3 as window manager and urxvt as terminal emulator.
The setup is kept simple, every window is maximized with a single bar for switching windows (like browser tabs).
This is helpful for distraction-free working.

Notifications work by propagating BEL control characters across tmux sessions.
When urxvt receives a BEL control character, it sets its "urgent" window property, allowing i3 to give its tab a signal color.
This scales well with the N:M relationship of user-end devices and applications.

## Backup

Most nodes dont have data that needs to be backed up.
Non-sensitive data is distributed across selected nodes via bittorrent, sensitive data is usually tracked with git.
There is a node that has bare repos and functions as a canonical remote, but in practice im free to pull from any other SSH-reachable node.

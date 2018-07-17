---
layout: post
title: "Opinions on Implementations for reproducible deployments"
---

# Docker

- 3rd layer of packaging (previous are tarball and dpkg/apk/whatev)
- Gets rather crappy as soon as you somehow need to authenticate containers against each other
- Docker networks fix this by creating dedicated network bridges (authentication happens by joining them)
- Updates to the base system (which happens rather often) would require a rebuild of all derived docker images, solution here is to just not update
- Deploying those updates then is requiring to store everything in parallel (overlays are useless if the base changed)
- Needs 3rd party tools to clean old images up
- Secrets must be bind mounted in or placed in the registry (which is utter crap)
- Isn't managing configuration
- Docker bridge implementation is the recipe for sabotaging IPv6 deployment for the next 20 years
- Still unstable under certain graph drivers and kernels
- I dont ever expect it ever to become stable software
- Images have no interop except from importing rootfs tarballs (at least image format isn't propietary)

# Ansible

- You need cleanup roles and playbooks (or equivalent mechanism), otherwise deployed packages and files from older versions of your roles will clutter up your system
- Solution for this: incrementally tear down and rebuild your infrastructure
- Rather slow, especially for huge server farms
- Uses YAML, which is heavily suffering from featuritis and competing implementations
- Secrets deployment via password-manager like integration possible (YAML hack to include it)
- Potential to properly deal with certificate-based host authentication
- Depends on python server-side
- Plugin-itis

# Go

- Only mentioned because it does link statically by default
- Binary size is an estimated 50 to 100 times larger than equivalent C code
- Go get absolutely cant deal with networks disjunct from the internet
- Requires rebuild when dependencies update

# Conventional static C linking

- Autotools, just "nope"
- Requires rebuild when dependencies update

# Nix

- Allows to properly create a system before deploying it
- First and only package manager that i know that is slower than apt-get (Updating 0 packages takes longer than installing a fresh base system with apk)
- Different FS layout requires heavy patching and heavy use of shell script wrappers around binaries
- Those wrappers are written in bash
- Wrappers also pollute scope of programs started indirectly, just dont look at the ENV of random processes
- /etc is managed in a stateless way, so you need hacks for per-host secrets like keypairs
- Requires rebuild when dependencies update

# apkovl

- Allows to properly create a system before deploying it
- Is pre-creating a tarball of /etc and deriving package list from that
- One-way like ansible, need extra software to clean /etc up (or rebuild from scratch)
- Quick enough to do it at boot (diskless mode)
- No established way to create apkovl

In addition, Docker and Ansible suffer from the fact that their owning companies want to sell you support for it.

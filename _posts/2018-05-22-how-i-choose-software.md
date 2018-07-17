---
layout: post
title: "How i choose software"
---

Because it sometimes seems arbitrary which software i like and which i dont, i'll try to outline what things i look for when making such judgements.

Also, before evaluating software, step 0 is to *check if the problem can be solved with pre-installed software*.

## Things that make me interested

- function that can be well explained by several paragraphs of docs (runit, mosh)
- portable interface (like unix pipes or command line arguments)
- high portability due to simplicity
- focuses to solve a single (possibly complex) problem (mosh)
- has bugfix-only releases (like linux kernel)
- development pace looks like its finished, no reason to wait for a next, "better" version
- has clear migration paths away (opposite of vendor lock-in)
- has documented and well defined behavior for error situations
- correctness over quick feature-hacks (musl libc)

## Things i avoid

- cargo-cult buzzwords like "modern" or "DevOps"
- lack of manpage / offline documentation
- documentations focuses on "how" stuff is done, not giving any insight how the program works
- `curl | sh` - i wish this finally dies
- magic box that does everything but fails horribly in less-common cases (systemd, IDEs)
- not properly documented compilation process
- awful regressions on update (gcc, glibc)
- overreaching Code of Conducts (Node.js, FreeBSD, Go)
- maintainers that use your production as their testing environment (systemd)
- "always on edge" crap that forces me to change my code every 6 months (Node.js)
- high cost by abstraction layers (like Nix)
- [CADT](https://www.jwz.org/doc/cadt.html) (gtk, gnome)
- world-open QA-less package ecosystems (NPM, go get)
- features over stability (btrfs, docker, pulseaudio)

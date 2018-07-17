---
layout: post
title: "Using git over tor"
---

Usually, `torsocks` is recommended to access git repositories over tor.

This is incompatible with my current workflow, which includes an foreach-like interation over all repositories to fetch their remote refs.
Looking for ways to make an default `git fetch` use tor per default, i opted to create a custom remote helper.
You can read about the mechanism in general in `gitremote-helpers(1)`.

To trigger the helper, i prefix every remote i want to access via tor with `tor://`.
The helper then checks the rest of the url and delegates the work to the torsock-ed original remote helper.
This way i can use `git fetch` generically without bothering on the actual transport mechanism.

I'll quote the PoC version of the helper here:

```
#!/bin/sh
url="${2#tor://}"
case "$url" in
http://*)
  exec torsocks git-remote-http "$1" "$url"
  ;;
https://*)
  exec torsocks git-remote-https "$1" "$url"
  ;;
git://*)
  url="${url#git://}"
  remote="${url%%/*}"
  url="${url#*/}"
  exec git-remote-ext "$1" "torsocks nc ${remote} 9418 %G/${url}"
  ;;
esac
```

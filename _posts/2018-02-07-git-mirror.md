---
layout: post
title: "Setting up a bare git mirror"
tags:
  - outdated
---

Today i setup a private mirror of the busybox repository:

```
git init --bare busybox.git
cd busybox.git
git remote add origin git://git.busybox.net/busybox
git config remote.origin.fetch 'refs/heads/*:refs/heads/*'
```

The last line is important, otherwise `git remote update` would only update the ref/remotes sections and not ref/heads.
You can always check with `git show-ref` which refs are currently defined.

To update the git repo, you can schedule `git remote update` via cron.

Also, when updating the head refs this way, neither the post-receive nor the post-update hooks do fire.
If you rely on those hooks for generating notifications et cetera, you might want to manually invoke them via `hooks/post-update` from cron.

Because `git remote update` overwrites refs without question, i want to protect myself from accidentally pushing to it (and loosing my commits afterwards).
To achieve this, i added a `hooks/pre-receive` script blocking any push operation and reminding me of the state of the mirror:

```
#!/bin/sh
echo "Read-only mirror of $(git config remote.origin.url)" 2>&1
exit 1
```

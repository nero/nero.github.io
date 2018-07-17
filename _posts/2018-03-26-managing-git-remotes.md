---
layout: post
title: "Managing (push) git remotes"
---

Git supports transfers via several transport mechanisms, especially popular are SSH, HTTP(s) and the git protocol itself.
When interacting with remotes, the protocol type is being determined by the remote url.
Some of the transports are read-only or dont allow reasonable pushes.

Quite often, i clone a public repo via the git or http protocol, and later authorize my machine or gain push rights to that repository.
Because i do pushes exclusively over ssh, this results in a weird mess of remotes, often having to 'fix' urls.

Thankfully, git allows rewrites of remote urls.
Lets take the following `gitconfig` snippet:

```
[url "git@github.com:"]
	pushInsteadOf = "git://github.com/"
	pushInsteadOf = "https://github.com/"
```

Using this, all pushes using git or https remotes are transparently redirected to use the ssh transport instead.
With `git remote -v` you can check the effective remote for your local git repository.

This is also useful to force-migrate away from github:

```
[url "git://other.server.net/nero/"]
	insteadOf = "git://github.com/nero/"
	insteadOf = "https://github.com/nero/"
```

This will transparently redirect to another server of your choice.
Take note that this snippet uses `insteadOf` instead of `pushInsteadOf`, and therefore also applies to pulls.

I considered using github urls as canonical urls, and then transparently define the actual remotes using this mechanism.
This is probably an bad idea anyways because git is confusing enough, already.

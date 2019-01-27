---
layout: post
title: How to talk about symlinks
---

In a professional environment, its important to communicate clear and precisely.
Most time in meeting is spend on clarifying around because some people misunderstood a concept.

This post is about the direction of symbolic links.

Imagine standing at a junction somewhere in rural America.
There is a sign pointing eastwards, with "Washington" written on it.
Imagine hearing someone saying "Hey, they even signposted Washington to this junction".

Does this sound weird? Look at this:

> Either by symlinking any other shell to /bin/bash or by installing bash

They meant, "Create a symlink /bin/bash pointing to another shell or install bash".

Yeah, but everyone knows whats meant, right?
Watch people trying to talk about cascaded symlinks.
Its a hilarious dumpster fire of misunderstandings because half of people dont grok how references work.

```
$ touch a
$ ln -s a b
$ ls -la
-rw-r--r-- a
lrwxrwxrwx b -> a
```

In this case, `b` is a symlink to `a`.
`a` is a file and does not care if its being pointed to.
Its no problem to create symlinks to non-existant paths:

```
$ ln -s your_mom_pulls_catapults_to_isengard foo
$ stat foo
File: 'foo' -> 'your_mom_pulls_catapults_to_isengard
$ stat your_mom_pulls_catapults_to_isengard                                                                                
stat: can't stat 'your_mom_pulls_catapults_to_isengard': No such file or directory
```

Symlinking is a operation on the symlink, and the symlink alone.
Its target string is essentially arbitrary.

The helptext of `ln` illustrates that:

```
Usage: ln [OPTIONS] TARGET... LINK
```

You dont go away from targets, right? You go towards them.

I can't believe how much time i wasted because half of tech people believe the direction of a symlink is the other way around.

How did this even come to be?

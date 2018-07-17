---
layout: post
title: "Hints on getting IRC support"
---

The Freenode IRC network offers a large variety of IRC channels.
Many FLOSS projects have channels there, which have a constant influx of people with problems.

Sadly, its not easy for newbies to explain their problems in a way people can help them.

I outlined some things that might help.

## Small Talk and meta

```
<k> Hi
<k> How are you guys doing?
```

```
<w> May i ask some question?
```

Almost all people in an IRC channel are lurking at the moment you write this.
This means, they are not actively taking part of the conversations.
Only a fraction of those lurking users even read the channels happening.

Your goal is to attract those peoples attention.
This is best done by getting straight to the point.
If some lurker sees you talking about something they recognize, they will come out and reply.
Regular small talk is rarely enough to do that.

On most IRC channels its socially perfectly acceptable to skip IRL customs.

## Too generic

```
<f> does anyone experience problems with XYZ?
```

Sometimes you are lucky and your problem is actually wide spread and well known.
Worst thing, they only talk to people also having a problem in that domain.
If its a problem only you experience, nobody will feel talked to.

# "Does not work"

```
<g> i tried XYZ but it does not work
```

These sort of questions are really tough to guess.
Just dont.
Never say "does not work".
Instead, say what you expected, and what you got instead.

Sometimes the issue is just a misunderstanding how something works.

## Asking for the wrong thing

```
<h> how do i convert glibc programs to musl?
<o> theoretically its possible, practically its such a pain that nobody has tried it yet
...
<h> i just want to run spotify on alpine linux
<o> gcompat offers a run-time environment for that
```

This is also known as the X-Y-Problem.
It happens when somebody has problem X and assumes Y is the solution for it, and asks how Y can be done.
In the example, X is "running spotify on AL" and Y is "converting glibc binaries to musl".

This problem is common enough to have an own [Website](http://xyproblem.info/).

## Complaining

Complaining in general.
Being antagonistic will get you nowhere except banned.
Keep in mind that most FLOSS people are doing it in their free time.

People who expect support like from a commercial project will need to adjust their expectations.

Also keep in mind that people helping you are likely other users like you and no official maintainers.

## Pasting

Error messages are really important for debugging.

Another big no-go is pasting multiple lines of text (error output or code) directly to irc.
Please paste that code to some pastebin service and post the URL instead.

Good upload services are sprunge.us and ix.io.
Usually pastes can be created directly with a curl command.

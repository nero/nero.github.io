---
layout: post
title: Rant about bash startup behavior
---

## About shell startup

Shell and environment initialisation usually consists out of two parts:

- profile: initialisation that only happens once at login, regardless if the 
  shell is interactive or not. Environment variables are usually set up here.
- shellrc: setup for interactive shells, like setting up aliases and the prompt.

The location of the shellrc is defined by the ENV variable being set in profile.
If its not set, a shell-specific value (like `~/.*shrc`) is assumed instead.

The semantics of this are pretty clear.
`/etc/profile` and `~/.profile` are executed by login shells, while the shellrc 
only gets executed for interactive shells.

## My Story

At work, we have huge shell servers where people do their work.
When i log in there, i want to get an easy glimpse on whats currents up in the 
git repos, so i set up a tiny script to show some key information upon ssh'ing 
in.
Because this is clearly something you only want in interactive shells, i placed 
the invocation of my tiny script in shellrc, and proceeded happily.

But then i got this:

```
$ rsync server:/path/to/file local/path
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
protocol version mismatch -- is your shell clean?
(see the rsync man page for an explanation)
rsync error: protocol incompatibility (code 2) at compat.c(178) [Receiver=3.1.2]
```

And this:

```
$ git clone server:src/scope3/repo4
Cloning into 'foo'...
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
fatal: protocol error: bad line length character: foobar
```

What the fuck?
My shellrc was the only place where i was using `tput`, so i was sure it was 
sourced somewhere.
Im using `tput` for generating the color sequences for my prompt.
`tput` relies on `$TERM` being set to a value describing what kind of terminal 
it should provide control sequences for.
This does not make sense for non-interactive shells of course.

How could this happen?

I found that i could easily reproduce the issue with `ssh server true`, on 
servers where my login shell was set to bash.

Did bash fail to see its not interactive?
`ssh server 'echo $-'` showed 'hBc'.
This means bash knew it was neither interactive nor a login shell.
Why got `.bashrc`, which is a symlink to my shellrc, executed then?

Desperately i consulted the bash manpage.

>When bash is invoked as an interactive login shell, or as a non-
>interactive shell with the --login option, it first reads and executes
>commands from the file /etc/profile, if that file exists.  After
>reading that file, it looks for ~/.bash_profile, ~/.bash_login, and
>~/.profile, in that order, and reads and executes commands from the
>first one that exists and is readable.  The --noprofile option may be
>used when the shell is started to inhibit this behavior.

One big difference.
`ENV` is completely ignored, and no attempt on reading the bashrc is made.
This is also why the default `.bash_profile` has an include on bashrc.

>When an interactive shell that is not a login shell is started, bash
>reads and executes commands from ~/.bashrc, if that file exists.  This
>may be inhibited by using the --norc option.  The --rcfile file option
>will force bash to read and execute commands from file instead of
>~/.bashrc.

Alright, this what i would have expected of bash.
This still doesn't explain why a non-interactive shell loads the bashrc.

>Bash attempts to determine when it is being run with its standard input
>connected to a network connection, as when executed by the remote shell
>daemon, usually rshd, or the secure shell daemon sshd.  If bash
>determines it is being run in this fashion, it reads and executes
>commands from `~/.bashrc`, if that file exists and is readable.  It will
>not do this if invoked as sh.  The --norc option may be used to inhibit
>this behavior, and the --rcfile option may be used to force another
>file to be read, but neither rshd nor sshd generally invoke the shell
>with those options or allow them to be specified.

What the fuck?

`.bashrc` may be sourced from a shell that is both non-interactive and 
non-login?

This is why every .bashrc MUST explicitly check if the shell is interactive and 
exit if its not.

I set my login shell to `mksh` on all remaining machines, because i think 
surprises are only good for birthdays, not for servers.

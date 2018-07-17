---
layout: post
title: "Portable Shell Prompt"
---

Im faced with a great variety of different POSIX-like systems, both at work and at home.
This also means that i dont always have much choice in selecting my preferred shell.
Contrary to popular perception, bash is *not* standard.

The scope and validity of this post is restricted to shells that are a superset of POSIX.

Executed shells have several properties, including:

- being interactive
- being a login shell

Examples:
- Logging in via the Linux Virtual Terminal (tty1 and such) results in a both interactive and login shell
- Starting a xterm from X results in an interactive shell that is not a login shell
- Invoking the shell via `#!/bin/...` as part as script execution results in a shell that is neither interactive nor a login shell

POSIX defines `~/.profile` as startup file for login shells.
There is also the `/etc/profile` system profile, but i'll focus on the things non-root has control over.
The profile script might set the ENV variable.
If the shell is also interactive, the script specified in ENV (or a default one) is sourced.
Depending on the shell properties, one, neither or both of `.profile` and `$ENV` might be sourced.
If you want an uniform prompt, it makes sense to have ENV the same value regardless for what shell is used.

Take note, that this requires the ENV variable be set for xterm-started shells (or from other terminal emulators).
I solved this by sourcing ~/.profile from xinitrc.

This works for all POSIX-conforming shells.
Zsh needs some extra symlinks here, both `.zprofile` and `.zshrc` map nicely to `.profile` and `$ENV` in their semantics.
`$ENV` is not automaticaly sourced.

Bash's behavior is utterly nonsensical.
You can both symlink `.bash_profile` and `.bashrc` to `.profile` and `$ENV`, but you'll need the following workarounds:
- If bash is both a login shell and interactive, *only* `.bash_profile` is called.
  Thus you need to append a check to .bash_profile to invoke .bashrc if the shell is interactive
- If invoked via SSH, it will source the `.bashrc` regardless of its interactive property.
  Printing data to stdout from the server-side `.bashrc` will thus break things like git or rsync over SSH.
  To fix this, you need to prepend a check and return if the shell is not interactive

The script specified via ENV may define the PS1 variable to set the prompt.
The expansion (substitution of variables, execution of `$(...)` commands) of PS1 on prompt rendering can be done using POSIX-Shell compatible means:

```
PS1='$USER@$HOSTNAME:$PWD: '
```

zsh additionally needs `setopt PROMPT_SUBST` for this to work.

## Color sequences and unprintable characters in prompt

Its easily possible to add color sequences to your prompt ("unprintable" because they dont draw characters on the screen).
You can create them portably with `printf '\033[...'`.

They might cause negative effects if your command is quite long.
Because the shell can't implicitly know which characters take up space and which dont, it will miscalculate the overall length of your prompt and command.
This results in broken command editing if you use unprintable characters in your prompt.
The quoting of unprintable characters itself is not portable and has to be done individually for each shell supporting it.

I decided to wrap that up into functions that can be used later for building the `PS1` variable:

```
_ps_init() {
  :;
}

_ps_unprintf() {
  printf "$@";
}
```

This defined two dummy functions, one for a prompt prefix (we need this for mksh) and one which behaves like printf.
This is the default function definition, which all unknown shells will use per default.

```
if [ -n "$BASH_VERSION" ]; then
  _ps_unprintf() {
    p="$1"
    shift
    printf "\[$p\]" "$@"
  }
elif [ -n "$ZSH_VERSION" ]; then
  setopt PROMPT_SUBST
  _ps_unprintf() {
    p="$1"
    shift
    printf "%%{$p%%}" "$@"
  }
elif [ -n "${KSH_VERSION##*PD KSH*}" ]; then
  _ps_init() {
    printf '\001\r'
  }
  _ps_unprintf() {
    p="$1"; shift; printf "\001$p\001" "$@"
  }
fi
```

This code checks for Bash, Zsh and Mksh and overwrites the `_ps_unprintf` function with a shell-specific implementation.
This implementation wraps the output into the necessary escape codes to signal the specific shell the unprintable nature of the output.

mksh is special as it needs to insert signal characters at the beginning of the line, not only around each unprintable output sequence.

```
PS1=$(
  _ps_init
  _ps_unprintf "\033[1;32m"
  printf '%s@%s' '${USER:-?}' '${HOSTNAME%%.*}'
  _ps_unprintf "\033[0m"
  printf '%s' ':'
  _ps_unprintf "\033[1;36m"
  printf '%s' '${PWD##$HOME/}'
  _ps_unprintf "\033[0m"
  printf '%s' '[$?]'
  printf '%s' ': '
  case "$TERM" in
  xterm*|rxvt*|st*|screen*|tmux*)
    _ps_unprintf "\033]0;%s\007" '${USER}@${HOSTNAME%%.*}:${PWD}'
    ;;
  esac
)
```

When actually building the prompt, you dont have to bother with shell specifics anymore.
Unprintable sequences are printed via _ps_unprintf in a generic fashion.
This way you can have a single colorful prompt definition for all POSIX-like shells, without breaking editing of long commands.

I often get asked about those `${...#%}` codes.
They are documented in Section 2.6.2 "Parameter Expansion" of the [POSIX Shell Command Language](http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html) definition, providing some simple string operations.

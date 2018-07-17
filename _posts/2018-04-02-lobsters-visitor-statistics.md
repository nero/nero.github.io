---
layout: post
title: "Lobste.rs visitor statistics"
---

**Note:** im just a regular lobste.rs user, not an admin nor mod.

For April Fools day, lobste.rs turned into an phpBB-like forum.
This also allowed for setting external images as forum signatures, which i did make use of.
After the whole thing was over, i grabbed the webserver logs and compiled some facts together.
The logs span approximately one and a half day, so they are skewed towards users from europe.
Also, my signature was only shown in certain threads, so there are probably many missing users.

- 5607 requests were made, amounting to 135 gigabytes of transferred bodies. This number is high, because originally, my tracking pixel was an 600 megabyte JPEG from the Hubble Space Telescope, picturing the Andromeda galaxy
- 9 requests had an body size of 1, all of which had Google Chrome as agent. I assume they crashed

# User Agents

- 894 distinct user agents were spotted
- 46% Android phones, ranging from 4.0 to 8.1 
- 15% Macintosh / Apple
- 15% X11 users (intersects with Linux) (including *BSD)
- 12% Windows
- 12% Linux (non-Android)
- 11% iPhones / iPads

# IPs

- 4646 distinct IP addresses
- 80% IPv4, 20% IPv6
- 33.3% from the US
- 6.3% from the UK
- 5% from Canada
- 4.9% from Germany
- 2.5% from France
- 2.2% from Australia
- 2.1% from Netherlands
- 2.0% from Sweden

# Weird things i noticed

- Two instances of Windows XP
- Someone is using Sailfish OS / Maemo
- There were 5 or so Opera users
- Some traces of FreeBSD and armv7 (linked to Chromebooks)
- A single user is using the AdGuard extension, which always sets the referrer to `http://adguard.com/referrer.html`. This makes this user unique across the dataset
- Three users tried to query [my dnt-policy.txt](https://www.eff.org/dnt-policy). I wasn't aware that such an thing exists. I guess this behavior is triggered by some privacy-addon and also makes those users significant across the data set.

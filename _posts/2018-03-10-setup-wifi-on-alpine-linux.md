---
layout: post
title: Setting up Wifi on Alpine Linux
---

This setup guide is intended for laptops running Alpine Linux.

First step, remove your wifi interface from `/etc/network/interfaces`.
Make sure `networking` is enabled via `rc-update`, otherwise you wont get a configured loopback device..

```
# Install necessary stuff
apk add wpa_supplicant dhcpcd

# Enable services
rc-update add wpa_supplicant
rc-update add dhcpcd

# Start dhcpcd now
/etc/init.d/dhcpcd start
```

Create your wifi config snippet with `wpa_passphrase` and append it to `/etc/wpa_supplicant/wpa_supplicant.conf`.
I found it necessary to keep the settings for the control socket in there:

```
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=wheel
```

Each network section should look like this:

```
network={
	ssid="Abraham Linksys"
	psk=ce6b408a0f91e374d3cd2b917e8fa28317133758d4fb25bd474878e420f72c4c
	# priority=4
}
```

The priority field is optional, but if you have multiple network sections, it can be useful to have an explict preference order.
Higher number means higher priority.

Start wpa_supplicant with `/etc/init.d/wpa_supplicant start`.
You can check if the connect was succesful by entering the `wpa_cli` shell and typing `status`.
The `wpa_cli` is also useful for dynamically connecting to wifi without having to permanently save it in `wpa_supplicant.conf`.

If `wpa_supplicant` is successful, `dhcpcd` will automatically recognize the now up network device and configure it via DHCP.

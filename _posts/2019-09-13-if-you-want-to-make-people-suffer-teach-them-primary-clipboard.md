---
layout: post
title: "If you want to make people suffer, teach them to use the PRIMARY clipboard"
---

Most users get to learn copy & paste via CTRL-C and CTRL+V, which seems to be the default nowadays.
But at least in the Linux ecosystem, there exists another kind of clipboard called PRIMARY.

With the primary keyboard, copying is done implicitly when selecting text.
Pasting text is done via the middle button of the mouse or Shift+Insert.

If you haven't used it yet, you may try it out!

<textarea></textarea>

Quite some terminal emulators were written with PRIMARY in mind - xterm, st, rxvt, and as of 2019, its still the default copypaste method for them.

So whats the problem?

The Internet. Websites, actually. Especially copying from websites into the terminal.
Its no problem to mark a command line or text paragraph and transfer it into your terminal with a middle click.
Except, at some point, website creators decided to make copying easier, so they created textboxes that automatically make their contents as selected (as you would do manually with your cursor) and call javascript functions to automatically write to your clipboard.
To the conventional clipboard. By making it implicitly select all itself, the user is unable to select it themselves to fill the PRIMARY clipboard.

So, if you happen to be a person who has to use the PRIMARY clipboard - you can copy all contents on all websites, EXCEPT the contents you are supposed to copy.
And this is the sadistic irony behind those UI "helpers".

Wanna copy a git url from Github to your terminal? NOPE.

Copypaste a command from a "helpful" textarea? NOPE.

Copy a API token out of Artifactory? NOPE.

As a workaround, you need to copy it via CTRL-C, CTRL+V into a textbox (whose creator does give a crap about acessibility), then select it all before you can finally post it into your xterm.

If this is modern UI development, i'd rather be a conservative reactionary.
Acessibility matters. Some people dont have a choice.

PS: The SSH URL field is, depending on the screenreader technology, completely invisible on github.

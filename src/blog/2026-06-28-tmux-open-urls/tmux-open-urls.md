# tmux trick #3: open URLs without the mouse

*This post is part of a [series](../../series)*

My [last post in this series](../2026-05-17-tmux-clipboard) on copy mode
was inspired by an old `.tmux.conf` file that I found in a backup folder.
In that same file I also had a command that selects all URLs that are
visible in the current pane, shows them to the user in a
[dmenu](https://tools.suckless.org/dmenu) session, and opens the
selected URL in a browser. This command is bound to `C-b u` with
the following configuration line:

```
bind u run "tmux capture-pane; tmux show-buffer | urlgrep | dmenu -l | xargs firefox"
```

This command is a great example of UNIX program composability. Let's break it down!

## The pipeline

First, `tmux capture-pane` copies all the text of the current pane in
its copy buffer. Then `tmux show-buffer` prints the current copy buffer
to standard output - we talked about this last time.

This text is then [piped](https://en.wikipedia.org/wiki/Pipeline_(Unix))
into `urlgrep`, a custom script that I wrote by copy-pasting a regular
expression from some StackOverflow answer:

```
#!/bin/sh

protocols='http|https|ftp|sftp|gemini|mailto'
valid_chars="][a-zA-Z0-9_~/?#@!$&'()*+=.,;:-"
regex="(($protocols):|www\.)[$valid_chars]+"

egrep -o "$regex"
```

This [grep](../2023-08-20-grep) command selects all URLs from its standard
input and prints them out one per line. These URLs are then sent to dmenu,
a graphical tool that prompts the user to select one of the items it received
in its standard input. The `-l` option is used to change `dmenu`'s layout so
that it shows one option per line.

The user's selection is then printed by `dmenu` to standard output; so we
use `xargs` to convert it to an argument for the `firefox` command. And
that's it! You can now follow links from your terminal using only your keyboard.

## Caveats

If a URL is broken into multiple lines, my `urlgrep` script is only going to
select it until the end of the first line, so you won't be able to open
it correctly with this configuration. However, I found this to be a common
issue in many terminal emulators.

## Update 2026-07-05

Shortly after this post was published, a reader emailed me his modified
version of the binding:

```
bind u {
	capture-pane -J
	display-popup -w 80% -T "Select URL to open" -E "tmux show-buffer | urlview"
}
```

This taught me three things:

1. `urlview` can replace my custom combo of scripts - cool! But I kinda like
   my scripts, I think I'll keep using them.
2. Using `display-popup` to show a "window" inside the tmux session. This can
   be useful e.g. if one is not running a graphical session at all. I can
   use it together with the `-m fzf` option for my `dmenu-urlselect`.
3. The `-J` option for `capture-pane` to preserve trailing spaces and join
   any wrapped lines. This may solve the caveat I mentioned above!

Thanks Johannes!

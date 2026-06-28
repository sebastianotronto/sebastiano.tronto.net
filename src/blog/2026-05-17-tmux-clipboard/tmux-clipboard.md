# tmux trick #2: copy to clipboard

*This post is part of a [series](../../series)*

Recently, for reasons that I may explain in a future blog post, I went
through some old configuration files of mine, and I found something in
my `.tmux.conf` that I thought would be worth a second post in this
series - only 2 years after the first episode, not bad!

## Copy mode

[tmux](https://en.wikipedia.org/wiki/Tmux) has a feature called *copy mode*
that allows one to visually select and copy text, all via your keyboard.
By default you can enter copy mode by pressing `C-b [` (`Ctrl+B` followed
by `[`); from there you can navigate the text that is currently on your
terminal with arrow keys and [Emacs](https://en.wikipedia.org/wiki/Emacs)-style
key bindings - or with hjkl and other
[Vim](https://en.wikipedia.org/wiki/Vim_(text_editor))-style bindings if
you have a `VISUAL` or `EDITOR` [environment
variable](https://en.wikipedia.org/wiki/Environment_variable) set to `vi`.

You can then start selecting text by pressing `Space`, and confirm the
selection by pressing `Enter`. The selection will then be copied to
an internal tmux buffer, and you can paste it by pressing `C-b ]`.

Actually, tmux offers multiple copy-buffers, but honestly I have never
used this feature. You can read more about this in its [manual
page](https://man.openbsd.org/tmux).

## Copy to clipboard

By default, tmux will copy the selection to its internal buffer, but you
may want to paste that text somewhere outside of tmux - maybe in a chat
application or in a web browser URL bar. And here is the trick: you can
actually tell tmux to [pipe](https://en.wikipedia.org/wiki/Pipeline_(Unix))
the selection to a custom command. For example, if you have this in your
`.tmux.conf`:

```
set -s copy-command "xsel -ib"
```

tmux will not only copy the selection to its internal buffer, but also
send it to the `xsel -ib` command. In case you did not know,
[`xsel`](https://linux.die.net/man/1/xsel)
is a command that copies its standard input to the X session
[clipboard](https://en.wikipedia.org/wiki/Clipboard_(computing));
this way you will be able to paste the copied text into any other
graphical application with the usual `Ctrl+V`. Neat!

## tmux show-buffer

Here one last trick: with the `tmux show-buffer` command you can print the
current tmux selection to standard output. You can use this in shell scripts,
for example, or in more complex tmux key bindings in your configuration file.
And that's a teaser for the next tmux trick :)

*Next in the series: [open URLs without the mouse](../2026-06-28-tmux-open-urls)*

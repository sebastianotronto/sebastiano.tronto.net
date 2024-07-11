# tmux tricks #1: battery status indicator

[tmux](https://github.com/tmux/tmux/wiki) is a program that allows
you to create multiple virtual terminals in the same shell and keep
your terminal sessions open even after the shell exits. A common
use case for both of these features is connecting to a remote server:
with *multiplexing* you can use multiple terminals with a single
SSH connection, and the session persistence feature leaves the
remote programs running even when you disconnect from the server.
Having multiple virtual terminals open on the same screen and easily
switching between windows is also useful when working locally.  In
fact, tmux is the first command I use pretty much every time I use
my [netbook](../2022-09-10-netbooks) - even though
[one shell is all I need](../2023-02-25-job-control).

Since tmux is quite a complex program, I never learned the details
of how it works. I learned how to do the couple of things I need,
and use the default settings for everything. But sometimes I do
feel the need to improve my workfow a bit, and what better excuse
for tinkering with a software tool than writing about it?

In this post I have one simple goal: display the battery level in
tmux's status bar. I am going to focus on OpenBSD, because this is
the system where I need this: on my Linux laptop I use my window
manager status bar to display this information, but on my underpowered
OpenBSD laptop I rarely use a graphical environment, and I rely on
tmux as a desktop environment.

## tmux commands

tmux can be controlled using a variety of key bindings, all prefixed by
a "prefix" key combination, which by default is `Ctrl+B`. For example,
`Ctrl+B C` creates a new window and `Ctrl+B %` splits the screen
vertically.

Each key binding calls a *tmux command*. Not all commands are bound to
a key combination, and there are other ways to call them, including:

* Typing them in the tmux command line, invoked by pressing `Ctrl+B :`.
* Calling them from any shell as `tmux command ...`.
* Adding them to the tmux configuration file (by default `~/.tmux.conf`)
  to be called on startup.

## The tmux status bar

tmux has a status bar, which can be any size between 0 (disabled)
and 5 lines long. The default is 1 line with date, time and hostname
displayed on the right, and some information on the current session
on the left.

My goal is to customize the status indicators on the right. After
consulting the [man page](https://man.openbsd.org/tmux) for a while,
I figured out that the command I need is:

```
set status-right "Hello, World!"
```

To show the output of a command one can use the `#()` notation:

```
set status-right "#(date +'%H:%M')"
```

This example is actually a bit redundant, because the string is
passed through [strftime](https://man.openbsd.org/strftime) before
displaying. So one could simply use `set status-right "%H:%M"` to
specify a date in the HH:MM format.

The status bar by default refreshes (and so re-runs the commands
in `#()`) every 15 seconds, but this can be changed with the
`status-interval` command.

## Battery information

The next step is getting the battery status from a command. On Linux
I wrote a little [script](https://git.tronto.net/scripts) to automate
this, but I don't have one (yet!) for OpenBSD. On this OS, this
information can be retrieved with `apm`:

```
$ apm
Battery state: high, 91% remaining, 367 minutes life estimate
AC adapter state: not connected
Performance adjustment mode: manual (1000 MHz)
```

I am only interested in the `91%` part, so I should pass this through `grep`

```
$ apm | grep -o '[^ ]*%'
91%
```

This command means "print the strings that consist of a % symbol
preceded by any number of non-space characters". To learn more about
`grep`, check out [my blog post](../2023-08-20-grep).

## Putting it all together

We can get our status line to show the battery status with this
tmux command:

```
set status-right "#(apm | grep -o '[^ ]*%%')"
```

Cool! But did you notice the double `%%`? That's because the string
is formatted with `strftime`, as I mentioned before, so we must
escape the `%`.  Tricky!

## More status info

We reached our goal, but in doing so we also got rid of all the information
that was already part of the status. I would like to have at least some of
it back.

One way to solve this is to use the `-a` flags for the `set` command,
like this:

```
set -a status-right " #(apm | grep -o '[^ ]*%%')"
```

This will append the new string to the current status, instead of
replacing it. Alternatively, we could declare exactly all the stuff
that we want there:

```
set status-right "#(apm | grep -o '[^ ]*%%') | %Y-%m-%d | %H:%M"
```

But what if one wants even more information there? I don't want to have
a cluttered status line, but for example being able to see at a glance if
I am connected to wifi or not would be convenient.

A simple solution is writing a shell script that prints out all this
information, save it somewhere in the `$PATH`, and then use
`set status-right "#(status_script)"`. I already have such a script
for Linux, and now I added one for OpenBSD in my
[scripts repository](https://git.tronto.net/scripts).

## Configuration file

Finally, we can have our status bar set on startup by adding the
following line to our configuration file:

```
set -g status-right "#(status_script)"
```

...wait a minute, that is the `-g` flag about? Witout it, I get the
following error on startup:

```
/home/sebastiano/.tmux.conf:1 no current session
```

Apparently, commands run *without* `-g` only apply to the current
"session", but the configuration file is sourced *before* a session
is created. The `-g` is used to apply this command globally. My
understanding of this is still superficial, but for now I am happy
that the battery status is there.  Maybe I'll learn about sessions
at some point, and I'll write a new blog post about them :)

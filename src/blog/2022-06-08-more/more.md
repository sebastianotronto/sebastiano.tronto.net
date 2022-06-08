# The man page reading club: more(1)

In the second episode of this blog series we are going to cover a UNIX
pager.  Instead of the popular less(1), we are going to check out the
classic more(1).

## In the bunker

*After installing your new OS and checking out the basic documentation,
you are excited to discover what your laptop can do. But there is
something keeping you back. Maybe it's the rumors that the nuclear
winter will be raging for years to come and you are in there for the
long run. No, it's not that.*

*You feel that learning is fun, and fun is precious, so you should not
waste it.  Entertainment is a scarce resource in the bunker: social
interactions are awkward, and the battery-charging gym only offers
re-runs of crappy mainstream reality shows.*

*You dedice to play the slow game and
[RTFM](https://en.wikipedia.org/wiki/RTFM) some more before doing actual
work. You have just found out that the man(1) program calls an external
utility, called less(1), to actually display the page. Learning more
abut this makes sense.*

```
$ man less
```

*You start reading, but you soon feel overwhelmed: this manual page is a
fucking novel! There are pages and pages of options, and on top of that
there are commands, and you can't make sense of what is actually useful.
You scroll back to the top of the page and something catches your eyes:*

```
less is similar to the traditional more(1), but with many more features.
```

*Hoping it will be easier to grasp, you decide to look into more(1)*

```
$ man more
```

*No, wait! Let's use what we learned [last time](../2022-05-29-man):*

```
$ PAGER=more man more
```

## more(1)

*Follow along at [man.openbsd.org](https://man.openbsd.org/OpenBSD-7.1/more)*

The description of more(1) starts with

```
The more pager displays text one screenful at a time. After showing each
screenful, it prompts the user for a command.  Most commands scroll the text
or move to a different place in the file, while some switch to another file.
```

So "commands" seem to be the interesting part. There are also a handful of
options, but they seem quite technical and not so interesting. Just to name
a few: `-n` changes the number of lines per screenful, `-p` can be used to
execute a command when a file is first opened and `-t` can be used to view
a file containing a specific "tag". This last one is enticing, but it
redirects to ctags(1), which may be a good topic for a future post.

Let's move on to the juicy part!

```
COMMANDS
	Interactive commands for more are based on vi(1).  Some commands may be
	preceded by a decimal number, called N in the descriptions below.  In the
	following descriptions, ^X means control-X.
```

The first command is `h`, which displays a help page for more(1). It is
basically a more terse, cheatsheet-like version of the COMMANDS section
that we are reading.

The basic navigation commands scroll the current page up or down. They can
all be preceded by the number of lines to be scrolled, but have different
defaults: `j` (or `RETURN`) scrolls down one line, `k` up one line. `f`
(or `SPACE`, or `^F`) and `b` (or `^B`) scroll one window down and up,
respectively. `d` and `u` (or `^D` and `^U`) scroll half a
window down and up, respectively. It is not documented in the manual, but
arrow keys, and `PgUp` and `PgDn`, seem to work just fine too.

Perhaps more interestingly, the commands `m` and `'` (single quote) allow
you to "mark" certain lines and move to them:

```
m	Followed by any lowercase letter, marks the current position with that letter.

'	(Single quote.)  Followed by any lowercase letter, returns to the position
	which was previously marked with that letter.  Followed by another single
	quote, returns to the position at whcih the last "large" movement command was
	executed, or the beginning of the file if no such movements have occurred.
	All marks are lost when a new file is examined.
```

There is also a search function:

```
/pattern   Search forward in the file for the N-th line containing the pattern.
           N defaults to 1.  The pattern is a basic regular expression (BRE).
           See re_format(7) for more information on regular expressions.
           The search starts at the second line displayed.
```

Regular expressions are a powerful tool, but we will not see them in detail
today. For now it is enough to know that plain text is a perfectly fine
regular expression.

There are alternative commands for searching: using `?` instead of `/`
searches backwards from the top line, while `/!` and `?!` search for lines
that *do not* match the pattern. In each case the search command can be
preceded by a number `N`, meaning we want to find the `N`-th line that
matches the search. I can see this being useful with `N=2` in case you
want to find the first next occurrence of a word that appears on the
current screen. But it is probably easier to just rely on the `n` and `N`
commands, which simply repeat the previous search, in the same or opposite
direction respectively; for example, using `N` after a `?` search searches
for the same pattern *forward*.

The next group of commands is used to move between different files: `:e`
to open a new one, `:n` for the next file and `:p` for the previous.
`:t` is used to move between the aforementioned (but not explained) tags.

If you are using more to view a file, the command `v` can be used to edit it,
using the editor vi(1) by default.

And finally

```
q | :q | ZZ    Exits more.
```

The last sections are fairly short, but worth skimming through.

The ENVIRONMENT section explains that more can read some environment
variables to change its behavior. In my opionion the most interesting
ones are `EDITOR`, which changes the editor to be used with the `v`
command, and `MORE`, which can be used to set default options for more.

An interesting example in the EXAMPLES section:

```
Examine several manual pages, starting from the options description in
the DESCRIPTION section:

	$ more -p '/DESCRIPTION
	> /options
	> ' *.1
```

And a word of warning from the STANDARDS section:

```
The more utility is compliant with the IEEE Std 1003.1-2008 ("POSIX.1") specification,
though its presence is optional.
```

This means that, unfortunately, when dealing with some more obscure POSIX
operating system you may not have the luxury of a pager program. Too bad.

## Conclusions

It is worth noting that the more(1) manual page states

```
The present implementation is actually less(1) in disguise.
```

In practice this means that in OpenBSD, even when using more, one can
make full use of the extra features of less described in its manual
page. One of the few differences is how certain options are interpreted.

I originally planned to write about less(1), but I was, as the fictional
*you* in the nuclear bunker, overwhelmed by the amount of options
available.  Most of them are either quite technical or just change
slightly the behavior of the pager. Some can be nice, but definitely
not necessary (e.g.  `-P` to change the prompt).

I don't see myself using any of the extra features described in the less(1)
man page, with the notable exception of the `|` (pipe) command, which 
can be used to pipe arbitrary portions of the current file to an external
command. But apart from this I could easily live in the pre-1985 era.

See you next time!

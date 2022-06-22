# The man page reading club: man(1)

I have been using Linux as my main operating system for the
last 14 years, and as my only one for the last 10. Needless
to say, I really like it. However, at the end of last year I
have decided to use [OpenBSD](https://www.openbsd.org/) for my
[VPS](https://en.wikipedia.org/wiki/Virtual_private_server). I had 3
main reasons (spoiler: security is not one of them):

* It is still UNIX: most things I am used to do with the Linux command
  line work exactly the same in other UNIX-like operating systems, so
  I would not have to learn everything from scratch.
* Comprehensive base installation: a lot of things I needed,
  such as an http server, were already included in the base system.
  This results in a great consistency with the rest of the OS,
  for example in terms of configuration file location and syntax.
* Local documentation, i.e. manual pages: having a well-written documentation
  attached to any piece of software you install is something that I find
  very valuable. I do not like the idea of having to rely on external
  documentation, which may or may not be specific to the OS I am using
  and to the specific version of the software I have installed, and
  googling for solutions is always a hit or miss.

As I was expecting, after some time using it I was really pleased with
the quality of OpenBSD's manual pages, to the point that I am sometimes
using them (by ssh-ing into my server) also when I am working or writing
[scripts](https://git.tronto.net/scripts) for my Linux machine.

So I thought that it would be nice to take once in a while one of these
manual pages, read it, and share what I learned with other people.
Hence I decided to start this blog-series: "The man page reading club".

## Nuclear Apocalypse

I tried to find a nice setting for this series, a funny story to introduce
each of these technical posts, but I could not come up with any good idea.
Luckily, a couple of weeks ago I read the short post
[OpenBSD is the Perfect OS post Nuclear Apocalypse](https://confuzeus.com/shorts/openbsd-nuclear-apocalypse/)
and I found it to be exactly what I was looking for!

*So here you are, in a cozy underground bunker during a Nuclear
Apocalypse. There is enough food and electricity for everyone, but
of course no Internet. After a couple of days of social chit-chat
with your new roommates you find out that you have pretty much
nothing in common with them, so you turn to your trusty laptop and
you install OpenBSD 7.1 - the last version released before the apocalypse.*

```
From: deraadt@do-not-reply.openbsd.org (Theo de Raadt)
Subject: Welcome to OpenBSD 7.1!
```

*Says your screen, after you login and type `mail`.*

```
For more information on how to set up your OpenBSD system, refer to the
"afterboot" man page.
```

*The what?*

```
If you are not familiar with how to read man pages, type "man man"
at a shell prompt and read the entire thing.
```

*Sounds like a good idea, let's do it!*

```
$ man man
```

## man(1)

*Follow along at [man.openbsd.org](https://man.openbsd.org/OpenBSD-7.1/man)*

The first interesting thing we see in this manual page is a thing called
*synopsis*:

```
SYNOPSIS
	man [-acfhklw] [-C file] [-M path] [-m path] [-S subsection]
	    [[-s] section] name ...
```

This explains how to invoke the `man` command. The parts within square brackets
are optional, and the other words such as `path` and `section` are going to be
explained later in this page.

A short description the tells us that `man` is used to display manual pages.
It is followed by a detailed explanation of what each option does.
Let's look at some of them!

```
-c	Copy the manual page to the standard output instead of using
	less(1) to paginate it.  This is done by default if the standard
	output is not a terminal device.
```
This option is not very interesting to use because of the last sentence:
it is the default behavior when you need it (for example, when you pipe
the output to another program). It is however interesting to read its
description, because it reveals a little detail of how `man` works.
Namely, that every time we open a man page we are also calling `less`!

```
-h	Display only the SYNOPSIS lines of the requested manual pages.
	Implies -a and -c.
```

This can be useful for commands with a more complicated syntax.

```
-k	A synonym for apropos(1).  Instead of name, an expression can be
	provided using the syntax described in the apropos(1) manual.
	By default, it displays the header lines of all matching pages.
```

This sounds like some kind of search function, like a post-nuclear Google.
Indeed, `man apropos` tells us:

```
NAME
	apropos, whatis - search manual page databases
```

The page `apropos(1)` is worth a read, but I won't write a dedicated post.
This utility supports searching by regular expressions and by "`mdoc` macros".
If you don't know what they are, worry not: it is all well explained in
`apropos(1)`. The page also contains a lot of examples, which is always
appreciated.

Now back to `man man`!

```
[-s] section
	Only select manuals from the specified section. The currently
	available sections are:

		1	General commands (tools and utilities).
		2	System calls and error numbers.
		3	Library functions.
		3p	perl(1) programmer's reference guide.
		4	Device drivers.
		5	File formats.
		6	Games.
		7	Miscellaneous information.
		8	System maintenance and operation commands.
		9	Kernel internals.
```
Manual pages are divided into sections: they are the mysterious numbers in
parentheses after a command's name, like in `less(1)`. There can be pages
with the same name in different sections, and with this option you can specify
which one you want. For example `man printf` shows the `printf(1)` page, for
the UNIX command with the same name, while `man -s 3 printf` shows the manual
page for the `printf()` C library function. The syntax for this option is
slightly unusual in that the `-s` itself is optional: `man 3 printf` does
the same as `man -s 3 printf`.

One might be tempted to think that if no section is specified, the page in the
lowest-number section is shown. However:

```
Within each directory, the search procedes according to the following list
of sections: 1, 8, 6, 2, 3, 5, 7, 4, 9, 3p. The first match found is shown.
```

The `man` program also behaves differently depending on the value of
some environment variables. For example

```
MANPAGER Any non-empty value of the environment variable MANPAGER is
         used instead of the standard pagination program, less(1).
         ...

PAGER    Specifies the pagination program to use when MANPAGER is not
         defined.  If neither PAGER nor MANPAGER is defined, less(1) is
         used.
```

It looks like the variable `MANPAGER` is read only by `man`, while `PAGER`
may be understood by other commands as well. But how do we set environment
variables? One way to do this is shown in the `EXAMPLES` section:

```
Read a typeset page in a PDF viewer:

	$ MANPAGER=mupdf man -T pdf lpd
```

Now you should complain, because I did not tell you about the `-T` option!
In fact I skipped this line:

```
The options -IKOTW are also supported and are documented in mandoc(1).
```

A quick look at the `mandoc(1)` page tell us that
the most interesting of these options are `-T`, which we have just seen,
and `-O`, which allows to tune some formatting settings. For example
```
man -O width=50 man
```
shows you a man page using only 50 columns, while
```
man -O tag=EXAMPLES man
```
shows you the `man(1)` page, but starting from the `EXAMPLES` section
(you can still scroll back up to the beginning of the page).

Back to `man man`.

```
STANDARDS
	The man utility is compliant with the IEEE Std 1003.1-2008 ("POSIX.1")
	specification.

	The flags [-aCcfhIKlMmOSsTWw], as well as the environment variables
	MACHINE, MANPAGER, and MANPATH, are extensions to that specification.
```

This means that all of the stuff we read in this manual page, except for the
very basic functionality of `man` - showing manual pages - is not
POSIX-standard, and might be different on other systems. Be sure to check
what your version of `man` does before assuming that it will behave the same
as the OpenBSD one!
I find it very nice that the OpenBSD man pages always tell you which parts
are standard (and thus you can expect to work in the same way on other
UNIX-like OSes) and which are OpenBSD-specific. It makes writing
portable scripts much easier!

## Conclusions

`man` is a straightforward utility and most of the time you are just going
to use it by typing `man command`. However, reading this page I was still
able to learn new stuff - such as the `-h` and `-O` options and the fact
that `apropos` supports searching by regular expressions and tags.
I hope you have learnt something new too.

As you can see I have skipped a lot of things, including all the parts
related to the `MANPATH`. This post does not want to
be a comprehensive tutorial on the `man` command, just a
survey of the subjectively most useful parts of the manual.

For the next post I will either take one of the pages that was referenced
here, such as `less(1)`, or dive into more exciting stuff with something
like `sh(1)`.

Stay tuned!

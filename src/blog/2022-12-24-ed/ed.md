# The man page reading club: ed(1)

I enjoyed writing a little introduction at the beginning of every
post of this series, but I am running out of ideas. I am not much
of fiction writer. I'll skip this time, maybe I'll get back to doing
it in the future.

For this episode I chose to explore ed,
[the standard editor](https://www.gnu.org/fun/jokes/ed-msg.en.html).
This little piece of software first appeared in the very first
version of UNIX, in the late '60s. Back then, the most common way
to interact with a computer was via a
[teletype](https://en.wikipedia.org/wiki/Teleprinter). This meant
that, in order to edit a file, you could not simply show a screenful
of text and modify it interactively.

As we will see in this post, the way you modify your text files
with ed is by running commands, as you would in your usual
[shell](../2022-09-13-sh-1).  You might wonder why in the world you
should be interested in using this over a more human-friendly text
editor. There are at least a couple of reasons:

1. You find yourself in a very limited environment (e.g. some ebedded
   OS) where ed is the only editor available.
2. You want to edit a text file as part of a shell script - you can
   find an example in my [last blog entry](../2022-11-23-git-host).

## ed(1)

*Follow along at
[man.openbsd.org](http://man.openbsd.org/OpenBSD-7.2/ed)*

The first section explains a few fundamental things.

First of all, ed can be invoked with a file as an argument.  The
given file is copied into a *buffer*, and changes are written to
it only when the user issues a `w` command.

ed reads every line the user inputs and tries to interpret it as a
command. The general form for an ed command is

```
    [address[,address]]command[parameters]
```

Where the (optional) addresses specify a range of lines over which
the command has to operate. See the **Line addressing** section
below for more info.

Some commands allow you to switch to *input mode*, where ed reads
text without trying to interpret it as a command - usually for the
purpose of inserting it in your file - until a line with a single
dot `.` character is read.

There are only two command line options for ed: `-s` to suppress
diagnostic messages and `-p prompt` to specify a prompt string for
its command line.

### Line addressing

Every command operates on one or more lines. The default is the
*current line*, which is usually set to be the last line affected
by the last command. For example, after opening a file, the current
line is set to its last line.

You can specify the line(s) on which a command shall operate by
prepending one or two *addresses* separated by a comma or a semicolon.
The difference is the following:

```
     Each address in a comma-delimited range is interpreted relative to the
     current address.  In a semi-colon-delimited range, the first address is
     used to set the current address, and the second address is interpreted
     relative to the first.
```

For example, let's say you are on line 3. Then the address range
`5,+4` selects the lines from 5 to 7 (3+4), while `5;+4` selects 5
to 9 (5+4).

But what is a valid address, actually? Besides simply specifying a
line number, there are a variety of ways to address line: For
example, `.` refers to the current line and `$` to the last line
of the file. As we have seen, you can also specify relative addresses
in the form `-n` or `+n`.  You can also search for a line containing
a specific patern:

```
     /re/    The next line containing the regular expression re.  The search
	     wraps to the beginning of the buffer and continues down to the
	     current line, if necessary.  The second slash can be omitted if
	     it ends a line.  "//" repeats the last search.
```

For more infor about regular expressions, see
[re_format(7)](http://man.openbsd.org/re_format)
(or perhaps my next blog entry?). Using question marks instead of
slashes (like this: `?re?`) searches backwards.

### Commands

ed offers a lot of commands to manipulate text. If you are familiar
with other UNIX editors such as vi or sed, you may recognize many
of them.

As usual, they are listed in alphabetic order in the manual page,
so I took the liberty of re-arranging them into groups. I'll have to
skip or just briefly mention some of them, otherwise I might just
as well copy the whole manual page here.

**Address-only commands**

Specifying an address only, without a command, changes the current
line to the (last) addressed line and it prints it. The default is
the next line, i.e. if you just press enter ed prints out the next
line and sets it as the current line.

**Printing lines**

The command `p` prints the addressed line. The command `n` does the
same, but it also prints line numbers. `l` is the same as `p`, but
special characters (e.g. new lines) are made visible.

Most commands accept a *print suffix* `p`, `l` or `n` that instructs
ed to print the last line affected by the command. Thus, the three
printing commands can be also seen as an *address-only command*
followed by a print suffix.

**Basic editing**

The commands `a` and `i` toggle *input mode* to let you insert text
after (**a**ppend) or before (**i**nsert) the last line addressed.
Usually you want to address a single line, often the current line,
when using one of these commands.

The commands `d` and `c` can be used to **d**elete or **c**hange
the addressed lines. The latter is equivalent to `d` followed by an
`a` command.

**Copying, moving and joining lines.**

The commands `t` and `m` operate on a range and take an extra single
address (which can be `0`) as a parameter, and copy (**t**ransfer)
or **m**ove the addressed lines to that location. For example the
command `2,4t0` will copy the 2nd, 3rd and 4th lines to the beginning
of the file.

If you want to join multiple lines in one you can use the `j` command.

**Text substitution**

The `s` command is one of the most powerful ed offers, but also one
of the most complex. It allows you to replace a piece of text, or
any arbitrary pattern defined by a regular expression, with whatever
you like.

It comes in three variants:

```
(.,.)s/pattern/text/
(.,.)s/pattern/text/g
(.,.)s/pattern/text/n
```

Where `pattern` is a regular expression and `text` is simple text.
The first form replaces only the first occurrence of `pattern` in
each selected line, while the second replaces every occurrence. In
the last form, `n` must be a number, and only the n-th occurrence
is replaced.

There are some special characters that can be used: for example, a
single `&` in `text` is equivalent to the currently matched text.
If `text` consists of a single `%`, the `text` argument of the last
`s` command issued is used.

You may escape any character in `text`, including newlines, by
prepending a backaslash. To avoid escaping slashes to death, keep
in mind that you can use any other character, for example a `|`,
instead of `/` in the `s` command.

Finally, a simple `s` command, without pattern or text, repeats the
last substitution issued.

Let's put this all together with a single example. We have a file
that looks like this:

```
This is the first line
Another line, called the second line
/A third line, with boundaries/
Let's make it four
```

And run the following ed commands:

```
1/s/t/T/
1/s/T/&&/g
2/s/l/%/
1,3s
3s|/|\||g
```

The result is:

```
TThis is TThe first lline
Another llline, called the second line
|A third lline, with boundaries|
Let's make it four
```

Understanding why you get this is left as an exercise for the reader ;-)

**Multiple commands on selected lines**

The commands `g` and `G` are also quite powerful. With

```
(.,.)g/pattern/command-list
```

you can specify a list of commands to be executed on every line
matching the regular expression `pattern`. The commands in the list
are each on their own line, ended with a backslash. The command `G`
is essentially an interactive version of `g`. Check the man page
for more details!

**Marks**

You can mark a line with a single lowercase letter (say x) using
the command `[address]kx`. What for, you might ask? Well, when
talking about addresses I omitted to tell you that you can also
refer to a marked line using `'x`.  You only have 26 marks at your
disposal, and one is only deleted when the line it marks is modified,
so use them wisely!

**Reading files and commands**

You can use the `r` command to insert the content of a file (with
`r filename`) or the output of a command (with `r !command`) after
the current line. This is the same as the `r` command of vi, which
I have discussed in a [previous blog entry](../2022-09-05-man-col).

**Undo**

Use the `u` command to undo the last command. Using `u` twice
undoes the undo.  No editing history for you, sorry.

**File management**

From inside ed, you can use `e filename` to open a new file (**e**dit),
`w` to save your changes to the current file (**w**rite) and `q`
to quit.  These commands have an upper-case variant (`E`, `W`, and
`Q`) that can be used to ignore errors (e.g. quit without saving).

The command `wq` can be used as a shortcut for saving and closing.

### ?

ed is infamously terse with its error messages. Indeed, whatever
error you make, you are going to be faced with the following
informative line:

```
    ?
```

But don't worry: the command `h` shows a more verbose description
of the last error. You can use the `H` command to toggle verbose
error messages for the whole session.

## An example session

Let's write an *Hello world* text file using ed!

Let's start by calling ed with a reasonable prompt, to make our
life easier.

```
$ ed -p 'ed > ' hellow.txt
```

And let's open a (new) file:

```
ed > e hellow.txt
```

Don't worry about the (unusually verbose!) error message. The file
does not exist yet, but it will be created when we save our work
with `w`.  Now let's add a line of text:

```
ed > a
Hello, wolrd!
wq

```

Wait, why is ed still open? And why is it not showing the `ed > `
prompt?  Oh right, we forgot to end the input mode by entering a
single dot!

```
.
ed >
```

Ok, now we are back in business. But we have to remove the `wq`
line we entered by mistake:

```
ed > /wq/d
```

Let's check that we have written what we intended to by printing
the content of the file:

```
ed > 1,$n
1       Hello, wolrd!
```

Oh no, there is a typo! No big deal, we can fix it:

```
ed > 1s/lr/rl/
```

And now that we are done, we can close our file:

```
ed > q
?
```

Wait, what's going on? Let's check:

```
ed > h
warning: file modified
```

Oh right, we need to save.

```
ed > wq
```

And now we are done!

## I/O redirection magic

As all other basic UNIX utilities, ed can be used non-interactively
by using input / output redirection. As an example, consider the
interactive session above. The input we fed to ed was:

```
e hellow.txt
a
Hello, wolrd!
wq
.
/wq/d
1,$n
1s/lr/rl/
q
h
wq
```

If we save (a stripped down version of) the text above in a file
called `edcommands.txt`

```
a
Hello, wolrd!
wq
.
/wq/d
1s/lr/rl/
wq
```

and run

```
$ ed -s hellow2.txt < edcommands.txt
```

We should obtain a file `hellow2.txt` identical to `hellow.txt`. I
say "should" because apparently there is a little caveat: when used
non-interactively, ed exits on the first error it encounters. This
also happens with the `No such file or directory` error that we get
at the beginning, if a file `hellow2.txt` does not exist yet. We
just have to create one in advance, for example with `touch
hellow2.txt`, and run again the ed command above.

## Conclusions

ed was designed in a time when the computer-human interaction was
a bit different from now, and it shows. However, its language is
pleasantly consistent: every action you want to perform is expressed
in the address-command-parameters form. This makes it easy to learn
and boring, which is a good thing. Such consistency is much harder
to achieve in the 2D graphical world - which includes
[TUIs](https://en.wikipedia.org/wiki/Text-based_user_interface).

At the beginning of the post I have mentioned two use cases for a
software like ed in the present day: being forced into a limited
environment and using it in non-interactive mode. But there is at
least another one: for visually impaired users, modern computer
interfaces are largely inaccessible, as they can't look at a wall
of text and pictures to figure out where the stuff they want to
work on is. On the other hand, an editor like ed does not overwhelm
users with visual output and does not require them to keep in mind
more than one line at the time. If you are interest in this topic
I highly suggest reading the article
[The command line philosophy](http://www.eklhad.net/philosophy.html)
by Karl Dahlke, the author of [edbrowse](https://edbrowse.org).

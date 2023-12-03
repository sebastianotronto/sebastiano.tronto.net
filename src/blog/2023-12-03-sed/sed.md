# UNIX text filters, part 2 of 3: sed

*This post is part of a [series](../../series)*

After the first (or second, depending on how you prefer to call ordinals
in a 0-based system) episode on [`grep`](../2023-08-20-grep) we are ready
to look at `sed`, the *stream* editor!

You can think of `sed` as the weird cousin of [`ed`](../2022-12-24-ed),
the standard editor, as they share much of their syntax. You could
argue that `ed` is the weirder one, though.

On the other hand, the *stream* part of `sed` is very peculiar,
and I prefer to think about it as a sort of `grep` that can not
only pick the desired lines, but also edit them. You can decide
which point of view you prefer after reading this post!

## Basic usage

The way sed works is easy to summarize: text is read from standard input
(or from a given file) line by line, a command is applied to each line,
and the output is printed. Pretty much the same as for `grep`, except
for the *a command is applied* part. Therefore, the power of `sed`
comes from the available commands.

A typical sed command is run like this:

```
$ sed [options] 'command' [file ...]
```

Instead of diving into the formal definition of the
grammar of sed, or following the
[manual page](https://man.openbsd.org/sed),
let's start with the basics.

### Replacing text: the `s` command

Most of the times I use `sed`, and pretty much every time I use it
in an interactive shell, I just use the *substitution command* `s`.
If you have used `sed` in the past, chances are you have used `s`.

As a basic example, say you want to replace all occurrences of the word
"dog" with the word "cat". Then you can use `sed s/dog/cat/g`:

```
$ echo "I love dogs! My dog is cute" | sed 's/dog/cat/g'
I love cats! My cat is cute
```

If you omit the `g` at the end, only the first occurrence on each line
is replaced:

```
$ echo "I love dogs! My dog is cute
> Another dog line" | sed 's/dog/cat/g'
I love cats! My dog is cute
Another cat line
```

### Regular expressions

Plain text substitution works fine in educational examples, but it may
fail in real-world use cases:

```
$ echo "Dogs are cool. My dog is called Doge." | sed 's/dog/cat/g'
Dogs are cool. My cat is called Doge.
```

Luckily, regular expressions come to rescue! The first part of
a substitution command can be a (basic) regular expression. Most
versions of `sed` also support extended regular expressions via
the `-E` or `-r` options, though this is not mandated by
[POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sed.html).
Check your local manual page, and see also the section **BSD sed vs GNU sed**
below. For more info on regular expressions,
see [part 0](../2023-06-16-regex) of this series.

Back to our example. We can use:

```
$ echo "Dogs are cool. My dog is called Doge." | sed 's/[Dd]og/cat/g'
cats are cool. My cat is called cate.
```

Ok, we had one problem and we solved it. Now we have two problems.

One problem is that the name of the dog was also canged, as it contains the
word "Dog". This can be fixed by using a more complicated regular
expression that matches word boundaries. With GNU `sed` (the default
in most Linux distros) the regular expression that matches dog or
Dog only when it is a word is `\b[Dd]og\b`, while on most BSD systems
it is `[[:<:]][Dd]og[[:>:]]`. As far as I know, none of these is
mandated by POSIX; avoid them if you are writing portable shell
scripts.

The second problem is that the replacement text does not respect
the replaced text's capitalization. One simple way to solve this
is using multiple commands.

### Multiple commands

A `sed` command can be a composition of multiple commands. This is
true not only for `s`, but also for all other commands that we have
not seen yet.

Commands are concatenated with a semi-colon. For example:

```
$ echo "Dogs are great, I love dogs!" | sed 's/dog/cat/g ; s/Dog/Cat/g'
Cats are great, I love cats!
```

Concatenated commands are applied, in the order they appear, to
every line.  Beware that subsequent commands operate on the modified
line! For example:

```
$ echo "dogs and cats" | sed 's/dog/cat/g ; s/cat/dog/g'
dogs and dogs
```

There are other ways of giving `sed` multiple commands to execute
for each line. Similarly to `grep`, you can use `-e COMMAND -e ...`
to list more commands directly, or `-f FILE` to let sed read the
commands from a file.

### Little trick: change the separator to avoid escaping slashes

For the `s` command, the slash `/` is a special character; if you
want to use it in your regular expression or in your substitution
text, you need to escape it with a backslash `\`. For example, to
change all the slashes to backslashes you can use something like:

```
sed 's/\//\\/g'
```

But you don't have to use the slash as a separator - actually, you can
use any character other than a backslash or a newline. If you use a
different separator, you don't need to escape slashes - though you do
need to escape whatever separator you choose instead.  For example,
to perform the same substitution as above you can use a pipe `|` as
a separator:

```
sed 's|/|\\|g'
```

A bit better, but you still need to escape backslashes.

### Addresses

In general, `sed` commands have the following form:

```
[address[,address]]function[arguments]
```

Addresses specify the range of lines of the text on which the given
function is applied. If no address is given, the command is applied
to all lines. With only one address the command applies to that
single line. Addresses can be also a dollar sign `$`, matching the
last line, or a regular expression  surrounded by slashes (e.g.
`/re/`), matching all the lines that match the expression.

Does this remind you of something? It should, if you have read my
[post on `ed`, the standard editor](../2022-12-24-ed). Addresses in
`sed` work in the same way, so I will cut it short here.

As an example, a few days ago I wanted to add a tab to every line
of a snippet of code, except for the first one. I used this:

```
$ sed '2,$ s/^/TAB/'
```

With a literal tab character (by pressing `Ctrl+V Ctrl+TAB`) instead
of `TAB`. With GNU `sed` one can use `\t` instead.

*(Recall that `^` means "the beginning of a line", so the command
above inserts `TAB` at the beginning of each line from the second
one to the last.)*

### More commands

With `sed`, one can do more than just find & replace. Here are
some of its other (simple) commands:

**Delete**: `d`. You can use it on a range of lines, the default being
every line. Unexpectedly useful trick: you can use `| sed 'd'` instead of
`> /dev/null' to suppress all standard output!

**Change**: `c`. The syntax is a bit different from what we have seen
so far. For example, to replace every line that ends with `0` or `5`
with `bar` you can use

```
$ sed '/[05]$/ c\
bar
'
```

Notice the newline before and after `bar`.

The `c` command also behaves a bit differently from other commands
when given a range of addresses, because it replaces the whole range
instead of operating on each addressed line one by one.

**Insert**: `i`. The syntax is the same as for the `c` command, but
text is just inserted, without deleting the current line.

**Print**: `p`. Lines are printed by default, but if you use the `-n`
option they are not. Useless trick: `sed -n '/RE/p'` is equivalent to
`grep 'RE'`!

**Quit**: `q`. This can be used to terminate sed earlier instead of,
for example, piping its result or its input through `head`. But it is
mostly known for the meme "`head` is
[harmful](https://harmful.cat-v.org/software/), use `sed 11q` instead".

## Advanced sed

So far I have only described "simple" `sed` commands that operate line
by line. These was pretty much all I knew about `sed` before writing
this post. But then I found out that there are more advanced features,
and I think they are worth mentioning.

### Pattern space and hold space

Reading the OpenBSD manual page, right after the general description
of how `sed` works, you can read the following sentence:

```
Some of the functions use a hold space to save all or part of the pattern
space for subsequent retrieval.
```

So, let's see how this *hold space* works.

There are 5 commands that manipulate or otherwise use the hold space:
`g`, `G`, `h`, `H` and `x`. The command `g` replaces the contents of the
pattern space with that of the hold space, while `G` appends the hold
space to the pattern space (with a newline character in between). The
commands `h` and `H` do the same, but in the other direction (pattern
space to hold space); you can memorize them as the initials of "hold"
and "get".  Finally, `x` swaps the contents of the two spaces.

Ok, let's see an example. It's a bit hard for me to come up with a
concrete one because I have never used this feature, so let's try
a "puzzle example". Say you want to replace every empty line of a file
with the content of the last line that started with a `>` character.

For example, if you input this text:

```
> To avoid edge cases, say the first line alway starts with >
This is
a paragraph

Another paragraph

> Now use this line
After this line

> Ok now this
> Actually, this

The end.
```

You want to obtain:

```
> To avoid edge cases, say the first line alway starts with >
This is
a paragraph
> To avoid edge cases, say the first line alway starts with >
Another paragraph
> To avoid edge cases, say the first line alway starts with >
> Now use this line
After this line
> Now use this line
> Ok now this
> Actually, this
> Actually, this
The end.
```

To do this, you can use the following command:

```
$ sed `/^>/h; /^$/g'
```

As a reminder: We are using regular expressions to specify address;
`^` matches the beginning of a line and `$` matches the end of a line,
so `^$` matches a blank line.

Yeah, this specific example is quite useless. Do you have any better
example of use of the hold space in `sed`? Let me know!

### Branching

I'll cover this very briefly because, like for the previous part about
the hold space, I have never used it in practice.

If you are writing a longer `sed` script, you may be interested in
(conditionally) jumping to different parts of your code. To do this,
you can set a label with with `: label` and branch to it with `b label`.
You can jump to a `label` conditionally, depending whether there has
been a text substitution or not since last reading an input line, using
`t label`.

As an example: say you want to replace some text, but also add some
kind of log of your work - for example, a line of text explaining that
a replacement happened. Then you can do something like this:

```
$ sed 's/dog/cat/g; t log; b end; : log; { i\
! At least one substitution was performed in the next line:
}; : end'
```

In the code above we set two labels, `log` just before the command
that adds the log line and `end` at the end of the `sed` script.  If a
substitution happens, we jump to `log`; if we do not jump to `log`,
then next instruction makes us jump directly to the `end`. Kinda like
programming with `goto`s!

In this example I had to wrap the `i` command in curly braces `{}`,
otherwise the semicolon needed to separate it from `: end` command would
have been treated as part of the text to be inserted.

## BSD sed vs GNU sed

To conclude this post, I would like to highlight some of the differences
between the
[GNU implementation of `sed`](https://www.gnu.org/software/sed/manual/sed.html),
which is found in most Linux distros except
[Alpine](https://alpinelinux.org) and a few others, and the BSD version
found in many
[BSD operating systems](https://en.wikipedia.org/wiki/Berkeley_Software_Distribution),
including MacOS. I am not sure all the BSD versions have the same features,
but the main points discussed in this section should hold for all of them.

Those listed below are all the differences I know of.  If you know
more, feel free to send me an email and I'll add them here!

### BSD sed is more minimal

In general BSD sed is more barebones, offering little more than POSIX mandates.
If something can be done with BSD `sed` it can also be done with
the GNU version, but the converse is not always true.

GNU `sed` has some extra options, some more commands and an alternative
syntax for some of the commands we have seen in this post - such as `c`
and `i`. See
[the Extended Commands section](https://www.gnu.org/software/sed/manual/sed.html#Extended-Commands)
of the GNU manual for details.

### Escape sequences

In GNU `sed` one can use escape sequences such as `\n` and `\t` not
only in regular expressions, but also in text - for example, in the
replacement part of an `s` command. In BSD `sed`, this is not possible:
one must insert literal special characters in their command - for example
by pressing `Ctrl+V Ctrl+TAB` or by breaking a command with a newline,
which is a bit ugly in my opinion.

Escape sequences can be used in regular expressions in both the GNU
and in the BSD version, see the section **Sed Regular Expressions** in the
[OpenBSD](https://man.openbsd.org/sed)
or
[FreeBSD](https://man.freebsd.org/cgi/man.cgi?query=sed&apropos=0&sektion=0&manpath=FreeBSD+14.0-RELEASE+and+Ports&arch=default&format=html)
manual pages for details.

### Regular expression special syntax

Both versions of `sed` let you choose between basic and extended regular
expressions with the `-E` (or `-r`) flag, but the GNU version offers
some new sets of characters not present in BSD.

We have already seen `\b` (word boundary); others include `\w` (word characters,
i.e. letters, digits or underscores) and `\s` (whitespace). See
[the GNU manual](https://www.gnu.org/software/sed/manual/sed.html#regexp-extensions)
for a full list.

## Until next time... sort of

It took me a long time to write this, but I am personally quite happy
with the result.  This is not a complete `sed` tutorial by any means,
and the set of examples is not as comprehensive as the interested reader
might like, but I think it is a decent overview.

The next post in the series is supposed to be about `awk`, but I decided
to take a small detour and talk about some other simple, special-purpose
text filtering commands, such as `tr`, `head`, `fmt` and so on. Expect
some short posts in this series before part 3 - after all, there are
[uncountably many](https://en.wikipedia.org/wiki/Uncountable_set)
numbers between two and 3!

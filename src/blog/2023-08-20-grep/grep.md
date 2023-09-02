# Unix text filters, part 1 of 3: grep

After [the preliminary post on regular expressions](../2023-06-16-regex),
we are ready to begin this series on *text filters*.

This time we'll explore `grep`, the most simple kind of filter:
given a bunch of lines of text, print out only those that match a
certain criterion.

I will only describe a few basic options. All that I mention here
is POSIX-standard, with the exception of the option `-o`. This means
that the content of this post is valid in pretty much any UNIX-like
OS, but check your manual pages before copy-pasting my code - I can
always make mistakes.

Without further ado, let's dive in!

## Standard usage

If you are familiar with how (UNIX) programs read from standard
output and write to standard output, the idea behing `grep` is
easily explained: the command

```
$ grep PATTERN
```

will read lines from standard input and write to standard output
only those that contain the given `PATTERN`. If you specify file
names after the pattern

```
$ grep PATTERN file1 file2 ...
```

`grep` will read those files instead of standard input. The `PATTERN`
can also be a [regular expression](../2023-06-16-regex).

In other words, you can use `grep` to look for certain pieces of
text in a file or in the output of another command. If you do not
understand all of this is about, start reading from the **Examples**
section below to get an idea.

Now let's see how you can tune `grep`'s behavior to your needs.

### What to match: `-i`, `-v`

A common use of `grep`, especially for non-programming tasks, is
to look for occurrences of a specific word in a long text. In
this case one usually does not care if the word is all lowercase
or capitalized, for example because at the beginning of a sentence.
If you find yourself in this situation, you can use the `-i` option
to make `grep` case-insensitive.

Sometimes it easier to spell out what you *do not* want to match -
for example, say you want all non-empty lines of a given file. In
this case you can use the `-v` option to invert the behavior of
`grep`, such as:

```
$ grep -v "^$" file
```

Here `"^$"` is a regular expression that matches all lines where the
beginning of the line (in regex language, `^`) is immediately followed
by the end of the line (`$`); in other words, empty lines.

### More on patterns: `-E`, `-e`, `-F`, `-f`

Up to now I have not specified what *kind* of regular expression
`grep` uses. By default it uses basic regular expressions, but it
uses extended regular expressions if called with the `-E` option.
Equivalentrly, you can use the command `egrep`.  If you want to
turn off regular expressions altogether, you can use `grep -F` (or
`fgrep`).

If you want to select lines that match *any* of a number of patterns,
you can use the `-e` option:

```
$ grep -e PATTERN1 -e PATTERN2 -e ... [file1 file2 ...]
```

Alternatively you can write your pattern in a file, one per line,
and use:

```
$ grep -f PATTERN_FILE [file1 file2 ...]
```

### Grepping multiple files: `-l`, `-n`

Sometimes I use `grep` to find occurrences of a certain string in
a bunch of files, for example with

```
$ grep "word" *
```

When used with multiple input files like this, `grep` will precede
each output line with the name of the file that contains it. If the
option `-n` is used, the line number is also shown. If `-l` is used,
only the name of the file is shown, and each file is shown at most
once.

If you do not want to print the file names at all, you can always
`cat` into `grep`:

```
$ cat file1 file2 ... | grep
```

But if anyone asks, you did not learn this from me - UUOC (Useless
Use Of Cat) is a considered a crime in some circles.

*Update 2023-09-02: I have just discovered that the the `-h` option can
be used to hide the file names, so no need for piping cats. However,
though present both in OpenBSD's and GNU's versions of `grep`, this
option is not POSIX standard.*

### Matching only part of a line: `-o`

You may not always want the *full line* containing a piece of text.
Sometimes you just want a specific part of a line, and you know
exactly how to match it with a regular expression. In this case you can
use the `-o` option - we'll see an example below.

The `-o` is not POSIX-standard. It is ubiquitous though, and it
should be present in pretty much any version of `grep`.

## Examples

Now that we now the basics, let's see some exciting applications
of `grep`!

Nah, I am kidding, they are not exciting. But they are useful. Boring,
but useful.

### Filter command output

Probably my first use of `grep` was to filter out irrelevant part of
some command's output. Say for example you are troubleshooting a
problem with your webcam: you can use `dmesg` to check what your
operating system knows about it, but most of the output is useless
to your specific problem.  No worries, you can pipe `dmesg` into
`grep`:

```
$ dmesg | grep video
acpivideo0 at acpi0: VGA_
acpivout0 at acpivideo0: LCDD
uvideo0 at uhub0 port 6 configuration 1 interface 0 "JMICRON TECHNOLOGIES CO., LTD. USB2.0 UVC VGA WebCam" rev 2.00/2.04 addr 2
video0 at uvideo0
```

### Look stuff up in files

Sometimes you may want to search something in a bunch of files.
Let's say for example I want to check in which of my old blog posts
I have mentioned "Linux":

```
$ grep -l Linux src/blog/*/*
src/blog/2022-05-29-man/man.md
src/blog/2022-08-14-website/website.md
src/blog/2022-09-10-netbooks/netbooks.md
src/blog/2023-01-28-windows-desktop/windows-desktop.md
src/blog/2023-02-25-job-control/job-control.md
src/blog/2023-02-25-job-control/jobs-diagram.pdf
```

Or say I am working on one of my software projects, and I do not remember where
a certain function is defined:

```
$ grep -n "^apply_move(" src/*.c
src/moves.c:206:apply_move(Move m, Cube cube)
```

*Note: the command above works because, when I write C code, I write
function names on a newline. See also
[this older post](../2022-06-12-shell-ide-sed) for another example
that takes advantage of this, this time using `sed`.*

### Grepping URLs

Looking for URLs in a piece of text is a common enough operation
for me that I saved it into a [script](https://git.tronto.net/scripts)
for ease of use, that I called `urlgrep`.  URLs can be complicated,
so for a long time I used a regular expression copied from somewhere
on the internet.

Now now that I am more familiar with `grep` and regular expressions, I have
written my own - it does not work perfectly, but at least I understand it
and I can keep tweaking it if I find errors.

Let's build it together! What does a URL look like? It usually starts with
either a *protocol* followed by a colon, or with `www.`. Then a bunch of
valid characters follow. There are probably more rules to it, but to keep
is simple we can start like this (using *extended* regular expressions):

```
regex="(($protocols):|www\.)[$valid_chars]+"
```

For protocols we can use

```
protocols='http|https|ftp|sftp|gemini|mailto'
```

I have thrown `mailto` in there because it is quite common in links web
pages. The valid characters are:

```
valid_chars="][a-zA-Z0-9_~/?#@!$&'()*+=.,;:-"
```

(Yes, these ones I actually copied somewhere online). Finally we can
find all URLs with

```
$ egrep -o "$regex"
```

As I mentioned above there are some problems with this. For example
if a URL is not terminated by a space, the characters following it
may be grepped too. For example:

```
$ urlgrep <src/blog/2022-05-21-blogs/blogs.md
https://en.wikipedia.org/wiki/Hypertext).
https://caseymuratori.com/blog_0031)
https://en.wikipedia.org/wiki/Netbook)
https://developer.mozilla.org/en-US/Learn)
https://www.romanzolotarev.com/website.html).
```

This is not *technically* a problem, because parentheses and dots are allowed
as part of a URL. But it is *practically* a problem, because most URLs will
only contain matching pairs of parentheses.

## Conclusion

`grep` is a must-know for anyone who wants to be proficient with the
UNIX command line. Luckily, it is also pretty easy to learn.

Moreover, being familiar with `grep` makes it easy to learn more
advanced tools, such as `sed` and `awk`: the "read one line, process
it, print something" idea is common to all three of them.

Stay tuned for the part 2: `sed`!

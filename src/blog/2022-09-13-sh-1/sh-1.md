# The man page reading club: sh(1) - part 1: shell grammar

*This post is part of a [series](../../series)*

After [last time's short entry](../2022-07-07-shutdown) and a
relatively long hiatus, we are back in business with a big one!

## A new day

*After a good night of sleep and a cup of whatever people call
coffee in the post-apocalypse, you turn your computer back on. You
would like to learn more stuff, but you are unsure where to start
from. You vaguely remember a `man afterboot` being mentioned
somewhere, so you start from there.*

```
DESCRIPTION
   Starting out
     This document attempts to list items for the system administrator to
     check and set up after the installation and first complete boot of the
     system.  The idea is to create a list of items that can be checked off so
     that you have a warm fuzzy feeling that something obvious has not been
     missed.  A basic knowledge of UNIX is assumed, otherwise type:

	   $ help
```

*You do have some knowledge of UNIX, someone might call it "basic",
but you believe "scattered" is a more appropriate adjective. In any
case, a review won't hurt. You type the command*

```
$ help
```

*And a manual page shows up. You could have typed `man help` instead
to get the same result. After skimming throught the introduction,
you discover something worth digging into.*

```
   The Unix shell
     After logging in, some system messages are typically displayed, and then
     the user is able to enter commands to be processed by the shell program.
     The shell is a command-line interpreter that reads user input (normally
     from a terminal) and executes commands.  There are many different shells
     available; OpenBSD ships with csh(1), ksh(1), and sh(1).  Each user's
     shell is indicated by the last field of their corresponding entry in the
     system password file (/etc/passwd).
```

*You have a look at `/etc/passwd` and you see that your user's shell
is `ksh`. So you type `man ksh` and start reading.*

```
DESCRIPTION
     ksh is a command interpreter intended for both interactive and shell
     script use.  Its command language is a superset of the sh(1) shell
     language.
```

*You are quite rusty on the Math jargon - some of your friends used
to talk like that in real life, but you never bothered to learn -
but "superset" sounds like "it is larger than". Is this another
[`less` vs `more`](../2022-06-08-more) kind of thing, where one
command is just a simpler version of the other? Let's see what
`sh(1)` has to say about it*

```
     This version of sh is actually ksh in disguise.
```

*Ah-ah! Exactly as you thought. Just like the other time, you prefer
to go with the simpler version. Enough of this "fun is precious"
bullshit, you want to learn as soon as possible!*

## sh(1)

*Follow along at [man.openbsd.org](https://man.openbsd.org/OpenBSD-7.1/sh)*

Despite having less features than more complex shells like `ksh`
or `bash`, the manual page for `sh` is still very long. So we are
going to split it into two or more parts.

The main sections I intend to cover are BUILTINS, SHELL GRAMMAR and
COMMANDS.  Parts of SPECIAL PARAMETERS and ENVIRONMENT are quoted
and explained in other sections, so I am probably going to skip
these too.  I think we can skip the invocation options, since we
are mostly going to run our shell implicitly when logging in or
when executing a script. Finally, COMMAND HISTORY AND COMMAND LINE
EDITING is best explained after we cover `vi(1)`, so we'll skip
that too. This still leaves with a big chunk of the man page to
discuss.

A technical manual page is not a novel: the content is often laid
out in an arbitrary order, to make it easier to find what you are
looking for (e.g. in alphabetic order) and not to make a top-to-bottom
read entertaining. So I felt like reordering things a bit: not only
I will cover the sections in a differ order than what you find in
the manual page, but I will also shuffle the content of each section
when it make sense to me.

Since I am very much a theoretical, grammar-first kind of person,
my totally subjective best way to dive into this is starting with
the grammar section!

## Part 1: shell grammar

After reading the input, either from a file or from the standard
input, `sh` does the following:

1. It breaks the input into words and operators (special characters).
2. It expands the text according to the rules in **Expansion** section below.
3. It splits the text into commands and arguments.
4. It performs input / output redirection (see the **Redirection** section below).
5. It runs the commands.
6. It waits for the commands to complete and collects the exit status.

The next three sub-sections (Redirection, Expansion and Quoting) are found
in the exact opposite order in the manual page.

### Redirection

Together with *piping*, which we will cover in one of the next episodes,
redirection is one of the key features of UNIX.

```
	Redirection is used to open, close, or otherwise manipulate files, using
	redirection operators in combination with numerical file descriptors.  A
	minimum of ten (0-9) descriptors are supported; by convention standard
	input is file descriptor 0, standard output file descriptor 1, and
	standard error file descriptor 2.
```

If the number `[n]` is not specified, it defaults to either `0`
(standard input) or `1` (standard output) depending if the angled
brackets are pointing to the left or to the right.

The main redirectors are `[n]<file`, to read input from `file`
instead of typing it in manually, and its counterpart `[n]>file`
to write standard output (or whatever is described by the file
descriptor `[n]`) to file. For example, if you want to log every
error message of `command` to `file.log`, you can use

```
$ command 2>file.log
```

The `[n]>>file` redirector is similar, but it appends stuff to
`file` instead of overwriting it. Both `>` and `>>` create the file
if it does not exist.

There is also `[n]<<`:

```
[n]<<  This form of redirection, called a here document, is used to copy
       a block of lines to a temporary file until a line matching
       delimiter is read. When the command is executed, standard input
       is redirected from the temporary file to file descriptor n, or
       standard input by default.
```

For example

```
$ cat <<BYEBYE
> one line,
> another line
> and so on
> BYEBYE
```

Outputs those three lines. It is useful in shell scripts, when you
want to output a block of text. The variant `[n]<<-` strips out
`Tab` characters.

Another useful one is `[n]>&fd`, which "merges" the file descriptors
`[n]` and `fd`. For example, if you want to make your command
completely silent, you can merge standard output and standard error
and redirect them both to `/dev/null` with

```
$ command >/dev/null 2>&1
```

### Expansion

There are essentially five kinds of expansion that the shell performs:
tilde expansion, parameter expansion, command expansion, arithmetic
expansion and filename expansion.

**Tilde expansion** is quite straightforward, so let's just quote
the man page:

```
     Firstly, tilde expansion occurs on words beginning with the `~'
     character.	 Any characters following the tilde, up to the next colon,
     slash, or blank, are taken as a login name and substituted with that
     user's home directory, as defined in passwd(5).  A tilde by itself is
     expanded to the contents of the variable HOME.  This notation can be used
     in variable assignments, in the assignment half, immediately after the
     equals sign or a colon, up to the next slash or colon, if any.

	   PATH=~alice:~bob/jobs
```

**Parameters** can be variable names or special parameters. Variables
can be assigned with the simple syntax `variable=value` and their
value can be "accessed" with `$variable`. In case of ambiguity you
need to enclose the variable name in curly braces `{}`: say you
want to type the string `subroutines` and you have a variable
`prefix=sub`. The shell will complain at a `$prefixroutines` about
there being no variable with such name, so you have to use
`${prefix}routines`.

The most useful special parameters are:

* Numbers `1`, `2`, `3`... that refer to the *positional parameters*:

```
    These parameters are set when a shell, shell script, or shell function is
    invoked.  Each argument passed to a shell or shell script is assigned a
    positional parameter, starting at 1, and assigned sequentially.
```

* The number `0`, which refers to the name of the shell or of the shell
  script being executed.
* The symbols `@` and `*` which expand to all positional parameters
  at once; they behave differently when enclosed in double quotes:
  with `"$@"` the parameters are split into fields, with `"$*"` they are not.

There are some useful constructs to expand a parameter in special
ways.  The constructs `${parameter:-[word]}` and `${parameter:=[word]}`
expand to `[word]` if `parameter` is unset or empty, with the second
one also assigning the value `[word]` to `parameter` for subsequent
use. Instead, `${parameter:+[word]}` expands to `[word]` *unless*
`parameter` is unset or empty, in which case it expands to the empty
string. In all these cases, if the colon is omitted `[word]` is
substituted only if `parameter` is unset (not if it is empty).

Another useful one is `${#parameter}`, which expands to the length
of `parameter`. Finally there are some constructs that can be used
to remove prefixes or suffixes from the expansion of a parameter:

| Construct | Effect |
|:---:|:---:|
| `${parameter%[word]}` | Delete smallest possible suffix matching word |
| `${parameter%%[word]}` | Delete largest possible suffix matching word |
| `${parameter#[word]}` | Delete smallest possible prefix matching word |
| `${parameter##[word]}` | Delete largest possible prefix matching word |

What unfortunately is not explained in the man page of `sh(1)` (but
can be found in that of `ksh(1)`) is that `[word]` in this case can
be a *pattern*.  See [glob(7)](https://man.openbsd.org/OpenBSD-7.1/glob.7)
for a description of patterns, which are the same that are used for
filename expansion (with the exception that slashes and dots are
treated as normal characters).

For example, using `*` which means "any sequence of zero or more
characters":

```
$ x="we can,separate,stuff,with commas"
$ echo ${x#*,}
separate,stuff,with commas
$ echo ${x##*,}
with commas
```

Then there is **command expansion**:

```
     Command expansion has a command executed in a subshell and the results
     output in its place.  The basic format is:

	   $(command)
     or
	   `command`

     The results are subject to field splitting and pathname expansion; no
     other form of expansion happens.  If command is contained within double
     quotes, field splitting does not happen either. 
```

**Arithmetic expansion** uses the syntax `$((expression))`. An
`expression` can be a combination of integers (no floating point
arithmetic in the shell!), parameter names and the usual arithmetic
operations. I won't copy them here; if you are familiar with C or
C-like languages, you can use pretty much all the operations you
are used to, including logic operations (resulting in 0 or 1),
assignment operations like `+=` and bitwise operations like `~`,
`&` and `<<`.  Even the *ternary if* `expression ? expr1 : expr2`
is available.

Finally, **filename expansion** uses the aforementioned rules of
[glob(7)](https://man.openbsd.org/OpenBSD-7.1/glob.7) to expand
filenames.  To sum them up:

* As we have already seen, `*` expands to any sequence of characters.
* `?` matches any single character.
* `[..]` matches any character in place of the double dot, or any
  character *not* listed if the first is an exclamation mark.
* `[[:class:]]` matches any character of a certain class; for example
  `class` could be `alnum` for alphanumeric characters or `upper` for
  uppercase letters.
* `[x-y]` matches any character in the range between `x` and `y`.

To illustrate what all of this means, check this out (the command `ls` is
used to list all files in the current directory):

```
$ ls
box                  file3                mbox                 typescript
count_args.sh        file4                mnt                  videos
file1                git                  music
file2                mail                 phone-laptop-swap
$ echo m*
mail mbox mnt music
$ echo m???
mail mbox
$ echo file[2-4]
file2 file3 file4
```

### Quoting

Sometimes we may want to write some of the special characters
described above, such as dollar signs, without their special meaning.
You can do so by *escaping*, or *quoting* them. There are essentially
three ways to quote a character or a group of characters:

* Backslash:

```
     A backslash (\) can be used to quote any character except a newline.  If
     a newline follows a backslash the shell removes them both, effectively
     making the following line part of the current one.
```

This means that a backslash can also effectively be used to split
long lines into multiple lines, for example for ease of editing a
shell script.

* Single quotes:

```
     A group of characters can be enclosed within single quotes (') to quote
     every character within the quotes.
```

* And double quotes:

```
     A group of characters can be enclosed within double quotes (") to quote
     every character within the quotes except a backquote (`) or a dollar sign
     ($), both of which retain their special meaning.  A backslash (\) within
     double quotes retains its special meaning, but only when followed by a
     backquote, dollar sign, double quote, newline, or another backslash.  An
     at sign (@) within double quotes has a special meaning (see SPECIAL
     PARAMETERS, below).
```

Basically the difference between single and double quotes is that
the former turn literally everything they enclose into simple text,
while the latter still parse and expand some special characters
(for example the dollar sign `$` for variables).

As an addition, remember that anything enclosed in single or double
quotes is considered a single field (word). This was briefly mentioned
in the Expansion section, but I skipped it. To illustrate what I
mean, let's write a short script and run it first with some words
as arguments and then with the same words enclosed in quotes:

```
$ echo 'echo $#' > count_args.sh
$ count_args.sh how many words are there
5
$ count_args.sh "how many words are there"
1
```

## Until next time

This was a very long post, but it made sense to keep all the grammar
rules together. To finish this manual page we are going to need
another long post, or two shorter ones.

See you next time!

*Next in the series: [sh(1) - part 2: commands and builtins](../2022-09-20-sh-2)*

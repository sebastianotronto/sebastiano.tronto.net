# UNIX text filters, part 0 of 3: regular expressions

One of the most important features of UNIX and its descendants, if
not *the* most important feature, is input / output redirection:
the output of a command can be displayed to the user, written to a
file or used as the input for another command seamlessly, without
the the program knowing which of these things is happening. This
is possible because most UNIX programs use *plain text* as their
input/output language, which is understood equally well by the three
types of users - humans, files and other running programs.

Since this is such a fundamental feature of UNIX, I thought it would
be nice to go through some of the standard tools that help the user
take advantage of it. At first I thought of doing this as part of
my *man page reading club* series, but in the end I decided to give
them their own space. My other series has also been going on for
more than a year now, so it is a good time to end it and start a
new one.

Let me then introduce you to: **UNIX text filters**.

## Text filters

For the purpose of this blog series, a *text filter* is a program
that reads plain text from standard input and writes a modified,
or *filtered* version of the same text to standard output. According
to the introductory paragraph, this definition includes most UNIX
programs; but we are going to focus on the following three, in
increasing order of complexity:

* grep
* sed
* awk

In order to unleash the true power of these tools, we first need
to grasp the basics of
[regular expressions](https://en.wikipedia.org/wiki/Regular_expression).
And what better way to do it than following the dedicated
[OpenBSD manual page](https://man.openbsd.org/OpenBSD-7.3/re_format)?

## (Extended) regular expressions

Regular expressions, or regexes for short, are a convenient way to
describe text patterns. They are commonly used to solve genering
string matching problems, such as determining if a given piece
of text is a valid URL. Many standard UNIX tools, including the three
we are going to cover in this series, support regexes.

Let's deal with the nasty part first: even within POSIX, there is
not one single standard for regular expressions; there are at least
two of them: Basic Regular Expressions (BREs) and Extended Regular
Expressions (ERE). As it always happens when there is more than one
standard for the same thing, other people decided to come up with
another version to replace all previous "standards", so we have also
[PCREs](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions),
and probably more. [Things got out of hand quickly](https://xkcd.com/927).

In this post I am going to follow the structure of
[re_format(7)](https://man.openbsd.org/OpenBSD-7.3/re_format) and
present *extended* regular expresssions first. After that I'll point
out the differences with *basic* regular expressions.

The goal is not to provide a complete guide to regexes, but rather
an introduction to the most important features, glossing over the
nasty edge-cases. Keep also in mind that I am in no way an expert
on the subject: we are learning together, here!

### The basics

You can think of a regular expression as a *pattern*, or a *rule*,
that describes which strings are "valid" (they are *matched* by the
regular expression) and which are not. As a trivial example, the
regular expression `hello` matches only the string "hello". A less
trivial example is the regex `.*` that matches *any* string.  I'll
explain why in a second.

Beware not to confuse regular expressions with *shell globs*, i.e.
the rules for shell command expansion. Although they use similar
symbols to achieve a similar goal, they are not the same thing. See
[my post on sh(1)](../2022-09-13-sh-1) or
[glob(7)](https://man.openbsd.org/OpenBSD-7.3/glob.7) for an
explanation on shell globs.

### General structure and terminology

A general regex looks something like this:

```
piece piece piece ... | piece piece piece ... | ...
```

A sequence of *pieces* is called a *branch*, and a regex is a
sequence of branches separated by pipes `|`. Pieces are not separated
by spaces, they are simply concatenated.

The pipes `|` are read "or": a regex matches a given string if any
of its branches does. A branch matches a given string if the latter
can be written as a sequence of strings, each matching one of the
pieces, in the given order.

Before going into what pieces are exactly, consider the following
example:

```
hello|world
```

This regex matches both the string "hello" and the string "world",
and nothing else. The pieces are the single letters composing the
two words, and as you can see they are juxtaposed without spaces.

But what else is a valid piece? In general, a piece is made up of
an *atom*, optionally followed by a *multiplier*.

### Atoms

As we have already seen, the most simple kind of atom is a single
character. The most *general* kind of atom, on the other hand, is
a whole regular expression enclosed in parentheses `()`. Yes, regexes
are recursive.

There are some special characters: for example, a single dot `.`
matches *any* single character. The characters `^` and `$` match
an empty string at the beginning and at the end of a line, respectively.
If you want to match a special character as if it was regular, say
because you want to match strings that represent values in the
dollar currency, you can *escape* them with a backslash. For example
`\$` matches the string "$".

The last kind of atoms are *bracket expressions*, which consist of
lists of characters enclosed in brackets `[]`. A simple list of
characters in brackets, like `[xyz]`, matches any character in the
list, unless the first character is a `^`, in which case it matches
every character *not* in the list. Two characters separated by a
dash `-` denote a range: for example `[a-z]` matches every lowercase
letter and `[1-7]` matches all digits from 1 to 7.

You can also use cetain special sets of characters, like `[:lower:]`
to match every lowercase letter (same as `[a-z]`), `[:alnum:]` to
match every alphanumeric character or `[:digit:]` to match every
decimal digit. Check the
[man page](https://man.openbsd.org/OpenBSD-7.3/re_format)
for the full list.

### Multipliers

The term "multiplier" does not appear anywhere in the manual page, I
made it up. But I think it fits, so I'll keep using it.

Multipliers allow you to match an atom repeating a specified or
unspecified amount of times. The most general one is the *bound*
multiplier, which consists of one or two comma-separated numbers
enclosed in braces `{}`.

In its most simple form, the multiplier `{n}` repeats the multiplied
atom `n` times. For example, the regex `a{7}` is equivalent to the
regex `aaaaaaa` (and it matches the string "aaaaaaa").

The form `{n,m}` matches *any number* between `n` and `m` of copies
of the preceeding atom. For example `a{2,4}` is equivalent to
`aa|aaa|aaaa`. If the integer `m` is not specified, the multiplied
atom matches any string that consists of *at least* `n` copies of
the atom.

Now we can explain very quickly the more common multipliers `+`,
`*` and `?`: they are equivalent to `{1,}`, `{0,}` and `{0,1}`
respectively.  That is to say, `+` matches at least one copy of the
atom, `*` matches any number of copies (including none) and `?`
matches either one copy or none.

## Basic regular expressions

Basic regular expressions are less powerful than their extended
counterpart (with one exception, see below) and require more
backslashes, but it is worth knowing them, because they are used
by default in some programs (for example [ed(1)](../2022-12-24-ed)).
The main differences between EREs and BREs are:

* BREs consist of one single branch, i.e. there is no `|`.
* Multipliers `+` and `?` do not exist.
* You need to escape parentheses `\(\)` and braces `\{\}` to
  use them with their special meaning.

There is one feature of BREs, called *back-reference*, that is
absent in EREs. Apparently it makes the implementation much more
complex, and it makes BREs more powerful. I noticed the author of
the manual page despises back-references, so I am not going to learn
them out of respect for them.

## Conclusion

Regexes are a powerful tool, and they are more than worth knowing.
But, quoting from the manual page:

```
     Having two kinds of REs is a botch.
```

I hope you enjoyed this post, despite the lack of practical examples.
If you want to see more applications of regular expressions, stay
tuned for the next entries on grep, sed and awk!

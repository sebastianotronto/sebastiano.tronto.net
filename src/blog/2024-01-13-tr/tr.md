# UNIX text filters, part 2.1 of 3: tr

*This post is part of a [series](../../series)*

In the [post about sed](../2023-12-03-sed) I have not discussed the
`y` command at all. This is because I realized it is just an
underpowered version of the `tr` command, that we are going to
explore in this post.

The `tr` command is a simple utility that can perform
character-by-character substitutions and a couple of other things.
Like most UNIX utilities, it operates on standard input and standard
output by default.

## Replacing

The most basic form of a `tr` command is

```
$ tr string1 string2
```

which replaces every occurrence of a character present in `string1`
with its corresponding character in `string2` - the first with the
first, the second with the second and so on. If `string2` is shorter
than `string1`, the last character is repeated as needed.

For example

```
$ echo 'Hello!' | tr le 13
H311o!
```

An equivalent `sed` command would be `sed 'y/le/13/'`.

Like sed and [grep](../2023-08-20-grep), also `tr` supports the
standard character sets like `[:upper:]`, `[:alpha:]` and so on.
For example, the following command capitalizes every letter in the
input string:

```
$ echo 'Hello!' | tr [:lower:] [:upper:]
HELLO!
```

## Deleting

With the `-d` option one can delete characters:

```
$ echo 'R42emo3vin0g all n66umber3s!' | tr -d 0-9
Removing all numbers!
```

Here I have used the *character range* `0-9` instead of `[:digit:]`.
Other examples of valid character ranges are `A-Z`, `0-8` and `a-f`.

The `-d` option can be combined with the `-c` option, which takes
the *complement* of a given set of characters:

```
$ echo 'R42emo3vin0g all non-n66umber3s!' | tr -cd '0-9\n'
4230663
```

Notice that I have also added `\n` to our list of
characters, so that the newline at the end of the text is kept.

A more complex example involving `tr -cd` is the following, which
I use to generate random passowrds:

```
$ cat /dev/random | tr -cd 'a-z0-9' | fold -w 12 | head -n 1
ft82mtfsy5ps
```

Here `/dev/random` spits out random data, while the commands
`fold -w 12` and `head -n 1` are used to break the input text into
lines of 12 characters and take the first line of the input,
respectively.  We'll talk about them in future posts.

## Squeezing

One more thing `tr` can do is *squeezing* consecutive identical
characters.  For example:

```
$ echo Helllllo | tr -s l
Helo
```

The `-s` option can be combined with the `-c` or `-d` option, and
in this case the squeezing is performed last, squeezing all the
characters contained in the last given string:

```
$ echo 'Hellllo! 112233' | tr -s 'l_e' '123'
H31o! 123
$ echo 'Hello!' | tr -ds '!' 'l'
Helo
```

## Conclusions

This is pretty much all there is tu say about `tr`. All of this can
probably be done with a sufficiently complicated `sed` or `awk`
script, but it is definitely nice to have a simpler utility to perform
easy changes.

*Next in the series: [head and tail](../2024-02-20-head-and-tail)*

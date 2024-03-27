# UNIX text filters part 2.2 of 3: head and tail

*This post is part of a [series](../../series)*

Continuing on our series of small text-filtering utilities, we have
`head` and `tail`. They are very simple, but also very useful.

## head

The `head` command is used to display the first few lines of a text file.
For example, the command:

```
$ head -n 4 [file]
```

Prints the first 4 lines of `[file]`. If `[file]` is not specified,
`head` reads from standard input.  If the option `-n 4` is not specified,
the first 10 lines are shown.

One can also use the following alternative notation:

```
$ head -4 [file]
```

Of course, there is also the equivalent [`sed`](../2023-12-03-sed) command:

```
$ sed 5q [file]
```

## tail

The `tail` command shows the *last* few lines of a specified file,
or of standard input. It supports the same `-n [number]` (or
`-[number]`) option where `n` defaults to 10.

However, for some reason, even in its standard POSIX variant, `tail`
has some extra features. First of all, one can add a `+` before
`[number]` to show all lines *from the `[number]`-th onwards*,
instead of the last `[number]`. For example:

```
$ printf '1\n2\n3\n4\n5\n' | tail -n +2
2
3
4
5
```

As you can see, the line numbering is 1-based.

It is also possible to start at a specific *byte* in the text stream
using the `-c` option:

```
$ echo 'Hello' | tail -c 3
lo
```

Notice that the ending `\n` is also included in the count. The `-c` option
also supports the `+[number]` notation:

```
$ echo 'Hello' | tail -c +2
ello
```

There is also an `-r` option that reverses the order of the output:

```
$ printf '1\n2\n3\n4\n5\n' | tail -r -n 2
5
4
```

Perhaps the most interesting feature of `tail` is the `-f` option,
which makes it stay open when the end of the file is reached,
displaying in real time any lines that are sunbsequently added. It
can be used like this:

```
$ tail -f my-log-file.log
```

This can be useful when the command writing to `my-log-file.log`
is already running and it is not possible to redirect its output.

The `-f` option does not work when `tail` is reading from standard
input, so technically speaking we are not in "text filter" territory
anymore, but it was mentioning.

## Conclusions

These two utilities don't do much, but can accomplish a lot when combined
with I/O redirection and other text filters.

*Next in the series: [rev](../2024-03-27-rev)*

# UNIX text filters, part 2.3 of 3: rev

*This post is part of a [series](../../series)*

Of all the simple programs I am dedicating a post to in this series,
`rev` is probably the simplest of them all.  So simple that it is
easy to forget about: `rev` prints each line of standard input to
standard output, reversing the order of the characters. For example:

```
$ printf 'This is\na very short post' | rev
si sihT
tsop trohs yrev a
```

Since [text is complicated](https://www.youtube.com/watch?v=gd5uJ7Nlvvo),
`rev` will read the environment variable `LC_CTYPE` to determine what
constitutes a character.

And that's it. See you soon for another (longer) post in this series.

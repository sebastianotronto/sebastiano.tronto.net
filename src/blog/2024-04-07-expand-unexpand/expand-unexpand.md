# UNIX text filters, part 2.5 of 3: expand and unexpand

*This post is part of a [series](../../series)*

Last week some guys at my company gave a little lecture on
[rust](https://www.rust-lang.org). They gave us some practical exercises,
with some partially-written source files to complete. Unfortunately, the
source files used spaces instead of TABs!

Luckily I knew how to use `unexpand` to fix this. And in case you
are shaking your head in horror because you prefer spaces, worry
not: `expand` can save you when you face the opposite problem.

## expand

The `expand` command converts tabs into spaces. By default every
TAB character *at the beginning of each line* is replaced by 8
spaces, but you can choose a different width with the `-t` option.
You can also choose to expand *all* TABs, not just the leading ones,
using the `-a` option. For example:

```
$ echo '	hello	world?' | expand -t 3
   hello	world?
```

As you can see, the TAB in the middle of the line is preserved.
Well I guess you can't really see it. Also, I am pretty sure the
markdown-to-html converter I use turns tabs into spaces anyway.
This example is a trainwreck, let's move on.

## unexpand

Unsurprisingly, `unexpand` does just the opposite of `expand`: it
converts groups of leading spaces into TABs. So the command I used
to "fix" the source files for the rust exercises was:

```
$ unexpand -t 4 main.rs
```

or to be more precise, since I wanted to replace the original file:

```
$ unexpand -t 4 main.rs > main.rs.2 && mv main.rs.2 main.rs
```

or to be even more precise, since I wanted to do this for multiple files:

```
$ for f in *.rs; do unexpand $f > $f.2 && mv $f.2 $f; done
```

## Quirks

For some reason, the OpenBSD version of `unexpand` does not allow
using the `-t` option. So if I had brought my OpenBSD laptop at the
rust lecture I would have been stuck with spaces :(

*Next in the series: [fold](../2024-05-31-fold)*

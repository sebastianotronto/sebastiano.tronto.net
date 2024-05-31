# UNIX text filters, part 2.6 of 3: fold

*This post is part of a [series](../../series)*

Today's text filter is `fold`, a program that can be used to format
paragraphs of text so that lines do not exceed a given width.

## fold

First of all, let's take a moment to celebrate the fact that the
[OpenBSD manual page for `fold`](http://man.openbsd.org/OpenBSD-7.4/fold)
uses the same terminology as me:

```
DESCRIPTION
     fold is a filter [...]
```

See? I didn't make this up!

Anyway, back to the tool. What `fold` does is breaking up lines of text
so that they take up a maximum of 80 characters - or any number of
characters specified by the `-w` option. For example:

```
$ echo 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec pretium odio quis nisi vestibulum, at semper magna ornare. Nulla facilisi. Sed in magna lacus. Proin faucibus est non ligula vehicula, quis ultrices lectus ultricies.  Aenean sit amet dignissim mauris. Sed luctus lobortis augue nec aliquet. Cras in felis tellus. Curabitur id purus feugiat enim posuere ultrices in viverra erat. Nulla facilisi. Donec et neque hendrerit, dignissim ipsum id, venenatis enim.' \
| fold -w 72
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec pretium o
dio quis nisi vestibulum, at semper magna ornare. Nulla facilisi. Sed in
 magna lacus. Proin faucibus est non ligula vehicula, quis ultrices lect
us ultricies.  Aenean sit amet dignissim mauris. Sed luctus lobortis aug
ue nec aliquet. Cras in felis tellus. Curabitur id purus feugiat enim po
suere ultrices in viverra erat. Nulla facilisi. Donec et neque hendrerit
, dignissim ipsum id, venenatis enim.
```

Although you probably want to use the `-s` option so that words are not
broken halfway through:

```
$ (same echo command) \
| fold -s -w 72
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec pretium
odio quis nisi vestibulum, at semper magna ornare. Nulla facilisi. Sed
in magna lacus. Proin faucibus est non ligula vehicula, quis ultrices
lectus ultricies.  Aenean sit amet dignissim mauris. Sed luctus
lobortis augue nec aliquet. Cras in felis tellus. Curabitur id purus
feugiat enim posuere ultrices in viverra erat. Nulla facilisi. Donec et
neque hendrerit, dignissim ipsum id, venenatis enim.
```

As with
[`rev`](../2024-03-27-rev) and [`cut`](../2024-03-28-cut), the environment
variable `LC_CTYPE` is used to determine what a character is, but
one can also specify to use *bytes* instead using the `-b` option.

## Examples

### Text formatting

A classic use for `fold` is formatting emails (or markdown files
for blog posts) to avoid long lines. For example if you use
[vi](https://en.wikipedia.org/wiki/Vi_(text_editor)), the command

```
!} fold -s -w 72
```

will format the next paragraph. However,
[`fmt`](http://man.openbsd.org/OpenBSD-7.4/fmt) can do the same and it is
more convenient to use - check it out!

### Generating passwords

Here is a cool example that puts together `fold` with some of the
other tools we have seen, [`tr`](../2024-01-13-tr) and
[`head`](../2024-02-20-head-and-tail). To generate a random password,
I use:

```
$ cat /dev/random | tr -cd 'a-z0-9' | fold -w 12 | head -1
```

This command reads the special file `/dev/random`, which contains a
never-ending stream of random bytes, and passes it through various commands
in a *pipeline*. First, every character that is *not* (`tr -c`) a
lowercase letter or a number (`a-z0-9`) is deleted (`-d`); then
the result is `fold`'d to 12 characters (`fold -w 12`); finally,
the first line is taken (`head -1`).

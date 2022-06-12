# The UNIX shell as an IDE: lookup stuff sed

Recently I have been working on [nissy](https://nissy.tronto.net), my
Rubik's cube solver written in C. It is a faily large project for me,
consisting of multiple files for a total of ~8k lines.

Something that I need to do quite often is quickly checking a structure's
or a function's definition. Using a simple text editor without
any plugin, my workflow for this at the moment is the following:

* Open a new terminal in the project's directory (one key-binding in
  my terminal's configuration)
* Open the correct file with `vi src/file.c` (this can be tricky,
  because I don't always remember in which file the object I am looking
  for is defined)
* Search with `/`

This is not too bad, but I can do better using a short sed script!

## Coding style

I write my functions like this:

```
static int
do_thing(int var)
{
	function body...
}
```

The important part is that the function's name is at the start of the line.
In this way when I search for the function's definition I can type
`/^do_thing`. Here `^` stands for the beginning of the line, and it
is fairly standard across UNIX tools (sed, grep, ed...), so all other
uses of the funciton in the same file are ignored.
The other important thing is that the closing `}` is also at the beginning
of the line, but everyone in their right mind does that (I hope).

## The sed command

If you are like me, 99% of the time you use sed it is to replace some text
with something like `sed 's/old text/new text/g`.
But this classic program can actually do more: it parses the input line by
line, applies a series of commands to each line that matches the given
address, and then prints the result. For example

```
$ sed '5,10 p' file.c
```

prints (`p`) the lines from 5 to 10 of `file.c`. Well, kind of: it prints
the whole file, but the lines from 5 to 10 are duplicated. This is because the
default behavior, applied to every line, is to do nothing and print the
(unmodified) input. We can change this behavior with the `-n` option:

```
$ sed -n '5,10 p' file.c
```

To print our `do_thing` function, we can find its address in the file using
the `/` search. The following command:

```
$ sed -n '/^do_/,/^}/ p' file.c
```

prints all the lines between one that starts with `/^do_/` and the first
one after that that starts with `}`. If you have another function called
`do_other_thing`, it will print that one too.

## Turning it into a script

Of course typing all of this every time we want to check out a function from
our file is too complicated. So we want to turn this into a script that we
can easily call.
We will call it `cth`, for "see thing', where the `c` also reminds us
that it is based on C's syntax.

We may start with something like this:

```
#!/bin/sh

sed -n "/^$1/,/^}/ p"
```

Using double quotes instead of single quotes is necessary to have the `$1`
expand to the first argument. After saving our script to `cth` and making
it executable with `chmod +x cth`, we can call it with

```
$ ./cth do_ < file.c
```

We have to use `<` to redirect the standard input, because our script does
not read any other argument that could be interpreted as a file name.
To do this, we can do:


```
#!/bin/sh

name=$1
shift
sed -n "/^$name/,/^}/ p" $@
```

This will save the first argument to a variable called `name`, "shift" the
list of arguments and pass every remaining argument to sed with `$@`. In this
way we can pass any number of file names. For example if we know our file
is in the `src` directory, but we do not remember what its name is, we can
[glob](https://en.wikipedia.org/wiki/Glob_(programming)) it with:

```
$ cth do_ src/*
```

And it works! You can now find
[this script](https://git.tronto.net/scripts/file/cth%2Ehtml)
among my other [scripts](https://git.tronto.net/scripts).

*Remark: in bash one can simply do `sed -n "/^$1/,/^}/ p" ${@:2}` to match
every argument from the second to the last, but this does not work in other
shells such as ksh.*

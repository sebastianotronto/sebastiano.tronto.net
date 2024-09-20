# Shell scripting in C

Recently, one of my [shell scripts](https://git.tronto.net/scripts)
grew too large. It is probably time to rewrite it in a proper
language. If possible I would like to still keep it as a script,
so I don't have to add a compilation step to the installation process
of my scripts.  Sure, I could use a scripting language like Python
or Perl... but what if I wanted to rewrite this script in C?

To be more precise, I want to write a single C file `script.c`,
make it executable with `chmod +x`, move it to somewhere in my
`$PATH` and then be able to run it simply by typing `script.c` in
my shell. It turns out that this is actually possible. Let's see
how *right now* so we don't have the time to wonder if it is a wise
thing to do (it does not sound like it).

## The trick

The single thing that makes it all possible is that lines starting
with `#` are preprocessor directives for C and comments for a UNIX
shell. We can then use the `#if` directive for conditional compilation
to "hide" a shell script in our souce file:

```
#if 0 /* Always false, skipped by the C compiler */

[Your shell script here]

exit 0 # Shell script terminates
#endif

[Your C source code here]
```

And now we just have to come up with a shell script that compiles
itself - that it, that runs a C compiler on its own source file.
For this we can run the `realpath` command on the shell parameter
`$0` to obtain the full path to the source file. Then we can compile
this file and save the executable to a temporary file, which we
finally run. The "C Script Hello World" looks like this:

```
#if 0

bin="$(mktemp)"
cc -o "$bin" "$(realpath $0)"
"$bin"

exit 0
#endif

#include <stdio.h>

int main() {
	printf("Hello, world!\n");
	return 0;
}
```

If you want to try this for yourself, you can download
[script.c](./script.c) instead of copy-pasting.

## Caveats

There are few caveats with this approach. First of all, you are
running a C compiler every time you launch this "script". This is
obviously less efficient than running a normal shell script.

Secondly, the `realpath` command I used above is not standard. I
thought it was in POSIX, but only the C library function with the
same name is, not the command itself. However, it is present in
most Linux distros since around 2012 and OpenBSD since version 7.1
- surprisingly, after I started using each of these operating
systems! The command is also included in FreeBSD (since 4.3) and
MacOS (since 13), and there are probably workarounds to make the
same concept work without it.

## Credits

I did not come up with this trick - I read about it in at least
three separate occasions from different places. Had I saved any of
the links I would add them here.

## For completeness, a python version

In case you did not know, making this work with an interpreted
language is much simpler. You just need to use a
[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) to make
the shell use the correct interpreter:

```
#!/usr/bin/env python3

print("Hello, World!")
```

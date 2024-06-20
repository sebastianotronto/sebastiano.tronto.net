# Another C trick: flexible logging with callback functions

Working with C on my personal projects I enjoy complete freedom: I
don't have to follow existing conventions, I don't have to bend my
code to fit into an existing codebase, I can re-organize the program's
structure whenever I feel like. On the other hand, I don't get to
learn well-known good practices that were invented by whose who
beat their heads against the wall before me.

Sometimes, through a lot of wall-headbanging, I get to re-invent
these good practices by myself. Some time ago I wrote about
[using macros to make functions testable](../2023-11-14-test-visibility-c-macro).
Now it is time for another trick: using a
[callback function](https://en.wikipedia.org/wiki/Callback_(computer_programming))
for logging!

## The problem

I am working on a new version of [nissy](https://nissy.tronto.net),
a Rubik's cube solver with some extra functionalities that I and a
few others use. The code is public but I won't link it here for
now; it is not ready and many things will likely change by the time
you read this post.

One thing I decided to do was organizing the code as a library that
can be used by other programs to provide user-facing functionalities.
In other words, the main code does not have a `main()` function.
Other programs that use this code as a library include or may include
in the future:

* A testing utility / framework
* A command line interface
* A graphical interface (tentative)

As a consequence, the library itself should avoid using standard
input and output - that would be fine for the CLI interface, but
useless for the GUI. All the necessary information is exchanged
between the library and the client code via function return values
and parameters, including `char *` buffers for text output.
This also means I can get rid of `stdio.h` from my library code.

However, sometimes it is useful to see some logging info, especially
when debugging. For this reason, I have hidden an `#include <stdio.h>`
behind the compile-time option `#ifdef DEBUG`.

This means so far I could only see log information when building
in debug mode. But I have recently realized that this is too limiting:
even in the user-facing version of this program, long-running queries
could benefit from more frequent output before the response has been
calculated. But how can I do this without using `stdio`?

## Brainstorming

Problem solving is full of dead ends and wasted brain-cycles.  Before
I present to you the clever solution I found like I am some kind
of coding guru, let's see some of the bad ideas that I came up with
and discarded.

### More macros

If I can hide debug logging behind a compile-time macro, why not
doing it for logging in general? I could split up the logging from
the other debug stuff and let the programmer (i.e. me) choose at
build time whether to have logs or not.

But this is not great. First of all, I don't like the idea of making
the build system more complex, I think it makes the code less
portable.  Secondly, it is less flexible, because it limits the
options to what I decide right now. Of course I could add more stuff
later as needed, but this implies more coupling between the library
and the client.

### Use `char *` buffers

Since some information is exchanged via `char *` output parameters,
the same could be done for logging information. This is very flexible,
because it allows the caller to do whatever they want with the log
output. But passing a "log buffer" parameter to every function call,
which is likely to be the same for the whole program, is annoying
and feels redundant. Moreover, reading this information off the the
buffer in real time is very complicated.

### Custom `FILE *` stream

If I log the information to
[standard error](https://en.wikipedia.org/wiki/Stderr) using
`fprintf(stderr, ...)`, perhaps replacing `stderr` with a custom
`FILE *` object could do the trick. It limits the log messages to
be written to a file, but in the UNIX world *almost* everything
is a file. This trick may not be the most portable, but it is
certainly quite flexible.

But how would the programmer set this custom stream? There must be
a way to do it with macros, but then we have the same problems of
the first idea. Alternatively, I could define a global `FILE *`
variable and add to my interface to let the caller set this variable...

And this brought me to the final idea: if I can set a global variable
via a function call, why not make this variable a pointer to a
function?

## The solution

The solution I settled for is the following.

In the main source file `mylib.c` I define a global function pointer

```
void (*mylib_log)(const char *, ...);
```

This pointer will be used to call the function that prints the log.
By default it is unset (NULL), which I choose to interpret as "no
logs should be printed".  I used the dots `...` because I wanted
this function to be
[variadic](https://en.wikipedia.org/wiki/Variadic_function), just
like the classic `printf()`.

After this declaration I have some wrapper code that checks if the
logger function is set before calling it:

```
#define LOG(...) if (mylib_log != NULL) mylib_log(__VA_ARGS__);
```

The macro above uses `__VA_ARGS__` to refer to the list of arguments
denoted by the three dots. Now to show a log message I can do:

```
void do_thing(int a, int b) {
	int x = compute(a, b);

	LOG("Computed value %d\n", x)

	return x;
}
```

Finally, there is a public function that lets the user of the
library set the logger function:

```
void mylib_setlogger(void (*f)(const char *, ...)) {
	mylib_log = f;
}
```

And that's it! Using this setup is pretty simple. For example, for my unit
tests I have something like this:

```
#include <stdarg.h> /* For va_list and related functions */

void log_stderr(const char *str, ...)
{
	va_list args;

	va_start(args, str);
	vfprintf(stderr, str, args);
	va_end(args);
}

int main(void) {
	mylib_setlogger(log_stderr);
	run_test();
	return 0;
}
```

The function `vfprintf()` is a version of `fprintf()` that takes a
[`va_list`](https://en.cppreference.com/w/c/variadic/va_list)
argument instead of an old-style parameter list. This is the
standard way to pass on variadic function arguments, as far as I
know. In case you did not know, `fprintf()` is a version of
`printf()` that prints to a given stream - in this case, `stderr`.

Now if I ever get to implementing a GUI, all I have to do to show
`mylib`'s logs is implementing a function `log_to_gui()` that shows
the given text somewhere, and call a `mylib_setlogger(log_to_gui)`
at the start of the program. Neat!

## Conclusion

When I code for fun, I definitely enjoy coming up with my own
solution for problems like this, even if the solution already exists
somewhere.  I also think that re-inventing standard practices like
this is making me a better programmer, because after struggling
with it myself I understand the practices better and I appreciate
them more.

This time in particular I learnt how to implement variadic functions,
and a bit of their
[history](https://stackoverflow.com/questions/14082476/what-is-the-best-way-for-giving-callback-for-logging).
I am still not sure if this will work well when I end up using
this library in a non-C project.  Is it even possible to call C
variadic functions from other languages?  Will I have to provide a
logger that takes a `va_list` instead? I guess I'll find out!

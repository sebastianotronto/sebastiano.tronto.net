# Making functions public for tests only... with C macros!

*Note from the future (2024-09-05): in the first version of this post,
I used the identifier `_static` instead of `STATIC` for a macro.
I have recently found out that one should almost never use identifiers
starting with underscore, so I have edited this post accordingly. See
[this StackOverflow question](https://stackoverflow.com/questions/69084726/what-are-the-rules-about-using-an-underscore-in-a-c-identifier)
for an explanation.*

As a programmer, I often face this dilemma: should I make this
function private to improve encapsulation, or should I make it
public so that I can write tests for it? I believe this problem is
especially felt in scientific computing, or when implementing big,
complex algorithms whose many small substeps have no place in a
public interface, but should be unit-tested anyway.

Until recently, I essentially had two ways to deal with this (with
a strong preference for the first one):

* Make the function public, tests are important. Who cares about visibility.
* Make the function private and skip the tests. Errors will be caught when
  testing the higher-level routine that calls this smaller function.

But a few days ago I thought of a cool trick (that realistically
has been known for at least 45 years, I just was not aware of it
before) to solve this problem for my C projects, using conditional
compilation.  Let's dive in!

## Function visibility in C

By default, functions in C are "public", by which I mean visible to any other
*[translation unit](https://en.wikipedia.org/wiki/Translation_unit_%28programming%29)*
(file). For example, say you have the following files:

`foo.c`:

```
int foo(int x, int y) {
	return 42*x - 69*y;
}
```

`main.c`:

```
#include <stdio.h>

int foo(int, int); // Function prototype

int main() {
	int z = foo(10, 1);
	printf("%d\n", z);
	return 0;
}
```

You can build them with `gcc foo.c main.c`, and the program will
run correctly and output `351`. Usually, the function prototype is
put in a separate `foo.h` file and it is included in `main.c` with
`#include "foo.h"`.

This works because a C program is built into an executable in two
steps: *[compiling](https://en.wikipedia.org/wiki/Compiler)* and
*[linking](https://en.wikipedia.org/wiki/Linker_(computing))*.
During the first of these two, each file is translated into
*[object code](https://en.wikipedia.org/wiki/Object_file)*; if the
compiler finds a reference to a function whose body is not present in
the same file - like our `foo()` in `main.c` - it does not complain,
but it trusts the programmer that this function is implemented somewhere
else. Then it is the turn of the linker, whose job is exactly is to
put together the object files and resolve these function calls;
the linker *does* complain if the body of `foo()` is nowhere to be found.

All of this is different for functions marked as `static`. These are
only visible inside the file where they are defined.

## Why make functions `static`?

There are a couple of reasons why one should make (some) functions
`static`:

* As a hint to other programmers: similarly to the `private` modifier
  in object oriented languages, `static` immediately communicates that
  this function is only used locally, and will not be called from other
  modules. It also prevents someone from calling it from another file
  by mistake.
* As a hint to the compiler: if a compiler sees a `static` function, it
  knows all the places where this function is called, and it can
  choose to optimize out all the
  [assembly boilerplate](https://en.wikipedia.org/wiki/Calling_convention)
  related to function calls and
  [inline it](https://en.wikipedia.org/wiki/Inline_expansion).

To illustrate the second point, I have put all the code of the
previous example in the same file [`main2.c`](./main2.c). You can
compile it with `gcc -O1 -S main2.c` to enable optimizations and
generate the assembly code instead of an exectuable. I have uploaded
the output here: [`main2.s`](./main2.s). Then you can do the same with
[`main3.c`](./main3.c), whose only difference is that `foo()` is now
static, and check the resulting [`main3.s`](./main3.s).

As you can see, the section labelled `foo:` has disappeared. This
is because the compiler knows that it will not be needed anywhere
else; it inlined it everywhere it saw a reference to it and called
it a day.

You may also see that `foo` was actually inlined in *both* examples,
and the call to it replaced by the constant `351`. Oh well, at least
the compiler got rid of some useless code in the second case, and
the binary will be smaller.

## The trick

The trick I came up with is the following:

```
#ifdef TEST
#define STATIC
#else
#define STATIC static
#endif
```

Now put the snippet above at the top of the C file where the functions
you want to test are implemented and declare your functions as
`STATIC`. When you compile your code normally,
these functions will be compiled as `static`, but if you use the
`-DTEST` option, `STATIC` will expand to nothing and the functions
will be visible outside the file.

Here is a complete example.

[`foo4.c`](./foo4.c):

```
#include <stdio.h>

#ifdef TEST
#define STATIC
#else
#define STATIC static
#endif

STATIC int foo(int x, int y)
{
	return 42*x - 69*y;
}
```

[`test4.c`](./test4.c)

```
#include <stdio.h>

int foo(int, int);

int main() {
	int result = foo(1, 1);

	if (result == -27) {
		fprintf(stderr, "Test passed\n");
		return 0;
	} else {
		fprintf(stderr, "Test failed: expected -27, got %d\n", result);
		return 1;
	}
}
```

You can download the source files (links above) and try for yourself:
build with `gcc foo4.c test4.c` and you'll get a linker error
`undefined symbol: foo`; build with `gcc -DTEST foo4.c test4.c` and
run `./a.out` to see the test pass!

## Related tricks

A few days before coming up with this trick, I had learned about a
similar use of C macros useful for debugging purposes. I wanted to
have some extra logging to be enabled only when I chose so, for
example when using a `-DDEBUG` option. What I used to do was throwing
`#ifdef`s all over my codebase, like this:

```
	if (flob < 0) {
#ifdef DEBUG
		fprintf(stderr, "Invalid value for flob: %d\n", flob);
#endif
		return -1;
	}
```

But what I have found (on the
[Wikipedia page on the C preprocessor](https://en.wikipedia.org/wiki/C_preprocessor))
is that you can use a single `#ifdef` at the top of your file:

```
#ifdef DEBUG
#define DBG_LOG(...) fprintf(stderr, __VA_ARGS__)
#else
#define DBG_LOG(...)
#endif

/* More code ... */

	if (flob < 0) {
		DBG_LOG("Invalid value for flob: %d\n", flob);
		return -1;
	}
```

Here I am using a *variadic macro*, which is supported in C99 but not,
as far as I know, in C89. If you want to try this out, you'll have to
build with `-std=c99` or a similar option.

Sometimes the part I want to conditionally compile is not just the
information logging, but the whole conditional expression. To do this,
I actually use something like this in my code:

```
#ifdef DEBUG
#define DBG_ASSERT(condition, value, ...)     \
	if (!(condition)) {                   \
		fprintf(stderr, __VA_ARGS__); \
		return value;                 \
	}
#else
#define DBG_ASSERT(...)
#endif

/* More code ... */

	DBG_ASSERT(flob >= 0, -1, "Invalid value for flob: %d\n", flob);
```

Here `condition` can be any C expression. Macros are powerful!

## Conclusion

Depending on your taste, you may find this a clean way to write
C code, or a disgusting hack that should never be used.

If you are working on a project where you can choose your own coding
style, I encourage you to try out tricks like this and see for
yourself if you like them or not. In the worst case, you'll make
mistakes and learn what *not* to do next time!

# Things I learned rewriting a project from scratch

About two years ago I [wrote](../2023-04-10-the-big-rewrite) about a
project I have been working on and off for a few years. In that post
I explain how and why I decided to rewrite it from scracth, splitting
it in multiple parts. I ended up not following exactly the plan that I
laid out, and I also worked on the rewrite more slowly than I wanted.
But rewriting from scratch allowed me to experiment with new ideas and
discover new tricks, and after two years I learned enough stuff that I
can make a blog post about it!

The project I am talking about is [Nissy](https://nissy.tronto.net), a
command-line Rubik's Cube solver that is quite popular in the very small
niche of speedcubers interested in the *Fewest Moves Challenge*, which
consists in solving the puzzle with the smallest amount of moves rather
than as fast as possible. Both the old and the new versions are written
in C, but not all the things I discuss in this post are language-specific.

You can find the new version of this project, the "Big Rewrite",
in [this repository](https://git.tronto.net/h48) - or
[on github](https://github.com/sebastianotronto/h48), if you prefer.
I decided to rename it "H48" back when I planned to have separate projects
for the different features of the old version, but I may change it back
to Nissy at some point.

But now let's get into it!

## Better memory safety (yes, even in C)

Let's start with a mistake that I think many inexperienced C programmers
make: in the previous iterations of this project, I used a lot of
`malloc()`s. And although I was quite diligent in always freeing the
memory I used, in most cases I would have been better off not using
dynamic memory allocation at all.

As an example, let's consider the case of converting some data structure
into a string. One way to do it would be something like this:

```
char *mytype_to_string(const mytype_t *x) {
	const size_t str_size = 512;
	char *str = malloc(str_size);

	/* Write stuff to str here */

	return str;
}
```

If you are familiar with
[garbage-collected languages](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)),
you may find the code above nice and clean. However, since with C we have
to manage our memory manually, the caller of this function would have
to remember to `free()` the pointer returned by `my_type_to_string()`.
This is not rocket science, but it is a common source of mistakes.

However, a safer pattern for this kind of function would be the following:

```
int mytype_to_string(const mytype_t *x, size_t len, char buffer[len]) {
	const size_t str_size = 512;
	if (len < str_size) {
		/* Handle error in some way, for example by returning -1 */
	}

	/* Write stuff to buffer here */

	return 0; /* Or return number of bytes written */
}
```

In this new version of the code, instead of returning a string, the
function takes a `char` buffer and its lenght as a parameter. Notice
that we are **not** passing the buffer by value, as the notation
`buffer[len]` might suggest: this function's signature is equivalent to
`my_type_to_string(const mytype_t *, size_t, char *)`, but by using the
square-bracket notation the compiler may be able to catch a too-small
buffer and warn us about it.

Now we can get rid of the malloc entirely, because the caller can
just allocate the char buffer on its stack:

```
void doing_stuff(mytype_t x) {
	const size_t len = 1024;
	char str[len];
	if (mytype_to_string(&x, len, str) != 0) {
		/* Handle error */
	}

	/* ... */
}
```

Unfortuntely, this new pattern leads to a small problem: the caller
must now be aware of the number of characters required for converting
`mytype_t` to a string. There are a couple of ways to solve this problem,
including handling a `NULL` first parameter as a "dry-run" request that
returns the required size without writing anything, or using a global
constant.

This brings me to another feature I have started using more and more
recently. Say we want to use a global constant for the size of `mytype_t`.
We could do something like this:

```
#define MYTYPE_SIZE 512

int mytype_to_string(const mytype_t *x, char buffer[static MYTYPE_SIZE]) {
	/* Write to buffer here, no error handling needed */

	return 0; /* Or return number of bytes written */
}

void doing_stuff(mytype_t x) {
	char str[MYTYPE_SIZE];
	mytype_to_string(&x, str);

	/* ... */
}
```

Notice how I used `[static MYTYPE_SIZE]` to denote the required size
of the buffer parameter. This tells the compiler that the function
`mytype_to_string()` can assume that the buffer must reference an area
of memory of size at least `MYTYPE_SIZE`. In turn, the compiler can
use this information not only to optimize the code, but also to give
useful warnings.  This trick can also be used to tell the compiler that
a pointer cannot be `NULL`: a pointer is not `NULL` if it refers to an
valid area of memory of size at least 1. So we can declare a function
as follows:

```
int mytype_to_string(const mtytype_t x[static 1], char buffer[static MYTYPE_SIZE]) {
	/* ... */
}
```

With this we can come up with a set of rules to never de-reference a
NULL pointer.  A pointer must be either:

1. Obtained by de-referencing an object allocated in current function.
2. A parameter declared as `[static 1]`.
3. Checked for `NULL` before de-referencing.

Having more memory safety baked into the language would be more convenient,
but at least we can use some mitigations.

## Sanitizers

Another tool that help me improve the memory management of my code are
[sanitizers](https://en.wikipedia.org/wiki/Code_sanitizer).
They were suggested to me by [Tomas Rokicki](https://tomas.rokicki.com)
when I shared my struggles with
[an old bug](../2023-05-05-debug-smartphone), and now that I got used
to them I am wondering how I even survived programming in C without them.
Sanitizers are *compiler intrumentations* supported by the major C and
C++ compilers - namely GCC and Clang. They add some runtime checks to
a program that make it crash with a clear message if they detect
a memory error, such as an access outside the bounds of an array, or a
race condition. For example, say you try to access some out-of-bound
element of an array:

```
/* This is a.c */

#include <stdio.h>

int main() {
        int a[4] = {0, 1, 2, 3};

        printf("Out-of-bound value: %d\n", a[4]);
}
```

Normally, this program just runs fine and prints some garbage value:

```
$ cc a.c && ./a.out
Out-of-bound value: 1573265008
```

Notice how the compiler did not even give us a warning!
However, if we compile with the address sanitizer enabled:

```
$ gcc -fsanitize=address a.c
$ ./a.out
=================================================================
==15152==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7fc4e2500030 at pc 0x000000401331 bp 0x7ffdffd953c0 sp 0x7ffdffd953b8
READ of size 4 at 0x7fc4e2500030 thread T0
    #0 0x401330 in main (/home/sebastiano/a.out+0x401330) (BuildId: e8411facf942864956c817b9be7bee9868ec6065)
    #1 0x7fc4e4a10247 in __libc_start_call_main (/lib64/libc.so.6+0x3247) (BuildId: f83d43b9b4b0ed5c2bd0a1613bf33e08ee054c93)
    #2 0x7fc4e4a1030a in __libc_start_main_alias_1 (/lib64/libc.so.6+0x330a) (BuildId: f83d43b9b4b0ed5c2bd0a1613bf33e08ee054c93)
    #3 0x4010d4 in _start (/home/sebastiano/a.out+0x4010d4) (BuildId: e8411facf942864956c817b9be7bee9868ec6065)

Address 0x7fc4e2500030 is located in stack of thread T0 at offset 48 in frame
    #0 0x4011a5 in main (/home/sebastiano/a.out+0x4011a5) (BuildId: e8411facf942864956c817b9be7bee9868ec6065)

  This frame has 1 object(s):
    [32, 48) 'a' (line 4) <== Memory access at offset 48 overflows this variable
HINT: this may be a false positive if your program uses some custom stack unwind mechanism, swapcontext or vfork
      (longjmp and C++ exceptions *are* supported)
SUMMARY: AddressSanitizer: stack-buffer-overflow (/home/sebastiano/a.out+0x401330) (BuildId: e8411facf942864956c817b9be7bee9868ec6065) in main
Shadow bytes around the buggy address:
  0x7fc4e24ffd80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x7fc4e24ffe00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x7fc4e24ffe80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x7fc4e24fff00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x7fc4e24fff80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x7fc4e2500000: f1 f1 f1 f1 00 00[f3]f3 00 00 00 00 00 00 00 00
  0x7fc4e2500080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x7fc4e2500100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x7fc4e2500180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x7fc4e2500200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x7fc4e2500280: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
==15152==ABORTIN
```

A bit overwhelming, but I certainly prefer this over getting random
garbage results!

Similarly, one can check for undefined behavior (`-fsanitize=undefined`),
data races (`-fsanitize=thread`), memory leaks (`-fsanitize=leak`) and
more. If you never used sanitizers, you should start now!

Sanitizers is that they are *runtime* checks.  This means that your
program running fine with sanitizers enabled does not guarantee the
absence of errors. Moreover, a program compiled with sanitizers enabled
will run much slower than normal - so you should only use them in your
debug builds.

It would be amazing to have this kind of checks performed at compile
time - I wonder if this is this "Rust" thing all the cool kids are
talking about?

## Data races and atomic types

Before starting this project I knew the basics of multi-threaded
programming with [pthreads](https://en.wikipedia.org/wiki/Pthreads). But
I had (and probably still have) many things to learn.

For example, I used to think that having a thread read a value that
another thread is possibly writing at the same time could be
done safely, without using any
[lock](https://en.wikipedia.org/wiki/Lock_(computer_science)).

Assuming you don't care if the value you read comes from before or after
the write from the other thread, which was my case, this sounds like
a reasonable assumption. It turns out that this assumption is called
*sequential consistency*, and that it is almost always wrong.

One way to confirm that a concurrent read + write is undefined
behavior in C and C++ is compiling with `-fsanitize=thread`, which
will rightfully scream at you if one such data race happens. Luckily,
it is not necessary to use a mutex for this kind of operation:
starting from C11 and C++11 you can just declare your variable
[`_Atomic`](https://en.cppreference.com/w/c/language/atomic) and happily
read and modify it at the same time. This comes at a performance cost,
but this cost is smaller than that of a traditional lock.

## Single instruction, multiple data

[SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data)
is a type of parallelism implemented in pretty much every CPU made in
the last 20 years or so.  You can call SIMD instructions directly from
high-level code using *vector intrinsics*. For example, the following
code computes four sums of 64-bit integers at the same time:

```
/* Compile with -mavx2 option */

#include <stdio.h>
#include <immintrin.h>

int main() {
	long long r[4];

	/* Initialize the 4x 64-bit int data structures */
	__m256i a = _mm256_set_epi64x(23, 42, 1234567890123456789, -1000);
	__m256i b = _mm256_set_epi64x(-1, 69, -1234567890123456789, 3);

	/* Compute the sums */
	__m256i c = _mm256_add_epi64(a, b);

	/* Store back the result into a buffer */
	_mm256_storeu_si256((__m256i *)r, c);

	/* Print the results (last is first) */
	printf("Results:\n%lld\n%lld\n%lld\n%lld\n", r[0], r[1], r[2], r[3]);
}

```

The `__mm256_add_epi64()` used above is not just syntactic
sugar: the compiler translates it directly to a single
`vpaddq` assembly instruction. You can check this on
[godbolt](https://godbolt.org/z/d6TjPzKPG), or by compiling the code
above with `gcc -S -mavx2 file.c`.

Adding numbers is not the only thing that can be done with SIMD: there
are also instructions for other operations, including logic operators
and permutations of blocks of bits. The latter was particularly relevant
to me, this project being a Rubik's cube solver.

Using these instructions gave me a similar feeling to when I wrote
multi-threaded code for the first time: it looks scary at first
because of the weird syntax, but it was actually pretty easy to do
what I wanted once I got started.

## Testing

It sounds completely trivial now, but I did not do much testing
in my previous personal projects. But rewriting from scratch allowed
me to do the right thing from the start and implement a proper
testing suite.

I used different types of tests at different stage of the development.
In ealy stages, when I was building the core routines of the library,
I relied more on [unit tests](https://en.wikipedia.org/wiki/Unit_testing),
and even did some
[test-driven development](https://en.wikipedia.org/wiki/Test-driven_development).
These tests ran always in debug mode with *sanitizers* switched on (see
above) and enabled me to catch errors early and be confident that, once
the tests passed, the code was correct.  On later stages this strategy
was hard to apply, because the high-level functions required working
with large arrays of data that were multiple gigabytes in size; they
could not be tested in isolation.

Being completely nuts as I am, I set up the whole testing system
from the ground up, but this turned out to be extremely practical and also
quite powerful in its simplicity. In a folder called `test` I had a
`test.sh` file and one sub-folder for each test. Each test consists
of a (usually very short) `.c` file and one or more *test cases*,
i.e. a pair of `file.in` (input file) and `file.out` (expected output)
files. The `test.sh` script, which I call with `make test`, builds and
runs each test case and compares the result to the expected output using
diff(1). Optionally, one case use an environment variable to pick which
test(s) to run.

If you are wondering why I set this whole thing up and I did not use
some test framework, that's a fair question. The answer is that I like to
understand every part of something I build, and I have quite a distaste
for external dependencies. Moreover, I was not in a rush to complete
this project - I was happy to build it piece by piece and possibly go
back and change everything if I discovered a better way to do things.

By doing everything by hand I ended up re-discovering many well-known
tricks on my own, such as [callback functions](../2024-06-20-callback-log)
and [some macro magic](../2023-11-14-test-visibility-c-macro).

But in the end it does not matter that much what type of tests or what
framework one uses, as long as they are automated and easy to run.

## Structuring the project as a library

This one is a rare instance of learning something not by banging my head
against a wall until either cracks, but instead by making a good call
intuitively early on and confirming it empirically.

When I started the rewrite I had in the the back of my mind the idea
of building multiple UIs for this tool, possibly using different
languages and frameworks. So I decided to structure the core of the project
as a library *with a very thin interface*. This meant not exposing many
functions, types or constants to simplify writing adapter code for
other languages. Indeed I avoided exposing *any* type at all and only
used standard integer types and strings.  This made it easy to implement
Python bindings (see below) and at the same time it gave me more freedom
to reorganize the code internally without breaking the API.

Another thing that I did was deferring all I/O and memory management
to the *user* of the library. This implied for example using
[callback functions](../2024-06-20-callback-log) for logging and,
as discussed at the beginning of this post, returning string output via a
`char *` buffer provided by the caller. This forced me to write in a very
clean and safe style - there is only one `malloc()` in the core library!

## Interfacing with Python

This project was developed as a library, but I still needed to run the
code to test it, of course. To do this, at first I developed a simple
command line tool to call this library's functions directly. However
parsing command line options by hand can easily become messy.

At some point I thought it would be cool to write some Python adapters
for my library and use the Python REPL instead of my custom CLI. Not only
would this be more powerful because of the ability to run arbitrary code,
it would also be easier to write and maintain. It was something new for
me, but once again it turned to be not too hard. I wrote about the first
steps in [a blog post](..2024-10-08-python-c).

## Accepting contributors

Around April last year a friend asked me if he could work on this
project as part of his bachelor thesis in computer science. And I said
no, because I wanted this to be my personal, slow-paced project and I
could not assure him that it would be in a stable state while he was
working on his thesis. So I made
[a spin-off project](https://git.tronto.net/cubecore)
and told him he could base his work on that. I offered to help if he
had any questions on the topice, and that was it.

Bur when he asked again to contribute a few months later, the situation
had changed. The project was in a stable state and most of the preliminary
work was done, so I decided to let him have fun and implement one of the
core parts of the tool. I started reviewing his contributions, and I had
to find the right balance between keeping the code consistent with what
I had mind and let him submit his code without requesting unnecessary
changes. This is something I regularly do for work, but doing this for
a project of which I am the creator and main author felt much different!

Besides the learning experience, this also had some technical benefits,
mostly related to the fact that we are using different compilers,
operating system and CPU architectures: now I have a library that compiles
with both GCC and Clang, runs on Linux and MacOS, and is optimized for
both x86 with
[AVX2 extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions#Advanced_Vector_Extensions_2)
and ARM with
[NEON](https://en.wikipedia.org/wiki/ARM_architecture_family#Advanced_SIMD_(Neon)).

## Conclusion

Rewriting from scratch is rarely the fastest way to fix a project,
but it feels nice and, as this post shows, it is a great opportunity to
learn cool new stuff.

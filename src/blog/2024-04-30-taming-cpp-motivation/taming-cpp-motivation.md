# Taming C++, episode 1: motivation

C++ is pretty much the standard language in the software industry for
any project where performance matters. I have used it a fair bit in
the past - during my [IOI](https://ioinformatics.org) time and for
a university course - but I used it only as "C with
[STL](https://en.wikipedia.org/wiki/Standard_Template_Library)". I have
also reviewed it for my job interview a couple of years ago, but I have
not touched it since then. Given that I am at the early stages of my
career as a software developer and that I am interested in performance,
it's about time I learn modern C++!

## Motivation

As much as I like programming and learning new stuff, this is something
that requires some effort. And it turns out that keeping a copy of
[A Tour of C++](https://www.stroustrup.com/tour3.html) on my desk and
looking at its cover from time to time does not provide sufficient
motivation to take up this new task.

Starting a new project would be a good way to start playing with a new
language, but at the moment I would rather keep working on my ongoing
projects than start a new one. Writing a (series of) blog post(s)
where I share my experience with the rest of the world seemed like a
good alternative, but I needed some extra push to get started.

Finally, a few weeks ago I have discovered Bert Hubert's series of posts
[*Modern C++ for C programmers*](https://berthub.eu/articles/posts/c++-1).
The first post in that series showed an example that got my attention:
for a task as simple as sorting a list of integers, using their respective
standard libraries, C++ outperforms C by a significant margin!

## Performance

To get started with modern C++, I decided to repeat Bert's experiment.
You can find the code I wrote in
[this repository](https://git.tronto.net/taming-cpp).

To sort a list of a hundred million integers, in C we can use `qsort()`
from `stdlib.h` (see
[sort.c](https://git.tronto.net/taming-cpp/file/sort-benchmark/integers/sort.c.html)):

```
qsort(a, ARRAYSIZE, sizeof(int), compar);
```

Where `compar()` is a comparison function such as

```
int compar(const void *x, const void *y) {
	return *(int *)x - *(int *)y;
}
```

In C++ we can use `sort()` from `algorithm` (see
[sort.cpp](https://git.tronto.net/taming-cpp/file/sort-benchmark/integers/sort.cpp.html)):

```
std::sort(a, a+ARRAYSIZE,
          [](const int &x, const int &y) { return x < y; });
```

Here we use a
[lambda expression](https://en.cppreference.com/w/cpp/language/lambda)
instead of a comparison function.

Modern C++ also offers parallelized
version of common algorithms as part of the standard library, so if
we want to completely humiliate poor C we can use this (see
[sort_parallel.cpp](https://git.tronto.net/taming-cpp/file/sort-benchmark/integers/sort_parallel.cpp.html)):

```
std::sort(std::execution::par, a, a+ARRAYSIZE,
          [](const int &x, const int &y) { return x < y; });
```

Parallelizing stuff like this looks almost like cheating, but it wasn't
without some struggle - see the "Gotchas" section below.

So, what is the result? These are the times I get on my
[Debian 12 desktop](https://sebastiano.tronto.net/blog/2023-10-15-build-time)
(AMD Ryzen 7 7700):

```
C time for 100000000 numbers: 9.815525s
C++ time for 100000000 numbers: 4.87299s
C++ time for 100000000 numbers (parallel): 0.488956s
```

Even without parallelization, C++ is twice as fast as C!

You might think that C++ is somehow optimizing for integer
sorting. But this is not the case, as demonstrated by a similar experiment
with *pairs* of integers (see
[sort.c](https://git.tronto.net/taming-cpp/file/sort-benchmark/pairs/sort.c.html),
[sort.cpp](https://git.tronto.net/taming-cpp/file/sort-benchmark/pairs/sort.cpp.html) and
[sort_parallel.cpp](https://git.tronto.net/taming-cpp/file/sort-benchmark/pairs/sort_parallel.cpp.html)
- I used a non-standard mixed lexicographic order to be reasonably sure the
compiler does not come up with any ad-hoc optimization):

```
C time for 100000000 pairs: 12.383896s
C++ time for 100000000 pairs: 6.50033s
C++ time for 100000000 pairs (parallel): 0.713616s
```

## Complexity is not for nothing

As explained by Bert in his post, the reason
the C++ version is faster is that by using
[templates](https://en.cppreference.com/w/cpp/language/templates)
the compiler can inline the call to the comparison function. C is not
as sophisticated, so this is not possible: the only way a standard
library function can call your custom code is via a
[function pointer](https://en.wikipedia.org/wiki/Function_pointer).
Regardless of possible performance issues with pointer
dereferencing, calling a function without inlining it always causes
some overhead. This is completely negligible for larger tasks, but for a
small function that is called millions of times it makes a big difference!

And all of this without even considering the elephant in the room, that is
the fact that with virtually zero extra effort - but again, see the "Gotchas"
section below - one can parallelize C++ STL algorithms and make them an order
of magnitude faster on modern hardware! In C I would have needed to write a
parallel sort on my own with something like
[pthreads](https://en.wikipedia.org/wiki/Pthreads).

Lesson learned for a C developer: sometimes the extra complexity of
other languages does bring some benefit.

## Gotchas

I mentioned above that I had some trouble compiling and running the
parallel version of my code. In fact it took me almost two hours to make
it work! This was for a couple of reasons.

The first reason is that, at least on Linux with GCC + GLIBC, the C++
standard library requires
[TBB](https://en.wikipedia.org/wiki/Threading_Building_Blocks). I
figured this out rather early, and it did not take me long to learn
that I had to add an `-ltbb` option to my command line either. What
took me an incredibly long time to understand is that `-ltbb` had to
be put *at the end* of the command line options! To make it clear,
something like this:

```
$ g++ -O3 -std=c++20 -ltbb -o sort sort_parallel.cpp
```

does not work, you have to write

```
$ g++ -O3 -std=c++20 -o sort sort_parallel.cpp -ltbb
```

Another problem I had was caused by my use of macros. You can see
in the source files that I am using an `ARRAYSIZE` macro for the
size of the array, and I provide a value for it at compile time.
Originally I had called this macro `N`, but this clashed with some
internal name used in TBB, and I got all sorts of walls of text
of weird template errors - something C++ is infamous for.

The last issue I had was that I was stupid and tried to compile my
C++ code with a C compiler. Indeed, while debugging the issue with
`-ltbb` I tried switching to [clang](https://clang.llvm.org), because
I sometimes get better error messages with it. But instead of using
`clang++` I used `clang`, which only compiles C.

## Until next time?

Now that I have broken the ice with C++ I think it will be easier
to continue studying it. I may or may not keep writing about this here:
turning this into another blog series may be a good way to force myself
to do this regularly, but on the other hand it may not be interesting
for my readers. We'll see!

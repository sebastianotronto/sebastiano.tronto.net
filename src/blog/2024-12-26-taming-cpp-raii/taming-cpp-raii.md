# Taming C++, episode 2: RAII

*This post is part of a [series](../../series)*

After publishing
[the previous post on this topic](../2024-04-30-taming-cpp-motivation),
I have not actually done much with C++, besides reading some more about
it. However, a few weeks ago I attended a three-day C++ training at work,
so I decided to pick up this blog series again (thus actually turning
into a series).

For this episode I decided to focus on one of the defining features
of C++: resource management and RAII ("Resource Acquisition Is
Initialization"). So in this post I'll talk about constructors and
destructors and how to use them to make resource management safer than
with C. I'll also discuss copy and move operations, which are part of
the same family as constructors and destructors.

Since this post does not want to be a C++ tutorial, I am going
to explain little to none of the syntax. I hope it will be easy
to follow along anyway, even for someone who does not know C++.
In any case, you will find throughout this page many links to
[cppreference.com](https://en.cppreference.com/w/), an incredible resource
for all things C++.

As for the previous post, I added some code in a
[git repository](https://git.tronto.net/taming-cpp) with the
examples discussed here.

Let's start with one practical example!

## Impress your friends with this simple trick

Consider the following C++ program:

```
class BadType {
	// Stuff
};

int main() {
	BadType x;
	return 0;
}
```

This program does nothing. Well, almost nothing. It allocates a variable
of a custom type called `BadType`. But then it does nothing with it,
it just exits returning a 0 value (success). So, assuming it compiles,
it can never fail, right?

Right?

No, of course not, otherwise I would not be asking. For example, the
class BadType may contain a *member variable* (for C programmers:
that's C++ for "struct field") too large to be
[allocated on the stack](https://en.wikipedia.org/wiki/Stack-based_memory_allocation),
such as an array of 100 million integers.

But there is a more interesting way to make this program fail by only
changing the definition of `BadType`. In fact, you can make this program
do pretty much everything you want by changing `BadType`'s *constructor*
to suit your needs (see
[surprising-error.cpp](https://git.tronto.net/taming-cpp/file/raii/surprising-error.cpp.html)):

```
class BadType {
	BadType() {
		BadType recursion_hell;
	}
};
```

The program now compiles without errors, and it immediately crashes.
And all it does is declaring variables! But in C++, every time a variable
of a *class type* is declared without any explicit initialization value,
the corresponding
[default constructor](https://en.cppreference.com/w/cpp/language/default_constructor)
is called. And declaring a variable of `BadType` inside its own default
constructor produces an artistic infinite recursion.

And it does not stop here either: whenever a variable
of a class type goes out of scope, the corresponding
[destructor](https://en.cppreference.com/w/cpp/language/destructor)
is called - see
[constructor-hello-world.cpp](https://git.tronto.net/taming-cpp/file/raii/constructor-hello-world.cpp.html):

```
#include <iostream>

class BadType {
public:
	BadType() {
		std::cout << "Variable created!" << std::endl;
	}

	~BadType() {
		std::cout << "Variable destroyed, bye bye" << std::endl;
	}
};

int main() {
	BadType x;
	return 0;
}
```

Of course, printing silly messages is not the point of constructors
and destructors. The point is managing resources such as memory,
files and network connections.

But before we get into that, let's take a moment to reflect on this
example.  For me, the main point here is that C++ does a lot of stuff
under the hood. This is, as most things in C++, a double-edged sword:
on the one hand, you can implement all sorts of interesting mechanisms
of initialization and clean-up for your custum types; on the other hand,
you constantly have to keep in mind that all of this stuff exists just
to get the hang of a simple C++ program.

Ok, now let's talk about resource management!

## Resource Acquisition Is Initialization (RAII)

[RAII](https://en.cppreference.com/w/cpp/language/raii) is a resource
management technique widely used in C++, but also in some other
languages.  My personal interpretation is this: ONLY allocate resources
with `malloc()`, `new`, `fopen()` and other dangerous operations *in
constructors*, and ONLY de-allocate them with the respective `free()`,
`delete`, `fclose()` and other dangerous operations in the respective
*destructors*.

Let's see a classic example. Say you have a function `f()` that, for
some reason, needs to work with a large array locally. If you allocate
it on the heap with `new` or `malloc()`, you must remember to `delete`
or `free()` it in every place where the function returns:

```
bool f(unsgined big_number) {
	// In C: int *a = malloc(big_number * sizeof(int));
	int *a = new int[big_number];

	if (/* some condition */) {
		// Remember to release the memory here!
		delete[] a;
		return false;
	}

	// Do stuff...

	// Also here!
	delete[] a;
	return true;
}
```

In C, a clean way to do this is to use the `goto` statement (yes, I know,
[considered harmful](https://en.wikipedia.org/wiki/Considered_harmful)
blah blah) more or less like this:

```
bool f(unsgined big_number) {
	bool return_value = true;
	int *a = malloc(big_number * sizeof(int));

	if (/* some condition */) {
		return_value = false;
		goto f_cleanup_and_return;
	}

	/* Do stuff... */

f_cleanup_and_return:
	free(a);
	return return_value;
}
```

Which is all fine and good, but wouldn't it be better if this
de-allocation happened automatically based on the scope of the pointer
`a`, just like if we had allocated it on the stack? This can be achieved
in C++ using constructors and destructors, for example:

```
class ArrayThing {
public:
	// Constructor
	ArrayThing(unsigned n) {
		buffer = new int[n];
	}

	// Destructor
	~ArrayThing() {
		delete[] buffer;
	}

	// You probably want something like this:
	int& operator[](unsigned i) {
		return buffer[i];
	}
private:
	int *buffer;
};

bool f(unsigned big_number) {
	ArrayThing a(big_number);

	if (/* some condition */) {
		return false; // Destructor is called, a is cleaned!
	}

	// Do stuff...

	return true; // Destructor is called, a is cleaned!
}
```

And this, as far as I understand it, is the essence of RAII. The same
concept applies not only to memory allocation, but also to other
resource-management operations, such as opening files or locking
a [mutex](https://en.wikipedia.org/wiki/Lock_(computer_science)).

The example above is only for illustrative purposes: in practice
if you want to achieve this result you should use a standard library
container such as
[`std::vector`](https://en.cppreference.com/w/cpp/container/vector)
or
[`std::array`](https://en.cppreference.com/w/cpp/container/array);
but these standard classes do pretty much the same thing under the hood.

## Copying and moving

So far I have only talked about constructors and destructors, but C++
offers control over two other mechanisms: *copy* and *move*. Both of
these come in two forms, a *constructor* form and an *assignment* form.

Copy and move operations can be summarized as follows:

* **Copy** is the operation that consists of creating or assigning a
  `target` object from a `source` object of the same type, copying the
  value of the source into the target. They act similarly to a regular
  constructor; a copy assignment must also take care of cleaning up
  the resources of the target object before copying the value.
* **Move** is the operation that consists of creating or assigning a
  `target` object from a `source` object of the same **and then immediately
  destroying the source object**, moving the value of the source into the
  target. They act both as constructors for `target` and as destructors
  for `source`; a move assignment must also take care of cleaning up
  the resources of the target object before moving the value.

Copy operations happen whenever you create an object from another one,
for example with `T a(b)` or `a = b`. Move operations are perhaps a bit
harder to understand, but they also happen regularly; returning an object
from a function is a classic example, but they also come up when using
[smart pointers](https://en.cppreference.com/book/intro/smart_pointers).

I made a
[comprehensive example](https://git.tronto.net/taming-cpp/file/raii/all-constructors.cpp.html)
of how all of these operations work, so you can see when exactly each
of them is called. Do check it out if you are interested!

Finally, I have tried summarizing the construction, destruction, copy
and move operations in the table below:

|Operation                                                                      |Signature          |Construct target|Destroy (old) target|Destroy source|
|:------------------------------------------------------------------------------|:------------------|:--------------:|:------------------:|:------------:|
|Constructor                                                                    |`T(...)`           |✓               |N/A                 |N/A           |
|[Destructor](https://en.cppreference.com/w/cpp/language/destructor)            |`~T()`             |❌              |✓                   |N/A           |
|[Copy constructor](https://en.cppreference.com/w/cpp/language/copy_constructor)|`T(T&)`            |✓               |N/A                 |❌            |
|[Copy assignment](https://en.cppreference.com/w/cpp/language/copy_assignment)  |`T& operator=(T&)` |✓               |✓                   |❌            |
|[Move constructor](https://en.cppreference.com/w/cpp/language/move_constructor)|`T& T(T&&)`        |✓               |N/A                 |✓             |
|[Move assignment](https://en.cppreference.com/w/cpp/language/move_assignment)  |`T& operator=(T&&)`|✓               |✓                   |✓             |

## Conclusion

Manual resource management (in particular, memory management) and RAII
are defining features of C++, features that clearly set it apart from
other object-oriented languages like Java or C#.  C++ gives you a lot
of control over the low-level details, and some powerful tools to make
use of it, in exchange for a lot of complexity that you must, at the
very least, be aware of.

# Taming C++, episode 3: templates, constraints and concepts

*This post is part of a [series](../../series)*

If you have ever written some C++, you have probably already used
[templates](https://en.cppreference.com/w/cpp/language/templates).
For example, you may have done something like this:

```
std::vector<int> v {1, 2, 3};
v[1] = -1;
std::cout << v[0] << ", " << v[1] << ", " << v[2] << std::endl;
```

The type
[`std::vector<int>`](https://en.cppreference.com/w/cpp/container/vector)
is the *specialization* of the *class template* `std::vector`. If you
wanted a vector of chars, for example, you could do something like this:

```
std::vector<char> w {'a', '!', '\n' };
```

Oversimplifying a bit, a template in C++ is a type (or a
[function](https://en.cppreference.com/w/cpp/language/function_template))
that depends on some other type or constant. They are quite powerful,
because they do a lot of work at compile time, so you can write generic
code without impacting performance. But at the same time they can be
quite intimidating, because as soon as you get something wrong around
templates the compiler will throw hundreds of lines of unreadable
error messages at you.

In this post I'll briefly explain what templates are and how to
write simple class and function templates. After that, I am going to
work through a little piece of code I wrote, starting from a simple
implementation and working out a general "templatized" version
step by step. I am going to use C++20 so that I can make use of
[concepts](https://en.cppreference.com/w/cpp/language/constraints),
so make sure to compile with `-std=c++20` if you are compiling with a
current version of GCC or Clang - in the future it may not be necessary
anymore, but currently both major compilers default to C++17.

You can find the code examples for this post in the
[companion repository for this series](https://git.tronto.net/taming-cpp),
and if you want you can also have a look at the final version
of my tiny library
[on my git page](https://git.tronto.net/zmodn/file/README.md.html). For
this post I am going to use Clang as a compiler, because I find its
error messages more readable most of the times.

## Templates

The first thing one must understand about templates is that **a
[class template](https://en.cppreference.com/w/cpp/language/class_template)
is not a class, it is a template for a class**.  Similarly, a function
template is not a function, it is a template for a function.

This means that a class template must be *specialized* to become an
actual class. The compiler won't generate any code for templates that
are not used anywhere. In other words, a template becomes something
concrete only when you provide concrete template arguments.

Different specializations of the same template are different types: one
cannot, for example, assign an `std::vector<int>` object to an
`std::vector<double>` variable.

### Class templates

As an example, let's take a simple standard library class such as
[`std::pair`](https://en.cppreference.com/w/cpp/utility/pair).
It could be implemented as follows (see
[pair.cpp](https://git.tronto.net/taming-cpp/file/templates/pair.cpp.html)):

```
template<typename S, typename T>
class Pair {
public:
	S first;
	T second;

	Pair(S s, T t) : first{s}, second{t} {}

	void print() const { // Kinda useless, but I need it to explain a thing
		std::cout << "(" << first << ", " << second << ")";
	}
};
```

And then you can declare variables of type `Pair` - or rather, of a
specialization of `Pair`:

```
Pair<int, char> p(42, 'x');
```

The compiler can also deduce the template argument types for you, so
the statement above is equivalent to

```
Pair p(42, 'x');
```

So using templates is not that hard. Nice!

### Splitting declaration and implementation

Let's say you want to make our example class template `Pair` a bit cleaner
by splitting the declaration and the implementation of the `print()`
function. To do so, we have to re-declare the template parameters:

```
template<typename S, typename T>
class Pair {
public:
	S first;
	T second;

	Pair(S s, T t) : first{s}, second{t} {}

	void print() const;
};

template<typename S, typename T>
void Pair<S, T>::print() const {
	std::cout << "(" << first << ", " << second << ")";
}
```

The syntax is not amazing, but it can be worth it for longer functions.

### Function templates

Templates are not limited to classes, we can also have function templates.
A classic example is a
[swap](https://en.cppreference.com/w/cpp/algorithm/swap) function, which
can be implemented like this:

```
template<typename T>
void swap(T& a, T& b) {
	T tmp = a;
	a = b;
	b = tmp;
}
```

(Here I am using
[references](https://en.cppreference.com/w/cpp/language/reference),
which in case you don't know are just a simplified syntax for pointers.)

Let's take this simple example to show an important property of templates.
Let's say that, perhaps by mistake, we implemented the swap function
using different template types for `a` and `b` (see
[swap.cpp](https://git.tronto.net/taming-cpp/file/templates/swap.cpp.html)):

```
template<typename S, typename T>
void swap(S& a, T& b) {
	S tmp = a;
	a = b;
	b = tmp;
}
```

This is actually ok, because **templates are not type-checked until
they are specialized**. And in fact we may legitimately want to
swap variables of different types, for example:

```
int x = 3;
double y = 1.0;
swap(x, y);
```

The code above will compile just fine, because C++ accepts implicit type
conversions between `int` and `double`. However, this:

```
int x = 3;
std::string y = "1.0";
swap(x, y);
```

Will not compile:

```
swap.cpp:6:6: error: assigning to 'int' from incompatible type 'std::basic_string<char>'
    6 |         a = b;
      |             ^
swap.cpp:13:2: note: in instantiation of function template specialization 'swap<int, std::basic_string<char>>' requested here
   13 |         swap(x, y);
      |         ^
1 error generated.
```

The error messages we get when misusing templates are not always nice
and readable as this one, they can literaly be hundreds of lines long.
Luckily, C++20 introduced
[constraints and concepts](https://en.cppreference.com/w/cpp/language/constraints)
to make these error messages more meaningful - we'll see some examples below.

### Non-type parameters

Objects, not just types, can be template parameters. A classic example
is [`std::array`](https://en.cppreference.com/w/cpp/container/array),
a fixed-size container where the capacity is fixed at compile time (see
[std_array.cpp](https://git.tronto.net/taming-cpp/file/templates/std_array.cpp.html)
for an example).

Non-type parameters can be constants of any *structural type* - see
[this page](https://en.cppreference.com/w/cpp/language/template_parameters)
for a precise definition. Remember that you can only specialize them
with compile-time (i.e. `constexpr`) constants!

With non-type parameter you can do pretty wild stuff, see for example
[factorial.cpp](https://git.tronto.net/taming-cpp/file/templates/factorial.cpp.html)
- although this specific example is not very useful, since it can easily
be replaced by a constexpr function.

Fun fact: if you use `auto`, you don't even have to specify a type for
a non-type parameter. For example, the following code works just fine (see
[println.cpp](https://git.tronto.net/taming-cpp/file/templates/println.cpp.html)):

```
#include <iostream>

template<auto X> void println() { std::cout << X << std::endl; }

int main() {
	println<1.23>();
	println<42>();

	return 0;
}
```

Later we'll see a more useful application of this.

### Default values

Template parameters can have default value, for example:

```
template<typename S = int, typename T = S>
class Pair {
public:
	S first;
	T second;

	// And so on...
```

With the code above, `Pair` is going to denote a pair of two integers,
and `Pair<double>` is going to denote a pair of two doubles.

Non-type parameters can have default values too:

```
template<typename T, int N = 10>
class MyArray {
	// A container with 10 elements by default
};
```

### Variadic templates

Like with functions, templates can have a variable number of parameters.
A classic example is
[`std::tuple`](https://en.cppreference.com/w/cpp/utility/tuple), which
works similarly to `std::pair`, but accepts any number of items.

## Contraints and concepts

To explain the last features I want to talk about, I am going to use a
simlpe, albeit slightly unusual, example: let's implement a class
template for
[the integers modulo `N`](https://en.wikipedia.org/wiki/Modular_arithmetic),
where `N` is a fixed at compile-time.

We may start with something like this (see
[zmodn-1.cpp](https://git.tronto.net/taming-cpp/file/templates/zmodn-1.cpp.html)):

```
#include <iostream>
#include <optional>
#include <tuple>

std::tuple<int, int, int> extended_gcd(int a, int b) {
	if (b == 0) return {a, 1, 0};
	auto [g, x, y] = extended_gcd(b, a%b);
	return {g, y, x - y*(a/b)};
}

template<int N>
class Zmod {
public:
	int value;

	Zmod(int z) : value{(z%N + N) % N} {}

	Zmod operator+(const Zmod& z) const { return value + z.value; }
	Zmod operator-(const Zmod& z) const { return value - z.value; }
	Zmod operator*(const Zmod& z) const { return value * z.value; }

	std::optional<Zmod> inverse() const {
		auto [g, a, _] = extended_gcd(value, N);
		return g == 1 ? Zmod(a) : std::optional<Zmod>{};
	}

	std::optional<Zmod> operator/(const Zmod& d) const {
		auto i = d.inverse();
		return i ? (*this) * i.value() : i;
	}

	std::optional<Zmod> operator/=(const Zmod& d) {
		auto q = *this / d;
		return q ? (*this = q.value()) : q;
	}
};

int main() {
	Zmod<57> x(34);
	Zmod<57> y(11);

	std::cout << "34 * 11 = " << (x * y).value << " (mod 57)" << std::endl;

	if (auto inv = y.inverse(); inv)
		std::cout << "11 * " << inv.value().value << " = 1 (mod 57)" << std::endl;
	else
		std::cout << "11 is not invertible in Z/57Z" << std::endl;

	return 0;
}
```

So we are just using a single non-type template parameter, no big deal.

But now let's say that by accident I type something like:

```
int main() {
	Zmod<0> z(13); // Oops, I meant Zmod<10>
}
```

Unfortunately, this code is going to compile just fine, and I'll get
a horrible run-time error. It would be cool if there was some way
to *constrain* the template argument to only allow positive integers.
Which brings us to...

### Constraints

[Constraints](https://en.cppreference.com/w/cpp/language/constraints)
are a way to prevent nasty run-time errors and / or make compiler errors
more meaningful when using templates; they were added in C++20.

In our case, introducing our constraint is quite simple (see
[zmodn-2.cpp](https://git.tronto.net/taming-cpp/file/templates/zmodn-2.cpp.html)):

```
template<int N>
requires (N > 1)
class Zmod {
	// Same as before...
};
```

And now if we try to compile the `Zmod<0>` declaration we get:

```
zmodn-2.cpp:51:2: error: constraints not satisfied for class template 'Zmod' [with N = 0]
   51 |         Zmod<0> z(157);
      |         ^~~~~~~
zmodn-2.cpp:12:11: note: because '0 > 1' (0 > 1) evaluated to false
   12 | requires (N > 1)
      |           ^
1 error generated.
```

Nice!

### Making it more generic

For one specific application of this class, which I may write about in
a future post, I need `N` to be very larger, larger than a 32-bit
integer. So I should probably change `int` to `long long` or `int64_t`.
Except I would like to work with numbers that are even larger than 64
bits!  This means I should find (or write) a library for large integers,
but at the same time I want to keep the `Zmod` class independent of a
specific library... I should definitely make `Zmod` parametric in the
type of N.

In order to do so, I can use a non-type parameter declared `auto` and
[`decltype()`](https://en.cppreference.com/w/cpp/language/decltype) (see
[zmodn-3.cpp](https://git.tronto.net/taming-cpp/file/templates/zmodn-3.cpp.html)):

```
template<auto N>
requires (N > 1)
class Zmod {
public:
	decltype(N) value;

	Zmod(decltype(N) z) : value{(z%N + N) % N} {}

	// The rest is unchanged
};
```

And of course I should also templatize the `extended_gcd()` function -
you can see the full code in
[zmodn-3.cpp](https://git.tronto.net/taming-cpp/file/templates/zmodn-3.cpp.html).

Now we can use any type as a "base" for our modular integer! Well, almost.
I mentioned above that the type we use must be *structural*, but that is
relatively easy to satisfy. A bigger problem is that our type must
allow for compile-time constants - so we need, at least, a `constexpr`
constructor. I could not find a suitable library online, so I ended
up writing my own - see
[bigint.h](https://git.tronto.net/taming-cpp/file/templates/bigint.h.html).

The code is simple and not very efficient, but this library is not meant
to be efficient. I am just using it for educational purposes.

To show it off, we can do stuff like this:

```
int main() {
	constexpr BigInt N("1000000000000000000000000000000");
	Zmod<N> x(BigInt("123456781234567812345678"));
	Zmod<N> y(BigInt("987654321987654321"));

	std::cout << x.value << " * "
	          << y.value << " (mod " << N << ") = "
	          << (x * y).value << std::endl;

	// Prints:
	// 123456781234567812345678 * 987654321987654321 (mod 1000000000000000000000000000000) = 5237873798636805364022374638

	return 0;
}
```

But now we have once again a constraint problem. We could for example write

```
	constexpr double M = 3.14;
	Zmod<M> z(M);
```

And sure, this will fail with an understandable error message related to
the modulo operation `%`, but it is not hard to imagine that in other
situations this could be a problem. So we should put a constraint on
our type, in this case `decltype(N)`.

At first I achieved this using the *type trait*
[`std::is_integral`](https://en.cppreference.com/w/cpp/types/is_integral):

```
template<auto N>
requires (N > 1) && std::is_integral<decltype(N)>::value
class Zmod {
	// Etc...
};
```

Type traits are defined in the `<type_traits>` header. For an overview
check out this nice
[blog post](https://www.internalpointers.com/post/quick-primer-type-traits-modern-cpp).

Unfortunately, my custom big integer class does not satisfy
`std::is_integral`.  So I have to define my own set of constraints.

### Concepts

Along with constraints, C++20 also introduced the possibility to define
and name a custom set of requirements. This can be done with *concepts*.
In our example, we can require that our type supports all the operations
we need (see
[zmodn-4.cpp](https://git.tronto.net/taming-cpp/file/templates/zmodn-4.cpp.html)):

```
template<typename T>
concept Integer = requires(T a, T b, int i) {
	{T(i)};

	{a + b} -> std::same_as<T>;
	{a - b} -> std::same_as<T>;
	{a * b} -> std::same_as<T>;
	{a / b} -> std::same_as<T>;
	{a % b} -> std::same_as<T>;

	{a == b} -> std::same_as<bool>;
	{a != b} -> std::same_as<bool>;
};
```

Let's break this down. The first line introduces a template, because our
concept depends on a type parameter `T`. The second line introduces the
definition of the concept: the arguments to the `requires` keyword are
variables that we are going to use in our concept definition.

The third line is where things get interesting. The notation `{T(i)}`
means "`T(i)` must be a valid expression", where `i` is any variable of
type `int`, as defined in the `requires` arguments. In other words, we
are asking that type `T` has a constructor that takes a single integer
parameter.

The other lines are all similar, and they expand on this concept.
For example `{a % b} -> std::same_as<T>` requires that the operator `%` is
defined between variables of type T; moreover, the `-> std::same_as<T>`
notation declares that we want the resulting type to satisfy the
type trait `std::same_as<T>` - in other words, we are asking for
`T operator%(T)` to be defined as a member function of `T`.

Note that we are not requiring anything about what these operations
actually do: we are only requiring that they are defined. If for some
reason a custom floating point type defines an operator `%` and all other
arithmetic operations that we require, it could be used for our `zmod<N>`
class without any complaints from the compiler, but the results may not
be what we expect.

We can use our newly-defined concept in two ways. As part of a requires
clause:

```
template<typename T>
requires Integer<T>
std::tuple<T, T, T> extended_gcd(T a, T b) { /* Same as before */ }

template<auto N>
requires (N > 1) && Integer<decltype(N)>
class Zmod { /* Same as before */ }
```

Or with the following syntax sugar:

```
template<Integer T>
std::tuple<T, T, T> extended_gcd(T a, T b) { /* Same as before */ }

template<Integer auto N>
requires(N > 1)
class Zmod { /* Same as before */ }
```

I tend to prefer the second way because it is more compact and it reads
nicely: in the first of the two templates, we declare `T` as if it were
a variable of type `Integer`.

And now if we try to compile `Zmod<3.14>` the compiler gives us a clear
error message:

```
zmodn-4.cpp:68:3: error: constraints not satisfied for class template 'Zmod' [with N = 3.140000e+00]
   68 |          Zmod<M> z(4);
      |          ^~~~~~~
zmodn-4.cpp:29:10: note: because 'decltype(3.1400000000000001)' (aka 'double') does not satisfy 'Integer'
   29 | template<Integer auto N>
      |          ^
zmodn-4.cpp:16:5: note: because 'a % b' would be invalid: invalid operands to binary expression ('double' and 'double')
   16 |         {a % b} -> std::same_as<T>;
      |            ^
1 error generated.
```

## Conclusion

Templates are a very powerful tool that allow creating zero-cost
abstractions (if you don't count the longer compile time as a cost).
With the addition of constraints and concepts in C++20 it became easier to
define requirements on the template parameters and catch template misuse
at compile time.

In some way concepts offer a new style of abstraction, similar in scope
to object-oriented programming. Since I am not a fan of OOP, I like that
we have this new option, and I am going to play around with whenever I
get the chance.

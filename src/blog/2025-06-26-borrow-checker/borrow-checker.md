# Stunned by the borrow checker 🦀

As I mentioned in my [last post](../2025-06-13-cargo-culture-shock),
in the last couple of weeks I have been learning Rust. I have written
[a small library](https://git.tronto.net/zmodn-rs/file/README.md.html) for
[integers modulo N](https://en.wikipedia.org/wiki/Modular_arithmetic)
(the original C++ version was mentioned in
[this post](../2025-01-21-taming-cpp-templates), rewritten
[my implementation](https://git.tronto.net/ecm/file/README.md.html)
of the
[ECM algorithm](https://en.wikipedia.org/wiki/Lenstra_elliptic-curve_factorization)
(mentioned in [this other post](../2025-02-27-elliptic-curves-javascript))
and I am now playing around with some past
[Advent of Code](https://adventofcode.com/) problems.

But today I won't talk about any of the above. Instead, I just want to show
you a small example of code that kept me confused for a couple of hours.

First, I need to very briefly explain Rust's concept of ownership.

## The borrow checker

The *borrow checker* is a unique feature of Rust that prevents certain
kinds of memory errors and data races. Without going into too much
detail, the borrow checker is a compile-time mechanism that ensures that,
at any given point, a given object is owned by at most one reference,
unless all references to it are *immutable* (that is, they don't allow
modifying the object).

As a simple example, the following code is not valid:

```
fn main() {
    let mut x = 2; // mut means mutable, without it x would be a constant
    let y = &x; // & means reference
    x = 3;
    println!("{x} {y}");
}
```

And the compiler gives a clear explanation:

```
error[E0506]: cannot assign to `x` because it is borrowed
 --> t.rs:4:5
  |
3 |     let y = &x;
  |             -- `x` is borrowed here
4 |     x = 3;
  |     ^^^^^ `x` is assigned to here but it was already borrowed
5 |     println!("{x} {y}");
  |                   --- borrow later used here
```

What happens is that creating a (mutable) reference `y` that refers to
`x`, *borrows* the object referred to by the name `x`, so `x` cannot be
used directly anymore until `y` goes out of scope.

If you want to know more, check out the
[ownership chapter in the book](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html).

## A tricky example

Let's say we have a vector of vectors, and we want to copy an element from
one of the internal vectors to another. We could try something like this:

```
fn main() {
    let mut v = vec![vec![23], vec![42]]; // v is now {{23}, {42}}
    v[0].push(v[1][0]);
}
```

But this won't compile. Indeed we get:

```
error[E0502]: cannot borrow `v` as immutable because it is also borrowed as mutable
 --> a.rs:3:15
  |
3 |     v[0].push(v[1][0]);
  |     -    ---- ^ immutable borrow occurs here
  |     |    |
  |     |    mutable borrow later used by call
  |     mutable borrow occurs here
  |
  = help: use `.split_at_mut(position)` to obtain two mutable non-overlapping sub-slices
```

However, the following works just fine:

```
fn main() {
    let mut v = vec![vec![23], vec![42]];
    let x = v[1][0];
    v[0].push(x);
}
```

And at this point I was very confused. Whatever the borrow checker does,
shouldn't the two pieces of code do exactly the same?  I got stuck for
a while thinking that for some reason the function argument of `push()`
was passed by reference in the first case, while it was copied in the
second, but this is not where the problem lies.

I was finally able to understand the problem when I realized that my first
piece of code is equivalent to the following, which also does not compile:

```
fn main() {
    let mut v = vec![vec![23], vec![42]];
    let mut v0 = &mut v[0];
    let x = v[1][0];
    v0.push(x);
}
```

Can you see the issue now?

## Explanation

Like in C++ and many other languages, the square
bracket operator is a method on the vector object.
More precisely, in Rust it is syntactic sugar for either the
[`index()`](https://doc.rust-lang.org/std/ops/trait.Index.html) or the
[`index_mut()`](https://doc.rust-lang.org/std/ops/trait.IndexMut.html)
functions, depending if mutability is requested in our usage. In our
example, when we call `v[0].push(...)` this will be translated to a call
to `index_mut()`, because `push()` requires a mutable reference; when
we do e.g. `let x = v[1][0]`, the immutable version will be call instead.

But the details of `[]` are not important for us. The cause of the problem
is that `let mut v0 = &mut v[0]` creates a mutable reference to *part
of* the object `v`. At this point, `v` is borrowed and cannot be used
directly anymore, even if we just want to immutably access some other
parts of it to make a copy. Thus, when we try to do `let x = v[1][0]`,
the borrow checker complains.

In the first version of my code all of this happens in the same line,
and this makes it confusing, because the order in which the various
statements of that line are executed is very important.

## Solution

Solving the problem is easy, I can just use the second version of my code.
Alternatively I could also try to use `split_at_mut()` as suggested
by the compiler, but this seems overkill in this case; good to keep in
mind though.

But sometimes understanding a problem is more important than finding
a solution.

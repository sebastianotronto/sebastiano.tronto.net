# Cargo culture shock 🦀

After a long adventure
[porting my cube solver to the web](../2025-06-06-webdev), I decided to
try out something completely different, like learning a new language.
Rust is one on my to-do list, and it has been there for more than 10
years - I remember reading about it in my first year in university,
so it must have been 2013 or early 2014.

So I started by quickly reading through the first few chapters of
[the book](https://doc.rust-lang.org/book/) to get an idea of the basic
syntax. Before I move on to implementing something, I thought I could
share my very early impression of the language and the tooling around it.

*Note: this is a relaxed write-up and I have a very superficial
understanding of the topic. I am going to use strong words for the things
that I did not like, but there are many things I like about Rust so
far. In fact, my first impression of the language, the documentation and
the tools is very positive! Keep this in mind while reading this post.*

## What is Rust about?

Before getting started with the Rust book, my impression was that Rust
was mostly about *safety* as in *memory safety*, and that it achieved
this by enforcing strict rules, leading to more correct programs overall.

But [the foreword](https://doc.rust-lang.org/book/foreword.html) says "the
Rust programming language is fundamentally about *empowerment*". Uh, that's
weird. I was expecting "something something *safety*". And actually,
I was hoping for "something something *correctness*".  Definitely not
"something something *empowerment*". *Empowerment* sounds like one of
those meaningless words that managers use when they have nothing to say.

Anyway, empowerement it is. Let's move on to actually using the thing.

## Installation

The officially endorsed way of installing Rust is the following:

```
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

The horror, the horror! Is this really what they suggest? The very thing
that *everyone* told you not to do in nerd forums until a few years ago,
even worse than copy-pasting commands from the internet, is now THE
suggested way of installing software? Seriously, piping a random web
page into `sh`?

I don't know what this script does, is it going to download even more
random shit from the internet? (Answer: yes, it is!) Is it going to fuck
up my environment by puking configuration lines into my .bashrc? (Answer:
yes, it is!)

But ok, what do I know. Maybe I am just living in the past, I should
embrace the future, because package managers and `make && make install`
*are so 1999, man*. So I took a deep breath an run the command.
Luckily the script kindly asked "do you want me to fuck up your
environment? [default: Yes]". I may be paraphrasing this, it probably
mentioned `.bash_rc` and `.profile`. Anyway, you can easily say "no"
and skip this fuckery. And then manually update a couple of environment
variables in your shell configuration file, which is what the script was
trying to do. I guess developers today are not expected to know how to
do this.

The installation was quick and everything went fine. Moving on!

## Cargo cult

[Cargo](https://doc.rust-lang.org/book/ch01-03-hello-cargo.html) is
Rust's build system and all-in-one tool. It can create a new project
with a default folder structure, compile code (running `rustc` under
the hood`), run tests, and more. Oh and it is also a *package manager*,
which apparently is something modern programming languages decided they
needed - more on that later.

I don't always like these kind of tools, becase they tend to do a lot of
things that you don't understand with the files in the current directory.
Like vomiting generated files that you are supposed to check into your
[VCS](https://en.wikipedia.org/wiki/Version_control) - which kinda
defeats the purpose of *generating* files in the first place, doesn't it?

Luckily, Cargo does not do too much of this. It generates an `src` folder
with a simple "hello world" program, a pretty minimal `Cargo.toml`
configuration file, and it initializes a git repo. All reasonable,
and most importantly easy to understand.

On the first run of `cargo build` it also generates a `target` folder
for the build artifacts (already in `.gitignore`) and it generates
only one of those vomit files that I am supposed to check into git
(`Cargo.lock`), which I promptly added to .gitignore. Apparently it is
mainly about dependencies, and I'd rather not use any for now.  So all
in all I am satisfied with this process.

About dependencies, you can specify some packages, or *crates*, that your
projects depends on. These *crates* are going to be downloaded as they are
needed from [crates.io](https://crates.io/).  You can of course specify
some constraints on the version for each specific crate, like "at least
2.0" or "at least 0.8.5, but less than 0.9.0". Here is where `Cargo.lock`
comes into play: if there is more than one version available for a given
crate that satisfies the contraints you impose in `Cargo.toml`, the first
time a specific version is used it gets written to `Cargo.lock`, so that
you will keep using that version even if a new one becomes available.
You are supposed to check in this file to git so other developers working
on the same project will use exactly the same version of each dependency.

I can't quite understand this. If I don't want to update to a later
(minor) version of the dependency, I can already specify this in
`Cargo.toml`. If instead I impose more relaxed requirements, then it
means that any version satisfying those requirements is fine, and I
in this case *I do want* to try different versions within the allowed
range, to make sure that my assumptions are correct. So I am confused
about why this Cargo.lock business is needed at all.  But I guess if
the time ever comes that I need to include dependencies in my project -
probably in the far future, *right?* - then I can just specify an exact
version and happily ignore `Cargo.lock`.

Anyway, coming from a mostly C and C++ background where there is no
standard way of including dependencies, all of this is certainly quite
interesting.

## Dependencies?

Chapter 2 contains a simple code example.
[This part](https://doc.rust-lang.org/book/ch02-00-guessing-game-tutorial.html#generating-a-secret-number)
caught my attention:

"Rust doesn't yet include random number functionality in its standard library."

Uh, ok. And then people complain about C having a small standard library.
It then continues:

"However, the Rust team does provide a
[`rand` crate](https://crates.io/crates/rand) with said functionality."

Ok, but... if this is provided by the Rust team, why not including it in
the standard library? Maybe it is still in beta, Rust is not a "finished"
project as far as I understand. I would think 15 years is enough to ship
a random number generator, though.

The tutorial tell us to add `rand` to our dependencies in `Cargo.toml`.
Simple enough. But then, if we launch `cargo build` again:

```
cargo build
  Updating crates.io index
   Locking 15 packages to latest Rust 1.85.0 compatible versions
    Adding rand v0.8.5 (available: v0.9.0)
 Compiling proc-macro2 v1.0.93
 Compiling unicode-ident v1.0.17
 Compiling libc v0.2.170
 Compiling cfg-if v1.0.0
 Compiling byteorder v1.5.0
 Compiling getrandom v0.2.15
 Compiling rand_core v0.6.4
 Compiling quote v1.0.38
 Compiling syn v2.0.98
 Compiling zerocopy-derive v0.7.35
 Compiling zerocopy v0.7.35
 Compiling ppv-lite86 v0.2.20
 Compiling rand_chacha v0.3.1
 Compiling rand v0.8.5
 Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
  Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.48s
```

Woho wait a minute. I have only added one dependency! Just a random
number generator!  Why is it building 15 packages now? Where does all
of this come from? Surely these are not dependencies dragged in by
the `rand` crate, *right?*

Well, apparently they are. If we want to generate a random number, we
need 15 external packages. I would imagine this makes Rust completely
unusable in a professional setting, because nobody would want to audit
15 separate crates just to include a random number generator. And no
professional programmer would include dependencies in a serious project
without first auditing them, *right?* *RIGHT?!*

I mean, each dependency introduces an extra liability in your project;
it is code that you can't control and you never know when it is going to
break. And this is why serious programmers, select dependencies carefully
and only use them when absolutely necessary... *right?*

Ahah, of course they do not. Remember the
[letf-pad incident](https://en.wikipedia.org/wiki/Npm_left-pad_incident)?
Apparently Cargo is of the same breed as npm. And then we wonder why
the software industry is such a shitshow. *Just keep building on top
of the house of cards, man. It's going to be fine, man, don't bother
implementing low-level stuff, that's hard. Just trust random people on
the internet and ship their code, man.*

Bleah.

## The Rust language

So far I talked mostly about the tooling around Rust, but I said nothing
about the language itself.  I want to write some code before making a
more informed opinion about it, but the first impression is that it is
really nice!

I love the type system, especially
[enums](https://doc.rust-lang.org/book/ch06-00-enums.html)
and `match`. I like that this and stuff like `Option<T>` are
first-class citizens; you can do something similar in C++ with
[`std::variant`](https://doc.rust-lang.org/book/ch06-00-enums.html) and
[`std::optional`](https://en.cppreference.com/w/cpp/utility/optional.html),
but the syntax quickly gets messy. I guess this shows the advantage of
making a new language from scratch instead of being forced to live with
decades-old syntax for backwards compatibility.

I especially like this mechanism - Rust's enums, or `std::variant`, or
tagged unions, whatever you like to call them - for error handling. I find
them a better solution than exception, because they enforce correctness:
if your function can fail, your coding must handle it; you can't just
let an error message bubble up from the depths of Hell, wreak havoc in
your control flow and face the user with an "Object reference not set
to an instance of an object".  I think it is great that Rust endorses
this more thorough way of error handling from the start.

On the less-nice side of things, apparently
[integer overflow](https://doc.rust-lang.org/book/ch03-02-data-types.html?highlight=overflow#integer-overflow)
is still an issue. Eh. At least when compiling in debug mode overflows
are caught, which is nice. But in release mode the program is
going to "panic", which I was not expecting. I mistakenly thought
this was one of the issues that Rust was solving at compile time,
or maybe even at the level of language specification.

This brings me to another problem that I thought Rust would solve,
but it does not: accessing a out-of-bound index of an array also leads
to a panic. I was expecting "don't allow indexes out of bound" to be
included in Rust's compile-time checks, somehow. For example in Ada you
can declare an array to accept only values of a specific
[range type](https://en.wikibooks.org/wiki/Ada_Programming/Types/range),
so that out-of-bound errors are completely eliminated. Apparently a
"panic" is memory safe behavior, but it is definitely not *correct*
behavior.  I guess this was a big misunderstanding from my side: memory
*safety* does not mean memory *correctness* - Rust still allows you to
make mistakes related to memory.

## Documentation

A quick note on the documentation: it is very nice. The book is well
written, and I am enjoying reading through it, even though it is very
basic for me. It is also available offline - at least when installing
rust via `rustup` - which is something I always appreciate.

The compiler error messages, which I consider to be part of the
documentation as well, are simply amazing. Not only they are usually very
precise, not only they often suggest a fix, but they also point you out to
some piece of documentation so that you can learn why your code is wrong.
For example, if you try to compile this code with `rustc filename.rs`:

```
fn main() {
    println("Hello, world!");
}
```

You get:

```
error[E0423]: expected function, found macro `println`
 --> hello.rs:2:2
  |
2 |     println("Hello, world!");
  |     ^^^^^^^ not a function
  |
help: use `!` to invoke the macro
  |
2 |     println!("Hello, world!");
  |            +

error: aborting due to 1 previous error

For more information about this error, try `rustc --explain E0423`.
```

And if you run `rustc --explain E0423` as suggested:

```
An identifier was used like a function name or a value was expected and the identifier exists but it belongs to a different namespace.

Erroneous code example:

struct Foo { a: bool };

let f = Foo();
// error: expected function, tuple struct or tuple variant, found `Foo`
// `Foo` is a struct name, but this expression uses it like a function name

Please verify you didn't misspell the name of what you actually wanted to use here. Example:

fn Foo() -> u32 { 0 }

let f = Foo(); // ok!

It is common to forget the trailing ! on macro invocations, which would also yield this error:

println("");
// error: expected function, tuple struct or tuple variant,
// found macro `println`
// did you mean `println!(...)`? (notice the trailing `!`)

Another case where this error is emitted is when a value is expected, but something else is found:

pub mod a {
    pub const I: i32 = 1;
}

fn h1() -> i32 {
    a.I
    //~^ ERROR expected value, found module `a`
    // did you mean `a::I`?
}
```

I would not be surprised if the main reason why Rustaceans are so
enthusiastic about the language was actually how nice `rustc` is.
I expect working with this tool will be very pleasant.

## Moving on!

Apart from the
[culture shock](https://en.wikipedia.org/wiki/Culture_shock) of the
installation process and the dependency management, my first impression
of Rust is quite positive.  But as I said, I am just getting started
and my judgement is very superficial.  I do want to write some small
project in Rust, and I think I'll start from re-writing a simple
[math library for modular arithmetic](../2025-01-21-taming-cpp-templates/#constraints-and-concepts)
that I wrote in C++ some time ago.

Stay tuned for more 🦀

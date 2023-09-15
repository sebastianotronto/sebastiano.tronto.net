# Why C?

Love it or hate it,
[C](https://en.wikipedia.org/wiki/C_(programming_language)) has
consistently been one of the most popular languages for the last
50 years or so. How did it become so popular? And why are people
(like me!) still using it?

## Quirky, flawed, and an enormous success

I have recently read
[this article](http://cm.bell-labs.co/who/dmr/chist.html)
by Dennis Ritchie. Besides summarizing the history of the language,
in this paper Ritchie also tries to answer our first question. He
gives four reasons for C's success:

### UNIX

C was the system language of UNIX, and the popularity of UNIX in
the 70's and 80's made C popular too. In other words, UNIX was the
[killer app](https://en.wikipedia.org/wiki/Killer_application) of C.

### Simplicity

Ritchie phrases the simplicity of C in terms of how close it was to
machine instructions while still being sufficiently abstract. This
means that C compilers are easy to write, and the language could be
ported easily to different systems.

### Pragmatism

C was designed with a concrete goal in mind, not as some kind of
abstract, ideal programming language. It was always in touch with
the "real world" and the needs of programmers.

### Stability

Despite some changes throughout the years, C has always remained
remarkably stable and free of proprietary extensions.

## Why did I choose C?

In 2019 I began working on a
[Rubik's cube solver](https://nissy.tronto.net).
At the time I had basic or intermediate level knowledge of multiple
programming languages, but I was not an expert of any of them. I
considered many languages for this project, including C, C++, Java,
Python and Rust - this last one I did not know at the time, but I
have wanted to learn it since 2013 or so.

In the end I picked C, and these were the main reasons:

### Ubiquity

Since my program was going to be relevant to a small nice of people
who are not necessarily programmers, I wanted it to be as accessible
as possible in terms of required infrastructure (compiler, libraries).
Sure, I could provide *some* compiled executables, but not for all
systems. It would be much easier if people could just type `make`
or `./compile.sh`, and then run my program.

C compilers are everywhere, while the same cannot be said of e.g. Rust.

### Simplicity

Since C is a simple language, knowing a bit of C means knowing quite
a big portion of it, in contrast to, say, C++. For this reason C
was the language I was more confident picking up to start a big
project, despite having more experience with Java or C++ at the
time.

### Stability

I don't like to re-learn my language every couple of years for a
project that I am working on in my spare time.  Backward-compatibility
is a thing, but, as languages introduce more features, the preferred
idiomatic way to do certain things changes, and old code starts to
"smell" without any good reason.

[RANT]

*Python2 was killed and now a bunch of tiny programs (mostly
[Project Euler](https://projecteuler.net) solutions that I have
no reason to "port" do not run anymore :( I want my print statements
back!*

*It seems Java has a new way of doing GUIs every time I look at it.
When I read my first Java book,
[AWT](https://en.wikipedia.org/wiki/Abstract_Window_Toolkit) was the
standard. When I read a second book,
[Swing](https://en.wikipedia.org/wiki/Swing_(Java)) was all the rage.
Then I went to university and they taught me
[JavaFX](https://en.wikipedia.org/wiki/JavaFX).*

[/RANT]

### Performance

I knew from the start that performance was going to be important
for this project, not only from the algorithmic point of view but
also from the low-level side of things. I needed manual memory
management and little overhead. This ruled out Java and Python.

## Conclusion (and memes)

I think there are some interesting similarities between the reasons
of C's success acoording to Ritchie and the reasons I picked it for
my personal project. I don't consider myself a C expert, and I know
even less about the other languages I talked about in this post,
so take my opinion as it is.

Instead of pretending to be more knowledgeable than I am and writing
some clever and insightful conclusion for this post, here is a short
list of memes and folklore about the C programming language.
If you know more of them send me an email and I'll update the list!

* [[YouTube, song] Program in C](https://www.youtube.com/watch?v=tas0O586t80)
* [[YouTube, song] Write in C](https://www.youtube.com/watch?v=1S1fISh-pag)
* [[Text] Linus Torvalds on C vs C++](https://harmful.cat-v.org/software/c++/linus)
* [[Wikipedia] Duff's device](https://en.wikipedia.org/wiki/Duff%27s_device)

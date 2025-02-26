# Elliptic curves and JavaScript

At my company we regularly have talks and other knowledge events.
After attending many of these events, I decided to give a talk
about [elliptic curves](https://en.wikipedia.org/wiki/Elliptic_curve),
which I worked with during my PhD.

The intended audience consists of software developers, but their
background is mixed: some have studied Maths in university, but many did
not. Most are not familiar with abstract algebra other than polynomials
and matrices, let alone algebraic geometry. Considering all of this,
I decided to give a presentation about
[Lenstra elliptic curve factorization](https://en.wikipedia.org/wiki/Lenstra_elliptic-curve_factorization),
so I could also show some code and do a practical demo.

Since I gave a presentation on this topic to a different audience a
couple of years ago, I could have simply adapted the slides and used the
same code.  Instead, I took this as an opportunity to experiment with
new tools and languages. This post is a summary of what I have learned
while preparing this talk.

All the code I talk about in this post, including the source for the
slides, can be found in [this git repository](https://git.tronto.net/ecm).

## The code

For the practical part of the talk I had to write some code to demonstrate
the factorization algorithm. It's not much, maybe 200 lines or so, and
I already had a working Python version. It was a rather straightforward
implementation, and it used exceptions to handle the "a factor was found"
part of the algorithm; although this is not amazing coding style, it
was faithful to how the algorithm was originally explained - or to how
I wanted to explain it, anyway.

It was not bad code, but I wanted to experiment with something new.

### Adventures in C++

Recently I have been learning C++, and I wanted to experiment with some
of its more advanced features. So I decided to rewrite the whole thing.

I had a clear idea of where I wanted to start: a small
[library for modular arithmetic](https://git.tronto.net/zmodn/file/README.md.html),
with compile-time fixed
[modulus](https://en.wikipedia.org/wiki/Modular_arithmetic) via templates
and heavy use of
[type inference](https://en.wikipedia.org/wiki/Type_inference)
for seamless operations between regular integers and integers modulo N.
This endeavor was quite successful, and it taught me how to use
templates and concepts, which I have talked about in
[my previous blog post](../2025-01-21-taming-cpp-templates).

When working on the previous part, I made sure that any kind of integer
could be used as a base type for the modular integers, so I could use
some custom big integer types to show off the power of the factorization
algorithm with very large numbers. Unfortunately, I did not take into
account that with my setup I needed a big integer class that supported
*compile-time constants* - for example in the form of `constexpr`
constructors. I could not find any, so I decided to write
[my own big integer class](https://git.tronto.net/zmodn/file/bigint.h.html).
This was less successful: implementing an *efficient* big integer library
was not as straightforward as the modular integers library. I decided
not to care about efficiency for the time being, but that would come
back to bite me very soon.

Finally, I put these two libraries together and implemented the elliptic
curve factorization algorithm. This was not hard.  The only problem was
that it was excruciatingly slow when I used large numbers, undoubtedly
due to my half-assed big integer implementation.  I could restrict
myself to using regular 64-bit integers, but then I would have to use
to relatively small numbers, making the demo less interesting.  I looked
online for other big integer libraries that I could use and I found
[ctbignum](https://github.com/niekbouman/ctbignum), but I could not make
it work together with my modular arithmetic class. The day of the
presentation was approaching quickly, so I decided to go back to
my original Python implementation instead.

### Back to Python

When I looked back at my old Python implementation, I found it nicer
and cleaner than how I remembered it. I did not have to do much
cleanup, it was pretty much ready to go, and much more readable than
the C++ verion for anyone who is not a C++ expert - and probably for C++
experts too. Moreover, Python's seamless use of large integers was
exactly what I was missing from the C++ version.

One of the few changes I made to this code was reworking a little bit
the "elliptic curve point" class I used. If anything, this was a good
excuse to learn about
[dataclasses](https://docs.python.org/3/library/dataclasses.html). I also
decided to add
[type hints](https://docs.python.org/3/library/typing.html), which I
have recently found out about.

And with little work, the old code was ready to go!

## The slides

Compared to the code, the slides needed a few more adjustments.
When I gave this talk the first time, it was for an audience of
Math students at the end of their Bachelor program. I could freely
use all that Math jargon that we Mathematicians like, such as
"let K be a
[field](https://en.wikipedia.org/wiki/Field_(mathematics))"
and "E is a
[projective](https://en.wikipedia.org/wiki/Projective_space) curve".
But this time I had to phrase things differently. The content itself
didn't need much change, but I had to use a more approachable language,
at the cost of being a little less rigorous. For example, I could
get rid of all the projective plane business by just saying "let's
pretend that there is a point *at infinity*; trust me, the Math
works out".

The problem with changing the old slides is that I did not want to touch
[LaTeX](https://nl.wikipedia.org/wiki/LaTeX)
anymore. As a Mathematician I like it because it can do pretty much everything
you need (did you know you can
[draw diagrams programmatically](https://www.youtube.com/watch?v=mWqhB6qOIk0)?),
but as a computer scientist I'd rather not deal with the mess that is a
LaTeX installation.
So what did I decide to use instead? HTML, CSS and a bit of JavaScript!

### Math formulas with MathJax

Even without LaTeX, I still needed a way to write Math formulas in my
slides. One way to achieve this is using [MathJax](https://www.mathjax.org),
which allows you to write LaTeX or
[MathML](https://en.wikipedia.org/wiki/MathML) formulas direclty in
your HTML, and have them rendered dynamically. A minimal example
looks like this:

```
<!doctype html>
<head>
	<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
	</script>
</head>

<body>
	<p>Hello! \[ e^{\pi i} + 1 = 0 \]</p>
</body>
```

In the example above I am including the MathJax library directly from a
URL. This means every time you load that page, a request is sent from
your browser to the MathJax server to get the code for rendering the
formulas. Among other things, this implies that my slides are going
to be dependent on this external website, and that they won't work
offline. The horror!

In theory I could install MathJax locally (or on my server) and get rid
of this dependency, and maybe at some point I'll do it. But for now
it is just easier and faster to include the script like this. And while
I was at it, I doubled down on the remote library thing and included 
also [highlight.js](https://highlightjs.org),
a package for rendering code blocks with syntax highlighting.

### Scrolling with JavaScript

The other big feature I wanted for the slides was for them to look and
behave like actual slides. So the whole HTML page should be divided into
single frames, and I wanted to be able to move back and forth between
frames by clicking or pressing a key.

In order to do this, I had to write my first piece of JavaScript.
The main part looks more or less like this:

```
const slides = document.querySelectorAll(".slide");

const keysNext = ["ArrowRight", "ArrowDown", " "];
const keysPrev = ["ArrowLeft", "ArrowUp"];

// Disable default action of the navigation keys (e.g. scrolling).
document.addEventListener("keydown", function(e) {
	if (keysNext.includes(e.key) || keysPrev.includes(e.key)) {
		e.preventDefault();
	}
});

function goto(slide) {
	slide.focus();
	slide.scrollIntoView({
		behavior: "instant",
		block: "start"
	});
}

function onkeydown(i, e) {
	if (keysNext.includes(e.key) && i+1 < slides.length) {
		goto(slides[i+1]);
	}
	if (keysPrev.includes(e.key) && i > 0) {
		goto(slides[i-1]);
	}
}

function onclick(i, e) {
	const w = slides[i].offsetWidth;
	const x = e.clientX;

	if (x > w/2 && i+1 < slides.length) {
		goto(slides[i+1]);
	}
	if (x < w/2 && i > 0) {
		goto(slides[i-1]);
	}
}

for (let i = 0; i < slides.length; i++) {
	slides[i].addEventListener("keydown", e => onkeydown(i, e));
	slides[i].addEventListener("click", e => onclick(i, e));
}

goto(slides[0]); // Go to the first slide when the presentation starts
```

First of all, every slide is a `div` with `class="slide"`. This allows
me to select all the slides with `document.querySelectorAll(".slide")`.
Then, after disabling any default handling of the arrows and space keys,
I add a new event listeners to every slide. These listeners uses the
`scrollIntoView()` function to scroll to the next or previous slide.
The `onclick()` function similarly handles clicks, where a click on the
left half of the screen goes to the previous slide and a click on the
right half goes to the next one.

And by the way, highjacking the default scrolling behavior is another
trend of modern web development that I hate. By I am fine with using
it here, because these slides are not meant to be a regular web page.

I also a function to add a footer to every slide:

```
function slideFooter() {
	const start = "<div class=\"footer\"><table class=\"footer-table\"><tr>";
	const title = "Elliptic Curves and the ECM algorithm"
	const link = "<a href=https://tronto.net/talks/ecm>tronto.net/talks/ecm</a>";
	const end = "</tr></table></div>";
	const content =
		"<td class=\"footer-title\">" + title + "</td>" +
		"<td class=\"footer-link\">" + link + "</td>";

	return start + content + end;
}

// In the main loop:
// slides[i].innerHTML += slideFooter()
```

In an older version I also had a small slide counter in the footer,
but I decided not to use it in the end.

Of course there was also some CSS work to
do. A new thing I learned in this regard is the
[flex](https://developer.mozilla.org/en-US/docs/Web/CSS/flex)
layout property, with which I was able to easily arrange
pieces of text and pictures in the slides - shoutout to
my friend [Jared](https://guissmo.com) for telling me about
it. Apart from this I don't have anything interesting to comment
about the CSS part of the slides. You can check the full code
[here](https://git.tronto.net/ecm/file/index.html.html) if you want;
everything is in a single HTML file.

The result looks fine, but it does not work perfectly will every screen
resolution. It's fine in 4:3 or 16:9, but with wider screens your
mileage may vary. I could improve it and always use the device height
(or width, but not both) as a reference. But this is quite some work
for very little gain, and in the end all I care about is that I can
show these slides from my laptop. I am sorry if you are viewing this
presentation from a smartphone.

You can view the slides
[on this page](https://sebastiano.tronto.net/talks/ecm).

## Conclusion

I didn't need to do all this work for this presentation, but it was fun to
learn new stuff - not only for the C++ part, that I did not end up using
anyway, but also for the slides. It's good to know a bit of JavaScript,
even if I don't plan to use it much in the future.

I scheduled this post to go online on the same day as my presentation -
wish me good luck :)

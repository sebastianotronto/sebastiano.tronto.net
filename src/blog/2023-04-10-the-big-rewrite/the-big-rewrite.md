# The big rewrite

Recently I have been working on [nissy](https://nissy.tronto.net),
my command-line Rubik's cube solver. But things were not going the
way I wanted. I was trying to implement some minor but rather complex
optimizations. It was a challenging problem and I made some good progress,
but coming back to my code after not looking at it for weeks made it
hard to debug it.

I could work on this project more often. I rarely have long hours or days
in a row to spend on it, but I do have some free time here and there -
I write somewhat regularly in this blog, after all. So why was I not
spending some more time on this project that I like so much?

I think I was trying to do too much. I was trying to write this complex
optimization for the puzzle-solving logic basically to prove to myself
that I am capable of it, but at the same time I wanted to keep the
tool usable for the few people interested in it. As new ideas piled up,
I rushed through my code changes. Code quality degraded, and I was not
improving the tool.

It was time for...
[the big rewrite](https://dylanbeattie.net/songs/big_rewrite.html)!

## What is nissy?

Nissy is a command line Rubik's cube solver and
*[fewest moves](https://www.speedsolving.com/wiki/index.php?title=Fewest_Moves_Challenge)*
solving assistant. You can find it's source code on its
[git page](https://git.tronto.net/nissy).
As a cube solver it is quite fast, faster than the classic
[Cube explorer](http://kociemba.org/download.htm), although it uses
much more RAM. But there is room for improvement.
Additional features related to
[Thistlethwaite's algorithm](https://en.wikipedia.org/wiki/Optimal_solutions_for_Rubik%27s_Cube#Thistlethwaite's_algorithm)
make it useful tool for a certain niche of speedcubers. Although
these features are appreaciated by nissy's users, the CLI interface
and general usability is not as well-received.

I started working on it in 2019, and after a few months of I had something
we could call useful, at least for me. As I added more features and tried
to implement a faster optimal solver, I noticed that I could make some
improvements to its design. So I decided to rewrite nissy from scratch.

"Rewriting from scratch" is a bit of a taboo among programmers.  It is
exciting to start working on a new or "rebooted" project, but it is
usually more time-efficient to just fix the old code.  Nonetheless,
starting over worked for me: at the end of 2021 nissy was much faster,
and more useful for everyone.

Fast-forward another year or so, and I was at the point I described in
the first paragraph. Since stopping to think, redesign and rewrite worked
for this project last time, I decided to do this again.  I did not start
nissy with a clear goal in mind, so it makes sense that I come up with
better goals and design ideas as I go.

## Setting a goal

Nissy has been my pet project for the last 3.5 years or so.  I started
writing because I wanted to see if I could do it, and decided which
features to include along the way.  I have never had a precise goal for
it, so I had to think about what I wanted nissy to be.

Right now, nissy's most important features for its users (including
myself) are:

* Analyzing a "fewest moves" solution, helping the (human) solver spot
  mistakes, oversigths and more advanced tricks that they missed.
* Solving a Rubik's cube optimally, fast.

The first part is basically already implemented, though some improvements
can be made and some simple features can be added.  Most importantly,
the interface should be made more accessible to people not familiar with
the command line - more on this later.

For the second part, the interface is less important, and I can expect the
users to be able to learn how to launch one single command.  It is also
the part that I find most interesting to work on, since the optimization
problem is much more challenging.  On the other hand, the optimal solver
implemented in the current version of nissy is already good enough for
most users.

Once I had written down these two main features, I realized that
I would be much happier working on this project if I just stuck to
those two things. And since *one* program should do *one* thing, I
decided to split the two features into separate projects.  Any other
cool idea I thought of implementing (a speed-solving assitant? a
higher-order cube optimal solver? a generic, hackable puzzle solver like
[ksolve+](https://mzrg.com/rubik/ksolve+)?)  is deferred to future
projects, or probably it will be never done. And that's OK.

## New plan

My plan is to split the work into the following parts:

* Starting from the [stable branch](https://nissy.tronto.net)
  of nissy, remove all the code that is needed only by the optimal
  solver and other unnecessary steps. Work on a GUI and other simple
  features useful for assisting fewest moves solvers.
* Branch off the optimal solver from the current
  [working branch](https://git.tronto.net/nissy/) of nissy. Remove
  all the code that is not needed for the optimal solver and simplify
  the logic, where possible, to address only this use case.
  Finish implementing the solver, basically following Tomas Rokicki's
  [nxopt](https://github.com/rokicki/cube20src/blob/master/nxopt.md),
  or at least parts of it.

For the user interface, I have been thinking about what would be
the best library / framework / technology to use. I would like
this to be as accessible as possible, so I have been considering
[WebAssembly](https://webassembly.org) so that people can just run this
in their browser. But apparently a WebAssembly app needs an http server
to work. I don't want nissy to require an internet connection, and
shipping a whole web server to run locally with it is overkill. I have
also been thinking about [Flutter](https://flutter.dev), it supports all
majow platforms and has the C language as a first-class citizen.  I think
I'll try making some proof of concept app with it and see how it goes.

## A GUI app? Is this an April fools' joke?

Am I a big fan of command line interfaces. I am such a fan of the command
line that I dislike TUIs (such as
[ncurses](https://en.wikipedia.org/wiki/Ncurses)-based programs), because 
they are just GUIs running in a terminal.  So why am I even considering
ruining my favourite personal project by adding a GUI?

One reason is that I don't expect my (very few) users to be familiar with
the command line. But this is not the main reason. I truly believe that,
for this specific use case, a graphical user interface would be better.
And it is not even a matter of showing a graphical representation of
the cube - my users don't need it,
[Singmaster notation](https://www.speedsolving.com/wiki/index.php/Singmaster_notation)
is enough for them.

The point is that this program is supposed to show you a bunch of
information. The user might want to see more details, less details,
group this information in different ways and so on. This information
should be browsable. The user should, ideally, be able to follow a
solution path proposed by nissy by simply selecting the suggested steps.

This could all be done with commands, of course. But it would not be
efficient. The command line is great when you know what information
you want and you ask the computer to generate it or fetch it.
But for interactively browsing information, especially when you do
not know exactly what you are looking for, a GUI is better.

## Ok, so when is it going be ready?

Ah-ah. It will be ready when it's ready, no promises :)

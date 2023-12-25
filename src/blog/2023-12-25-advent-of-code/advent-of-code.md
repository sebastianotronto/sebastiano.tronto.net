# Advent of Code

The [Advent of Code](https://adventofcode.com) is an online programming
contest that takes place every year in December. It works like an
[advent calendar](https://en.wikipedia.org/wiki/Advent_calendar), except
each day instead of a piece of chocolate or a sweet you get a new problem
to solve.

I have taken part in this contest for the first time this year, after
an email from a colleague that mentioned prizes for the winner of our
private leaderboard. Even without any prize, if it is a challenge
then I must accept it!

*Warning: if you are still trying to complete the problems, you may find
minor spoilers ahead, but nothing game-breaking.*

## Choosing my weapons

As I was initially not planning on taking part in the challenge, I did
not have much time to decide which language or tools to use. I opted for
solving the problems in C, because it is the language I worked with the
most recently, but in hindsight it would have been more convenient to
refresh my Python or C++ skills.

In the end using a more limited language did not make a big difference: the
easy problems were still easy, some of the hard ones became a bit slower
to type out. I also had some fun implementing some basic data structures,
for example [heaps](https://en.wikipedia.org/wiki/Heap_(data_structure))
for [day 17](https://adventofcode.com/2023/day/17).

## The fun

Overall, I really enjoyed solving these problems! I liked the diverse
set of techniques that were needed: graph algorithms, dynamic programming,
computational geometry... a very nice selection of brain teasers!

I also liked the fact that the difficulty increased *on average*, but
sometimes a hard problem was be followed by an easier one. This way,
even if I found a problem particularly hard, I could still hope that
the next one would be quicker to solve.

I also liked that other people, including friends, colleagues and my
girlfriend, were taking on the challenge at the same time. I enjoyed
explaining my solution or asking my friends to explain theirs. By the
way, my friend Jared has some in-depth explanation of his solutions
in his [blog](https://guissmo.com/blog/) - check it out!

## The ugly

There were a couple of problems that I disliked, and all of them for
the same reason: the problem was not solvable without taking advantage
of specific properties of the input data that were not made explicit in
the problem's statement.

As a Mathematician, I am never going to randomly assume that a generic
graph has a specific structure, or that just throwing the
[lcm](https://en.wikipedia.org/wiki/Least_common_multiple) into my
algorithm would make it work. So I was scratching my head for hours trying
to solve a general problem that was very likely unsolvable, when I only
had to solve a special case.

However, as a Reddit user pointed out, the input data *is* part of the
problem statement. Analyzing it to figure out what algorithm may work
is a skill. I guess I learnt something from this.

## Solutions

If you are interested, you can find all my solutions on
[my git page](https://git.tronto.net/aoc/) and on
[Github](https://github.com/sebastianotronto/aoc). They are written in
[C99](https://en.wikipedia.org/wiki/C99) without any external dependency
other than the C standard library.

Apart from the harder problems, I have not commented my solutions much,
but you can send me an email if you want some explanation!

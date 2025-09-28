# Cube coordinates

In this page I describe the way I implemented *coordinates*, in the
sense of [Cube Explorer](http://kociemba.org/cube.htm), in one of the
versions of [Nissy](https://nissy.tronto.net).

Unfortunately, this implementation got lost between rewrites and is
currently not included in any working version of Nissy or other projects,
so it this page is of theoretical interest only. Some code is available
in the [nissy-nx repository](https://git.tronto.net/nissy-nx), but it
is currently broken (what is described in this page works, though).

## What are cube coordinates?

A *cube coordinate* is a way of associating to any legal position
of the Rubik's cube an integer in a certain range [0..n-1]. For
example, any way of encoding the permutation of the corners as a
number from 0 to 8!-1 is a valid coordinate; another example is
an encoding of the orientation of the edges with respect to a given
axis as a number in [0..2^11].

In other words, a coordinate is a function from the set of legal
configurations to [0..n-1]. Coordinates need not be surjective,
though it is more convenient if they are, and in my examples they
will be.

To work with cube coordinates, we need to implement the following:

* An integer `n`, the maximum value of a coordinate +1.
* A function `index()` that takes a cube as input and returns an integer
  in the range [0..n-1] as output.
* A function `to_cube()` that takes an integer in [0..n-1] as input and
  returns a cube `c` such that `index(to_cube(x)) == x` for every x in
  [0..n-1]. In other words, `to_cube()` is a *section* of `index()`.
  In practice, it is not necessary that the output of `to_cube()` is a
  valid cube object.
* A function `move()` that takes as input a coordinate, a move m and an
  integer x in [0..n-1] and returns an integer y in [0..n-1] such
  that `y == index(m(to_cube(x)))` (here `m(c)` is the cube c moved by m).
* If applicable, a `transform()` function that applies a transformation
  in a similar way as `move()` applies a move. For coordinates this is
  not possible, because they do not capture enough of the cube state.
  For some coordinates, only some transformations are possible. For
  example, for the edge orientation coordinate only the transformations
  that fix the axis with respect to which the edge orientation is defined
  can be applied.

For the implementation, see
[coord.c](https://git.tronto.net/nissy-nx/file/src/coord.c.html)
and
[coord.h](https://git.tronto.net/nissy-nx/file/src/coord.h.html),
as well as the definition of
[coordinate](https://git.tronto.net/nissy-nx/file/src/cubetypes.h.html#l181)
in cubetypes.h.

## Coordinate types

In my work I have defined four types of coordinates (but I actually use
only three of them).

### Basic coordinates

Basic coordinates are the simplest kind, and they are completely defined
by the integer `n` and the functions `index()` and `to_cube()` defined
above. This is the type of coordinate that "does not exist" in the code,
because they are just a special case of *composite coordinates*.

### Composite coordinates (COMP\_COORD)

Composite coordinates are, like the name says, a composition of many basic
coordinates. They are given by a list of basic coordinates (n\_1, index\_1(),
to\_cube\_1()), ..., (n\_k, index\_k(), to\_cube\_k()). The value of such a
composite coordinate on cube c is computed as
`index_1(c) + n_1 * (index_2(c) + n_2 * (...))`.

### Symmetric coordinates (SYM\_COORD)

A symmetric coordinate consists of a basic coordinate reduced by symmetry.
Symmetric coordinates must be initialized from a given set of *cube
transformations* before they can be used. The initialization step produces
the following data:

* A table that associates every possible value of the basic coordinate
  with its class in the symmetric coordinate. Computing the value of the
  symmetric coordinate will then amount to computing the basic coordinate
  via `index()` and looking up the value in this table.
* A table that associates every possible value of the basic coordinate
  with a fixed representative for its class.
* A table that associates every possible value of the basic coordinate
  the cube transformation that brings it to its representative.
* A table that associates every possible value of the basic coordinate
  with the list of cube transformations that do not affect it, that is
  a list of *self-symmetries*. This will be useful when computing the
  pruning table associated to this coordinate.

### Symmetric-composite coordinates (SYMCOMP\_COORD)

A symmetric-composite coordinate is based on two other coordinates, a
symmetric coordinate and a composite coordinate. To compute the value
of a symmetric-composite coordinate one must compute the symmetric
coordinate value first, then transform the cube using the transformation
that brings the basic coordinate associated to the symmetric coordinate
to its representative in order to compute the correct value for the
composite coordinate, and finally combine the two.

More precisely and with less tong-twisting, for a given cube c one must
take the following steps:

* Compute the value x\_s of the symmetric coordinate at c, the value
  x\_b of the *basic* coordinate associated with the symmetric coordinate
  and the value x\_c of the composite coordinate.
* Read from the table the transformation t that brings x\_b to its
  representative.
* Apply t to the composite coordinate value x\_c to obtain x\_t.
* Compute the value x\_s * n\_c + x\_t, where n\_c is the maximum value +1
  of the composite coordinate.

## Moving coordinates

A move is applied to a coordinate by lookup into a transition table,
pretty much as explained in Jaap's
[computer puzzling page](https://www.jaapsch.net/puzzles/compcube.htm#trans).
These transition tables are initialized once and for all at the beginning,
and in my implementation I actually saved them to a file to speed up
subsequent runs.

Some extra care has to be taken in dealing with symmetries.

### Basic and composite coordinates

This case is quite simple: the transition table with something along these
lines:

```
for i in [0..n-1]
	for m in Moves
		move_table[m][i] = index(m(to_cube(i)))
```

### Symmetric coordinates

As mentioned above, this case and the next are tricky, because we need
to keep track of which transformation has to be applied to get from the
representative of the symmetry class to our actual cube.

You can imagine a move applied to symmetric coordinate as if we just
move between different representatives. The actual cube can be recovered
from this by keeping track of an *offset transformation*, and updating
it after every move.

The necessary tables can be generated with something like this:

```
for i in [0..n-1]
	for m in Moves
		j = m(rep of i) /* Apply as basic coordinate */
		move_table[m][i] = class of j
		offset_table[m][i] = transformation bringing j to its rep
```

### Symmetric-composite coordinates

A symmetric-composite coordinate requires some extra work, but the hard
part is already handled by its base symmetric coordinate.

To move a symmetric-composite coordinate, first we recover the value s
of its symmetric coordinate's and the value c of its composite coordinate
by taking the quotient and the remainder of division by the maximum value
of the composite coordinate.

Then we apply the move to the values s and c using their respective
transition tables. The offset transformation is taken from the symmetric
coordinate, and apply it to the result of the move on the composite coordinate.

This may be summarized with the following pseudo-code:

```
s = ind / M /* M is the maximum value +1 of the composite coordinate */
c = ind % M
new_s = move_table_s[m][s] /* Using the table for the symmetric coordinate */
new_c = move_table_c[m][c] /* Using the table for the composite coordinate */
offset = offset_table[m][s]
new_c = offset(new_c) /* See next section for transformations */

return (new_s * M + new_c, offset)
```

## Transforming coordinates

When we talk about *cube transformations*, we are talking about
conjugating a cube by a rotation, possibly combined with a mirroring
along a fixed axis.  More precisely, transforming a cube c is done with
the following steps:

* Start from a solved cube
* (optional) Mirror it left-right
* Apply the required rotation
* Apply c (as a permutation / move sequence) to the rotated solved cube
* Apply the inverse of the rotation
* (optional) Mirror it left-right

When working with coordinates, transformations are applied pretty much
in the same way as moves, using a transition table. This time, though,
symmetric coordinates are much less of a problem: any transformation
on a symmetric coordinate is, by definition, trivial! Of course, this
is only true if we limit ourselves to applying transformations that are
part of the set used to "reduce" the symmetric coordinate; but we always
do this anyway.

## Pruning tables

I'd like to mention pruning tables here, because their computation is
quite straightforward when using coordinates.

Say you want to compute a table that associates every possible value i in
[0..n-1] of a coordinate with the minimum amount of moves required to
solve any cube c such that `index(c) == i`. For the purpose of this page
we assume one can afford to allocate enough bits so that the actual value
can be stored.

With coordinates, one can do the following, without ever going back to
the full cube representation:

```
set all values of the pruning table to infinity
set the value associated with the solved cube to 0
for d in [1..20]
	for i in [0..n-1]
		if pruning_table[i] == d-1
			for m in Moves
				old = pruning_table[m(i)]
				pruning_table[m(i)] = min(d, old)
```

This is conceptually very simple, but unfortunately it is not enough.
Because of self-symmetries, not every position will be reached in this
way for a symmetric-composite coordinate: there may be more ways to
bring the base of the symmetric coordinate to its representative, each
having a different effect on the composite coordinate, but we only pick
one of them when building the move tables.

Luckily, this can be solved because we have memorized for every position a
list of all the transformations that keep it invariant (see above). Then
it is enough to add the following loop at the end of every iteration of
the outermost loop above:

```
	for i in [0..n-1]
		for t in the set of self-symmetries of i/M
			old = pruning_table[t(i)]
			pruning_table[t(i)] = min(d, old)
```

The code for this can be found in
[pruning.c](https://git.tronto.net/nissy-nx/file/src/pruning.c.html).
The use of pthread made it more complicated, so it can be hard to follow
without reading this page first.

## Why using coordinates?

Coordinates are necessary to compute pruning tables, which are fundamental
when solving a cube using the methods described in Jaap's
[computer puzzling page](https://www.jaapsch.net/puzzles/compcube.htm).

However, using transition tables for moves and transformations is
not necessary.  It used to be an efficient way to perform moves on a
cube, but with newer hardware the trade-offs between memory access and
instruction execution are changing.

One thing that is made particularly cumbersome by using coordinates
instead of a full representation of the cube is computing the
inverse. While it is possible to compute the inverse somewhat efficiently
from a representation of the cube made of a smart selection of coordinate
values, it is not necessarily efficient.
See [fst.c](https://git.tronto.net/nissy-nx/file/src/fst.c.html#l113)
for an implementation.

For these reasons, I am not using the coordinate approach described here
for my new work-in-progress solver (which can be found
[here](https://git.tronto.net/nissy-core)).

# Optimizing solutions: n-slice insertions

## tl;dr

You can insert 3 slices in one of the following ways:

* `E (I) E (I or D) E2`
* `E (I) E2 (I) E`
* `E (D) E2 (D) E`

Where `(I)` denotes a "neutral" sequence like `R2 R2` or `R2 F2 L2`
and `(D)` denotes a "diagonal swap" sequence like `R2 F2 R2`. The list
above is complete up to inverses and mirrors.

## Setting

The problem is this: say you have a DR finish on U/D that contains some
"sliceable" sequences, such as `U D'`, `U2 D`, `U D` or similar. To be
more precise, a sliceable sequence is a sequence of moves that would
cancel out on a 2x3x3 cube.

*(I will not address the problem of having a DR finish minus slice
and inserting E-moves to solve the slice, because it can be reduced
to the "solved slice" case by solving the slice sub-optimally with
any insertion.)*

Sliceable sequences can often be simplified also in a 3x3x3 cube. One
way to do this is to insert E-layer moves at different points of the
solution in such a way that the effect on the E-layer cancels out. It
has been known since the early days of DR (2019) how to insert two moves
that cancel out (`E` and `E'`, or `E2` and `E2`) without affecting the
E-layer edges even without looking at a cube. *(I believe the first person
to come up with a way to do this was Wen, but correct me if I am wrong.)*

I will call insertions of multiple E-layer moves n-slice insertions.
I will start this post with some necessary preliminaries, and then I'll
recall how to find 2-slice insertions without looking at the cube. Then
I will move explain how to do 3-slice insertions in a similar way, and I
will prove that there is no other way to do 3-slice insertions. Finally,
I'll leave here some considerations I have made for more complex cases,
hoping that this will help us develop a general theory to perform any
kind of n-slice insertion quickly and without looking at a cube.

## Preliminaries: floppy and "minidisc" sequences

To insert slices, we have to understand how sequences of DR moves affect
the edges of the E-layer. For this purpose, we can ignore any `U*` or
`D*` move, hence we have to study move sequences in the floppy cube
subgroup <R2, L2, F2, B2>.

There are two kinds of sequences that are particularly important: those
that, up to `y` rotations, do not affect the E-layer (we'll call these
sequences *I-sequences*, where I stands for "Identity") and those that,
up to `y` rotations, perform a single diagonal swaps (*D-sequences*).

Some examples of I-sequences:

* `R2 F2 F2 R2` (all moves "cancel out")
* `R2 F2 L2` (equivalent to y', E-edges stay in the same relative position)
* `R2 F2 R2 L2 B2 L2` (two D-sequences in a row always give an I-sequence)

Some examples of D-sequences:

* `F2 B2`
* `R2 F2 R2`

Considering only the effect of a floppy sequence on the E-layer
edges up to y rotations, there are only 6 possible types of sequences.
They are equivalent to the possible permutations of a 2x2x1 cube
(or "minidisc" cube, name that I have just made up) that keep one
corner (say BL) fixed:

* `(no moves)` I-sequences
* `R2`
* `R2 F2`
* `R2 F2 R2` D-sequences
* `F2 R2`
* `F2`

This fact will come into play later on.

## 2-slice insertions

As I said at the beginning, it has been known for a while how to
do 2-slice insertions (`E E'` or `E2 E2`) without affecting the E-layer
edges. The trick is the following:

* For `E E'` insertions, insert either `E` or `E'` wherever you want
  (usually in a "sliceable" place, i.e. right before/after a `U* D*`
  pair of moves) and insert the other slice (either `E'` or `E`) in a
  spot such that the moves between the two insertions form an I-sequence.
* For `E2 E2` insertions, insert the first `E2` wherever you want, and
  the second `E2` in a spot such that the moves between the two
  insertions form either an I-sequence or a D-sequence.

There is no other way of inserting two slices so that they cancel out.

### Examples

For our first example, say you have a DR finish like this:

```
Setup: R2 D R2 D' U' R2 U R2 U' B2 L2

Solution:
L2 B2 U //Blocks + OBL
R2 U' R2 U D R2 D' R2 //J+J perm
```

Ideally, you would like to "slice away" the `U D` in the second step.
You can insert there either an `E` or an `E'`, in either case one you save
one move. Where can you insert the second slice move? We can see that the
three moves before `U D` are an I-sequence, and placing an `E'` before
them would cancel out the `U` ending the first step.  Here only an `E'`
can be inserted, so we'll have to use `E` in the other spot.  So we have:

```
L2 B2 U [2]
R2 U' R2 U D [1] R2 D' R2
[1] = E
[2] = E'
```

Giving a final solution: `L2 B2 D B2 U' B2 U2 R2 D' R2`.
One move saved!

*(I like to number my insertions in the order I found them, hence the
[2] before the [1] in this case.)*

For our second example, take the double edge swap `(UF DF) (UL DR)`:

```
R2 F2 R2 U2 F2 R2 F2 U2
```

You can turn the two `U2` moves into `Uw2` and you get an equivalent alg.
This is equivalent to the following two-slice insertion:

```
R2 F2 R2 U2 [1] F2 R2 F2 [2] U2
[1] = [2] = E2
```

Notice that the two slices are separated by a D-sequence.

Less intuitively, you can also change some of the other moves to
their wide counterpart:

```
R2 [1] F2 R2 U2 F2 [2] R2 F2 U2
[1] = [2] = M2
```

or

```
R2 F2 [1] R2 U2 F2 R2 [2] F2 U2
[1] = [2] = S2
```

This trick is useful for maximizing cancellations with edge insertions,
without memorizing many variations of the same alg.

## Bonus: 2 slice to solve a 4x case

This bit is out of scope for this page, but it is still interesting
to note. If, instead of shortening a "solved slice", you are trying to
solve a 4x case (that is, edges are solved but the 4 E-layer centers are
swapped), you can still use 2-slice insertions fairly easily.  In fact,
inserting `E E` or `E' E'` so that they are separated by a D-sequence is
going solves this case. Keep in mind that this will *not* work if the two
`E` moves in the same direction are separated by an I-sequence!

## 3-slice insertions

Up to inverses and mirrors, there are only two possible types of 3-slice
insertions: `E E E2` and `E E2 E`. Both consist of two `E` moves (or two
`E'` moves) and one `E2` move.

To understand how to find spots to insert them, we are going to think
about them as if we are inserting two `E` moves in the same direction,
and then fixing the slice by inserting an `E2`. This works for both
types of 3-slice insertions.

The first question we want to ask is then: where can we insert two
`E` moves so that the result can be fixed by a single `E2` insertion?
An `E2` insertion necessarily performs a double swap of edges, so our
two `E` insertion must leave such a case. (We are ignoring centers,
because we already now they will be solved at the end of our process if
we insert two `E` moves in the same direction and one `E2` move.)

The answer is: the moves between the two `E` moves must form an
I-sequence. Indeed, since an I-sequence does not affect the relative
position of E-layer edges, two `E` moves separated by an I-sequence
have the same effect as an `E2` move, that is a double edge swap (up to
`y` rotations).

This already tells us something useful: in those cases where we
would like to insert two slices `E E'`, but we find an admissible
spot for the second slice that would cancel more if we inserted the
inverse move, we can the inverse move and hope to find a suitable
spot to "correct" the insertions with an `E2`. We'll see in a minute
where we can insert the `E2`, now let's prove that this is the only
way to perform 3-slice insertions.

We can check that this is the only admissible way to insert the two
`E` moves by going through all other "minidisc sequences" listed in
the previous section, and checking that E (minidisc sequence) `E`
does not yield, up to a `y` rotation, a double edge swap.

Up to a `y` rotation:

* `E R2 E` is a single edge swap (`y2 F2` solves the slice)
* `E R2 F2 E` is a 3-cycle (`y2 [E, F2]` solves the slice)
* `E R2 F2 R2 E` is a single edge swap (`y2 [R2: B2]` solves the slice)
* `E F2 R2 E` is a 3-cycle (`y2 [E', L2]` solves the slice)
* `E F2 E` is a single edge swap (`y2 L2` solves the slice)

So, where can we insert the final `E2`? This is easy: the moves between
the `E2` and any of the two `E` moves must be either an I-sequence
or a D-sequence. This can be proved with the same reasoning we used a
few paragraphs above when we said that two `E` moves separated by an
I-sequence have the same effect as an `E2`, combined with the knowledge
on 2-slice insertions of type `E2 E2`.

This gives us 4 possible "patterns" for 3-slice insertions, up to
inverses and mirrors:

* `E (I) E (I) E2`
* `E (I) E (D) E2`
* `E (I) E2 (I) E`
* `E (D) E2 (D) E`

Where (I) and (D) denote I- and D-sequences, respectively.

### Examples

Let's take this example:

```
Setup: L2 F2 L2 D' L2 D R2 D B2 U'
Solution:
U B2 U' B2 D' F2 U //HTR
U D' B2 L2 B2 U' D // Finish, one move cancel
```

*(The second step could be replace by `U' D F2 R2 F2 U D'` for one less
move, and then you could use a 2-slice insertion, but please let me use
this artificial example for now.)*

The DR finish is then: `U B2 U' B2 D' F2 U2 D' B2 L2 B2 U' D`

We would like to slice away the `U2 D'` and the `U' D` at the end, but
they are separated by a D-sequence, and an `E2 E2` insertion would not
work here.  But fear not, for we can use 3-slice insertions:

```
U B2 U' [3] B2 D' F2 U2 D' [2] B2 L2 B2 [1] U' D
[1] = E
[2] = E2
[3] = E
```

In this case rather than inserting the two `E` moves first and then adjust
with an `E2` it makes more sense to insert and `E` and an `E2` and then fix
with another `E`, for maximum cancellation. This is reflected in the order
I wrote the insertions.

I would like to add more examples here, but I have yet to use 3-slice
insertions in an actual FMC attempt.

## General n-slice insertions

I have not been able to devise a general method for n-slice insertions,
but I have some ideas on how to work in this direction.  This section
contains only speculations, if you are only interested in learning
new techniques that you can apply to your solves you do not have
to read it.

First of all, it could be worth considering only what we can call
*fundamental* slice sequences, i.e. those having no contiguous
sub-sequence that keeps centers solved. For example `E E E2` is
fundamental, but `E2 E' E E2` is not (the `E' E` subsequence keeps
centers solved) and neither is `E E' E E2 E` (both the `E E'` at the
beginning and the `E' E` starting on move 2, as well as the ending
`E E2 E`, are sub-sequences that do not affect centers).

The idea behind this is that we can perform a non-fundamental
slice insertion in two or more passes, by inserting the shorter
subsequences first. Unfortunately, this is not as simple: for example,
the non-fundamental sequence `E E' E E'` could be such that the first
`E E'` pair leaves a 3-cycle that is subsequently fixed by the other
`E E'` pair. Nevertheless, decomposing a sequence into fundamental
subsequences can have its use.

Classifying all fundamental sequences is actually very easy: up to
inverses and mirrors, this is the full list:

* `E E'`
* `E2 E2`
* `E E2 E`
* `E E E2`
* `E E E E`
* `E2 E E2 E'`

The fact that there are no fundamental sequences longer than 4 moves
is a consequence of the following theorem (warning: Math ahead,
caution advised):

**Theorem**. Let n and k be positive integers. If a sequence of k
elements of Z/nZ has sum 0 and it has no non-trivial (contiguous)
subsequence with sum 0, then k <= n.

*Clarification: non-trivial means that it contains at least one element
and it is not the whole sequence.*

**Proof** (thanks to Chiara for the nice proof). It is enough to
prove that any sequence of n+1 elements of Z/nZ has a subsequence whose
sum is 0. To prove this, let, for l=1 to n+1, s\_l = a\_1 + ... + a\_l.
If s\_i=0 for any i, we are done. Otherwise by the pigeonhole principle
there must be s\_i and s\_j with s\_i = s\_j and, say, i < j. But then
the subsequence a\_(i+1), ..., a\_j has sum s\_j - s\_i = 0. This proves
the claim.

More work needs to be done here.

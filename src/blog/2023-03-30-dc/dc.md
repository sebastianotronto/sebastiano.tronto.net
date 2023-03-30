# The man page reading club: dc(1)

For this episode I have decided to go back to the basics, in multiple
ways. Indeed `dc`, the *desk calculator*, is:

* A calculator, the most basic functionality for a computer to be called
  so - "computer" *literaly* means "calculator".
* A [stack-machine](https://en.wikipedia.org/wiki/Stack_machine), one of
  the most basic
  [Turing-complete](https://en.wikipedia.org/wiki/Turing-complete) 
  computational models.
* One of the oldest UNIX utilities, predating even the C language - in fact,
  it was originally written in
  [B](https://en.wikipedia.org/wiki/B_programming_language).

But is it also a practical tool to use? Let's find out!

## dc(1)

*Follow along at [man.openbsd.org](http://man.openbsd.org/OpenBSD-7.2/dc)*

There are a few features marked as non-portable in the manual page, most
of them relevant to OpenBSD's [bc](http://man.openbsd.org/OpenBSD-7.2/bc)
implementation. To make the post a bit shorter, I have decided to skip
all of them.

The first few lines of the manual page explain that `dc` uses
[reverse Polish notation](https://en.wikipedia.org/wiki/Reverse_polish_notation):
numbers can be pushed onto a stack, and operations are performed on the top
(or top two) numbers on the stack, their result being pushed back onto the
stack to replace the operands.

`dc` allows to set an arbitrary precision (here called *scale*), as well
as different bases for input and output - for example, you may want to
input your numbers in binary and read the output in hexadecimal. The
output base can be any number greater than 1, but the input base must
be between 2 and 16.

The most basic operation you can perform is simply pushing a number
onto the stack. Letters A to F can be used to input numbers in bases
higher than 10, and negative numbers are written with an underscore `_`
instead of dash `-`.

The commands are listed in alphabetic order in the manual page, but I will
instead separate them in more logical sections.

### Basic operations

The most basic operations are `+` (sum), `-` (subtraction), `*`
(multiplication), `/` (division), `%` (remainder or modulus) and
`^` (exponentiation). There is also `v` (square root).

For example the command `4 7-` results in `-3`.  You can input it
like that, all on one line and without any whitespace between the
`7` and the `-`. But if you do, you won't get any output.  Why?

### Stack manipulation

Operations remove one or more numbers from the stack and push back the
result. So the answer to the previous question is: the result was pushed
onto the stack, but no instruction was given to print it.

This can be done with the command `p`, which prints the top number in
the stack. The command `f` prints the whole stack.  Both of them leave
the stack unchanged. So for example:

```
$ echo '4 7-p' | dc
-3
```

*(Notice how we redirected the output of `echo` to be read by `dc` -
I'll never get tired of
[this](https://en.wikipedia.org/wiki/Pipeline_(Unix)))*

Commands that manipulate the stack are `c` to clear the whole stack
and `d` to duplicate the top element. The command `z` pushes onto the
stack the number of elements currently on the stack.

### Scale and bases

As mentioned at the beginning, some global parameters can be set:
input base, output base and scale. This can be done with the commands
`i`, `o`, and `k`, respectively: each of them pops the top element
of the stack and uses it as value to set the respective global parameter.

The capitalized version of these commands, `I`, `O` and `K`, read
the value of the input base, the output base or scale respectively
and push it onto the stack

Each number on the stack has its own scale, too. This value is derived
from the global scale and the scales of the operands used to compute it.
More precisely:

```
For addition and subtraction, the scale of the result is the maximum
of scales of the operands.  For division the scale of the result
is defined by the scale set by the k operation.  For multiplication,
the scale is defined by the expression min(a+b,max(a,b,scale)),
where a and b are the scales of the operands, and scale is the scale
defined by the k operation.  For exponentiation with a non-negative
exponent, the scale of the result is min(a*b,max(scale,a)), where
a is the scale of the base, and b is the value of the exponent.  If
the exponent is negative, the scale of the result is the scale
defined by the k operation.
```

The command `X` can be used to replace the top number with its
scale. Similarly, the command `Z` replaces the top number with its
length, i.e. its number of digits (not counting eventual decimal point
or negative sign).

### Registers and arrays

So far we have seen that `dc` can do everything that a rather basic
RPN calculator can do. Things are going to get
much more interesting in the next two sections.

`dc` allows the use of 256 *registers* to store data. Each register
is labelled by a single byte - in practice, an ASCII character.
This character can be anything, even a whitespace or a non-printable
character, so make sure not to put unneeded whitespace before a
register name.

The actual structure of registers was not very clear to me from the
manual page. I had to read the relevant section and command
descriptions a few times, and in the end I resorted to the ultimate
technique: try it out.  (I skipped the "read the source code" step,
please forgive my impurity.)

It turns out that each register is a stack, each level of which
contains both a single number and an unbounded array of numbers.
The single number and the array can be manipulated separately. All
the values default to 0 if unset.

The command `sr` can be used to pop the top element of stack and
save it as the "single" value of register `r`. You can replace `r`
by any other ASCII character to manipulate other registers. To load
the "single" value from register `r` onto the main stack, you can
use `lr`; this command does not alter the state of the register.

To manipulate a register's array, you can use `;r` and `:r`:

```
:r   Pop two values from the stack.  The second value on the stack is
     stored into the array r indexed by the top of stack.

;r   Pop a value from the stack.  The value is used as an index into
     register r.  The value in this register is pushed onto the stack.
```

So for example `42 3:r` stores the number 42 in the third position of
the array of register `r`, and `3;r` retrieves this value.

So far so good. But I said that each register is actually a stack. What
did I mean by that?

The commands `Sr` and `Lr` (capital S and L) can be used for this: `Sr`
creates a new stack level on register `r`, pops the top value of the
main stack, and saves that value as the "single" value. In doing so,
a new level of the register's array is also created. Conversely, `Lr`
pops a level of register `r` and pushes its single value onto the main
stack, deleting the whole array saved on the level that was popped.

Let's work out an example to help us understand this. First, we push
some numbers on register `a`:

```
1sa
100 0:a 101 1:a 102 2:a
```

Now register `a` looks something like this:

```
Level 1 --- single value: 1 --- array: 100 101 102   0   0 ...
```

You can confirm this by running the commands `la 0;a 1;a 2;a f`,
which should output the numbers 102, 101, 100 and 1, one per line.

Now let's push another level onto the register with `2Sa`. The
register now looks something like this:

```
Level 2 --- single value: 2 --- array:   0   0   0   0   0 ...
Level 1 --- single value: 1 --- array: 100 101 102   0   0 ...
```

Running the same command as before (`la 0;a 1;a 2;a f`) should
now yield  0, 0, 0, 2.

Lastly, let's pop the top level of this register with `La`. Now
it should look like this again:

```
Level 1 --- single value: 1 --- array: 100 101 102   0   0 ...
```

And you can check this with the usual command. If you do, you'll
notice that the number `2` has also been pushed on the main stack
by the `La` command.

Phew, this was a long one! And we have not reached the most
interesting part yet...

### Strings and macros

In `dc` you can work not only with numbers, but also with strings.
You can input a string by enclosing it in square brackets, like
this: `[Hello, World!]`. Square brackets can appear in a string
if they are either balanced or escaped by a backslash.

Strings can be pushed onto the main stack or saved in any register
like numbers. But what can you do with them? One thing you can do
is print them with the `P` command:

```
[Hello, World!
]P
Hello, World!
```

As you can see, it is very easy to include a newline in a string.

But much more interesting is the fact that you can *execute* strings
with the `x` command. This allows you to create macros. For example,
say you want to evaluate the function `p(x)=x^2+2x-1`. Since we are
working in RPN, it is probably easier to rewrite `p(x)` as
`x(x+2)-1`. If your number `x` is on the stack, you can compute `p(x)`
with the commands `d2+*1-`. But what if you want to do this
multiple times? Here macros can help:

```
[d2+*1-]sp
```

Now we have saved the macro "evaluate p(x)" on the register `p`. We
can execute it any time we want by loading it with `lp` and then
executing it with `x`:

```
3 lpx
_2 lpx
1 lpx
f
```

Should give 2, -1, 14.

### Conditionals

Lastly, we can control the flow of macro execution using conditionals:

```
<x >x =x !<x !>x !=x
    The top two elements of the stack are popped and compared.
    Register x is executed if they obey the stated relation.
```

Let's see a simple example: computing the average of all numbers
on the stack.

First we need to save the number of elements somewhere, say in the
register `n`. We can do this with `zsn`. Then we need to sum the
whole stack. We can do this by calling `+` until the stack is only
one element left...  this sounds like a loop, but we can use recursion
instead:

```
[+z1<a]sa
```

This saves the the macro `[+z1<a]` in register `a`, achieving recursion:
the macro starts by summing the top two numbers, then pushes the number
of elements left onto the stack with `z`, followed by one. It then pops
these two numbers and calls itself if the top one is less then the second.

Putting this all together, we can compute the average of a bunch of
numbers, say to two decimal digits, like this:

```
10 12 11 9 8 10 11 10 10
2k
[+z1<a]sa
zsnlaxln/p
```

Not the most legible code, but quite short!

## Conclusion

In the end I managed to write a rather lengthy post about something as
simple as a desk calculator. And I have even skipped some things, like
recursion levels and the `?` command!

Initially I wanted to write about
[bc(1)](http://man.openbsd.org/OpenBSD-7.2/bc), the other standard UNIX
calculator. It works with the more familiar infix notation and has
for loops, if / else statements and functions. I even wrote a
[small library of mathematical functions](https://git.tronto.net/bclibrary)
to show off! But in the end I thought it would be boring, so I decided
to learn and write about `dc` instead. In practice I am likely going to
use bc and my hand-written math library for most purposes - except
maybe computing averages, that was one example where the terseness of
`dc` can come in handy.

Fun fact (from the bc manual page):

```
bc is actually a preprocessor for dc(1), which it invokes automatically,
unless the -c (compile only) option is present.  In this case the
generated dc(1) instructions are sent to the standard output, instead
of being interpreted by a running dc(1) process.
```

I think it would be a fun excercise to try and re-implement `dc`, and
then bc as a compiler to `dc` code. I could learn a few things about
compilers with this project! But for now I'll have to put it in the
ever-growing list of "one day, maybe" ideas.

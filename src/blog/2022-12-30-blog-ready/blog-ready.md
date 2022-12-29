# Getting my blog ready for 2023

My first year of blogging is about to end, and I am happy with what
I wrote.  I wanted to write at least one post every month, and I did. I
intend to keep this pace next year, but I want to make this easier by
writing shorter posts from time to time. This is not a trivial task:
I found out that writing good *short* content is harder than writing
good *long* content!

But if I keep writing, [my blogs's index page](../) is going to become
messy at some point! It would be nice to divide these posts by year...

## Adding year sections to my blog index

Very easy: in my
[build.sh](https://git.tronto.net/sebastiano.tronto.net/file/build.sh.html)
script that I run to
[build my website](../2022-08-14-website), there is a
[`makeblog()`](https://git.tronto.net/sebastiano.tronto.net/file/build.sh.html#l52)
function that takes care of building the index page and RSS feed for my blog.

It is enough to add the following lines inside its main loop:

```
thisyear=$(echo $d | sed 's/-.*//')
if [ "$thisyear" != "$lastyear" ]; then
	printf "\n## $thisyear\n\n" >> $bf
	lastyear=$thisyear
fi
```

And that's it! These few lines introduce two new variables, `thisyear`
and `lastyear`, that keep track of the years of the last and next blog
post that the loop is scanning. If there was a year change, a new line
with the current year is added, and the `lastyear` variable is updated.
The first line refers to a variable `d` that holds the date of the
current post in `yyyy-mm-dd` format.

A last note on the variables: if you are familiar with other programming
languages, you might wonder where the variable `lastyear` is initialized.
After all, I am using it in the `if` statement's condition, so it must
be initialized outside of its body, right?

Actually, no. The shell's variable scoping does not work like in C or
similar languages, and a variable initialized inside a block is also
visibile outside of it. Moreover, un-initialized variables evaluate to
the empty string, so the first time the condition is checked it correctly
determines that the current year is different from the last.

This was my last UNIX shell tip for this year. Stay tuned for more!

![My netbook and planner for 2023](pc-planner.jpg)

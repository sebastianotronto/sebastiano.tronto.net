# Resizing my website's pictures with ImageMagick and find(1)

I have noticed that most of the pictures I have uploaded on this website
are incredibly large:

```
$ du -h -d 1 sebastiano.tronto.net
42M     sebastiano.tronto.net/gemini
42M     sebastiano.tronto.net/http
42M     sebastiano.tronto.net/src
100M    sebastiano.tronto.net/.git
225M    sebastiano.tronto.net
```

Stupid modern phones and their multi-megapixel cameras!  I definitely
do not want my minimalist blog to waste your bandwidth, I have to fix
this. I could just go through all my pictures and resize them one by
one with something like [gimp](https://www.gimp.org/) - there are like
10 of them.  But that's boring. Let's do it with the command line instead!

## ImageMagick

The obvious question is: how do we even edit a picture
with the command line? Luckily, there is a tool for that:
[ImageMagick](https://imagemagick.org/). This piece of software can do a
ton of things, and I do not use it very often, so I always need to look
up what I want to do.

One way to invoke ImageMagick is by
calling the `convert` command, which can take a
[`-resize`](https://imagemagick.org/script/command-line-options.php#resize)
option, followed by a
[`geometry`](https://imagemagick.org/script/command-line-processing.php#geometry)
argument. After checking the online manual, I understood that the command
I was looking for was:

```
$ convert picture.jpg -resize "750>" picture.jpg
```

which resizes `picture.jpg` by scaling it down to at most 750px width -
preserving the ratio between width and height, and leaving the picture
untouched if it is already smaller. The value 750 was chosen after a
couple of attempts, it seems a good compromise between quality and size.

And now I just have to do this for all pictures. Of course, running the
same command 10 times with a different argument is out of question.

## find(1)

*(No "man page reading club" this time, but don't
worry, the series will be back soon.)*

A standard UNIX command, [`find`](https://man.openbsd.org/find) allows
you to scan a folder for files with certain properties (for example,
a certain name pattern) and perform actions on them (for example,
running a command). The OpenBSD and GNU versions of find have some
differences, check your local manual page. The commands I use
here have been tested on the GNU version, but should be standard.

To look for files and simply print their name, we can use `-name`:

```
$ find src -name \*.jpg -or -name \*.png
src/me.png
src/favicon.png
src/speedcubing/cubing.png
src/blog/2023-01-28-windows-desktop/settings.png
src/blog/2023-01-28-windows-desktop/tiling.png
src/blog/2022-09-10-netbooks/darkstar.jpg
src/blog/2022-09-10-netbooks/final.jpg
src/blog/2022-09-10-netbooks/scramble.jpg
src/blog/2022-09-10-netbooks/hd.jpg
src/blog/2023-02-25-job-control/jobs-diagram.png
src/blog/2022-12-30-blog-ready/pc-planner.jpg
```

Notice how I had to escape the `*`: the strings `\*.jpg` and `\*.png`
are part of the find command, we don't want the shell to expand them.

Now we can use `-exec` to run a command on each of these files,
using `{}` to refer to the file's name:

```
$ find src \( -name \*.jpg -or -name \*.png \) -exec convert {} -resize "750>" {} \;
```

We get a couple of warnings about grayscale images, but whatever.
This seems to have worked.

## The weight of history

Let's see if things have improved:

```
$ du -h -d 1 sebastiano.tronto.net
19M     sebastiano.tronto.net/gemini
19M     sebastiano.tronto.net/http
19M     sebastiano.tronto.net/src
102M    sebastiano.tronto.net/.git
158M    sebastiano.tronto.net
```

That's... a bit disappointing. It looks like large pictures were not
the only culprit - all the [slides for my math talks](../../research)
are also quite heavy. Too bad, I am not going to change them now.
Maybe in a follow-up post :-)

Just like me with my old slides, git also wants to keep a memory
of the past. After all, this is what version control system are
supposed to do. If you are wondering why my website is a git
repository, check out
[this old blog post of mine](../2022-08-14-website). In the end,
I don't really need the ability to revert my website to an older
version, so I could just reset the repo from all the history
at some point.

## Conclusion

ImageMagick is and find are both powerful tools. I am happy with looking
up ImageMagick's syntax everytime, but I definitely want to become more
proficient with find.

This was not a hard task, but I have learned something new. I hope you
did too :-)

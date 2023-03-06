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

Stupid modern phones and their multi-megapixel cameras!
I definitely do not want my minimalist blog to waste your bandwidth,
I have to fix this. I could just go through all my pictures and resize
them with something like [gimp](https://www.gimp.org/) - there are like
10 of them.  But that's boring. Let's do it with the command line instead.

## ImageMagick

The obvious question is: how do we even edit an image file
with the command line? Luckily, there is a tool for that:
[ImageMagick](https://imagemagick.org/). This piece of software
does a ton of things, and I do not use it very often. So I always
need to look up what I want to do.

One way to invoke ImageMagick is by calling the `convert` command,
which can take a
[`-resize`](https://imagemagick.org/script/command-line-options.php#resize)
option, followed by a
[`geometry`](https://imagemagick.org/script/command-line-processing.php#geometry)
argument. After checking the online manual, I understood that the
command I was looking for was:

```
$ convert picture.jpg -resize "750>" picture.jpg
```

which resizes `picture.jpg` by scaling it down to at most 750px width -
keeping the ratio between width and height, and leaving it untouched if it
is already smaller. The value 750 was chosen after a couple of attempts,
it seems a good compromise between quality and size.

And now I just have to do this for all the pictures. Of course, running
the same command 10 times with a different argument is out of question.

## find(1)

*(No "man page reading club" this time, but don't
worry, the series will be back soon.)*

A standard UNIX command, [`find`](https://man.openbsd.org/find) allows
you to scan a folder for files with certain properties (for example,
a certain name pattern) and perform actions on them (for example,
running a command). The OpenBSD and GNU versions of find have some
differences, check your local manual page. The commands I use
here have been tested on the GNU version, but should be standard.

To look for file and simply print their name, we can use `-name`:

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

Now we can use `-exec` to run a command on each of these files,
using `{}` to refer to the file's name:

```
find src \( -name \*.jpg -or -name \*.png \) -exec convert {} -resize "750>" {} \;
```

We get a couple of warnings about grayscale images, but whatever.
This seems to have worked.

# Dotfiles backup and bootstrap

It took me more than 18 years of using Linux, but I have finally bought
a used [Thinkpad](https://en.wikipedia.org/wiki/ThinkPad), thus becoming
a *real* Linux user. To be specific, I got a Thinkpad L13 from ~2020 with
an Intel i5 CPU and 8Gb of RAM.

After I bought the laptop, it was time to set it up to my likings. I usually
do this by installing a Linux distro and then manually copying my
configuration files (a.k.a. *dotfiles*) from some messy backup folder. Since
I do this quite rarely, and since when I do I also tend to pick a different distro
just to try it out, I have never bothered automating this process...

...But not anymore! This time I decided to set things up properly.

## OS choice: Alpine Linux

For the operating system, I chose [Alpine Linux](https://alpinelinux.org/).
It is an extremely simple Linux distribution that relies on minimalistic
core tools - for example, it uses [busybox](https://busybox.net/) instead of
[GNU coreutils](https://www.gnu.org/software/coreutils/) and
[OpenRC](https://en.wikipedia.org/wiki/OpenRC) instead of
[SystemD](https://en.wikipedia.org/wiki/SystemD). Its package manager is incredibly
fast (and it can be used [declaratively](../2025-08-16-alpine-declarative)) and
it's [wiki](https://wiki.alpinelinux.org/wiki/Main_Page) is well-maintained.
I am liking it a lot, but your mileage may vary - especially because it uses
[musl](https://musl.libc.org/) as the system C library, breaking compatibility
with some pre-built applications and, notably, with video streaming platforms
that rely on [DRM](https://en.wikipedia.org/wiki/Digital_rights_management).

Other options I considered were [Void Linux](https://voidlinux.org),
that I have happily used since 2020, [OpenBSD](https://www.openbsd.org),
that I am using on my server and on my old [netbook](../2022-09-10-netbooks),
[Debian](https://www.debian.org), that I am using on my [gaming
desktop](../2023-10-15-build-time) and [Slackware](http://www.slackware.com),
the old time favorite that I used back in 2009-2013. I am not going to explain
the reasons why I settled on Alpine in the end; it is mostly a matter of
personal preference anyway.

## Configuration files as a git repository

As for my configuration files, they are now managed via a [git
repository](https://git.tronto.net/config), as explained in [this blog post
by Drew De Vault](https://drewdevault.com/blog/dotfiles). In short:

* My home directory is a git repository.
* All files are ignored by default (my `.gitignore` contains a single line: `*`).
* Configuration files that I wish to track are manually added with
  `git add -f my_file`.

This way, the path of each file is preserved in the structure of the
repository, and cloning it into a new system's `$HOME` makes everything
fall into place.

There is a small caveat with this setup: every file and directory that is
directly or indirectly contained in my home, even if `gitignore`'d, is now
part of this git repository. This includes other git repositories, and this
could break certain development tools - for example, I had issues with
[ty](https://docs.astral.sh/ty) ignoring all files due to them being
`gitignore`'d by my configuration file repository.

While I was at it, I have also moved my [scripts](https://git.tronto.net/scripts)
into this repository, since they are part of my desktop setup anyway.

## Bootstrapping

Copying configuration files into the right place is not the only thing
I need to do when I set up a new laptop. I also need to install packages,
build some software from source (for example, [dwm](https://dwm.suckless.org)),
edit some configuration files that are outside of `$HOME` (for example,
in `/etc`), and so on.

I tried to automate these steps as much as I could turned them into [a
script](https://git.tronto.net/config/file/scripts/setup-config-alpine.html). I
won't explain everything it does here, you can just read through it if you want -
it is pretty self-explanatory. This script also takes care of cloning the dotfiles
repository I mentioned above, so when I set up a new system I just need to download
a copy of this script from my server and run it.

The script ends by printing some instruction on the remaining manual steps,
such as uploading my SSH keys into some machines that I regularly
access remotely and copying copying some secrets into `.ssh`.

## Conclusion

This setup may be a bit overengineered, but it gives me a consistent way to
quickly set up a new computer, and it also serves as documentation on my local
configuration.

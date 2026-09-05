# From stagit to cgit

When I first set up this website back in 2022, I also started self-hosting
my git repositories. To make them accessible via web I used
[stagit](https://codemadness.org/stagit.html), and I wrote about this
in [an old blog post](..//2022-11-23-git-host/). In short, I used a custom
post-receive [git
hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) that used
stagit to generate the HTML pages for [my git
website](https://stagit.tronto.net).

This script ran every time I pushed some changes to a repository.
After calling stagit, the script would also modify the generated
pages to add a custom Download button at the top, which was not
efficient. For my largest repositories, this took around
a couple of minutes for every `git push`. Moreover, having all the file
contents both in the git folder and in the HTML pages wasted some
space on my small VM.

So I looked for alternatives, and I found
[cgit](https://git.zx2c4.com/cgit/about/), which works quite differently
from stagit. I gave it a try, and I am quite happy with the result! If
you want to check it out, go to [git.tronto.net](https://git.tronto.net).
A frozen version of the old stagit-generated pages is still available at
[stagit.tronto.net](https://stagit.tronto.net).

## Static pages versus CGI

Instead of generating pages to be served by a
[web server](https://en.wikipedia.org/wiki/Web_server), cgit is
based on [CGI](https://en.wikipedia.org/wiki/Common_Gateway_Interface).
To put it simply, cgit is a program that continuously runs on a server,
generating on the fly each page a visitor requests.

There is an obvious trade-off between disk space and CPU usage here:
on the one hand we don't need to store all the HTML pages that are
essentially a duplicate of what can already be found in the git
repository's folder; on the other hand, computing the page on the
go takes some work for the server's CPU. However, cgit can also
cache the most recently viewed pages, so it does not have to re-compute
the most requested ones all that often.

Of course, another cost is the more complex setup, as we are now dealing with
a full-blown web application instead of plain and simple static HTML files.
We'll get into some of the problems that this causes in the next section.

## OpenBSD and cgit

As you may know, the [VM](https://en.wikipedia.org/wiki/Virtual_machine)
that  hosts this website has historically been running on
[OpenBSD](https://openbsd.org) (spoiler: this is no longer the case).
When it comes to hosting cgit, or any CGI application, this comes with
some pros and some cons.

First off, the pros: OpenBSD's base system already has a web server
([httpd](https://man.openbsd.org/httpd.8)) and a FastCGI server
([slowcgi](https://man.openbsd.org/slowcgi.8)) that are capable of
running cgit. So no external program is strictly needed other than
cgit itself - see [this short
tutorial](https://codemadness.org/openbsd-httpd-and-cgit.html) for
details.

But there are some points of friction that arise from one of httpd's
most-loved security features: the fact that it works in a
[chroot](https://en.wikipedia.org/wiki/Chroot) environment, by default
rooted at `/var/www`. This means that httpd cannot see any file outside
of `/var/www`. So any file that cgit needs, including all the git
repositories that one wants to show, must be inside `/var/www`.

And while it is not much effort to put them there, I have been
managing my repositories via a dedicated `git` user, keeping them in
`/home/git`. So I would have to either change this user's home directory
to something in `/var/www`, or change the relative path of each repository.
Either way, it wouldn't be as nice as my current setup.

But the repositories are not all cgit may want to know about. For example,
one can *filter* README files through a Markdown parser, such as
[lowdown](https://kristaps.bsd.lv/lowdown/), to display more nicely on the
web - see [this README](https://git.tronto.net/nissy-core/about/) for an
example. The parser, too, must live within httpd's chroot. Same for any
[dynamic library](https://en.wikipedia.org/wiki/Dynamic_library) it
depends on. To make this work, I ended up creating `usr/bin` and `usr/lib`
folders inside `/var/www` and manually copied some executables and libraries
there - not the cleanest solution.

Alternatively, one may configure httpd to chroot at `/`, making things
more practical but loosing the security benefits. But at this point,
I decided I wanted to try out a different stack - new VPS provider, new
OS, new web server. This is something I had been thinking about for
about a year at this point, and I'll talk about the reasons in the
next post.

But if you plan to host cgit on OpenBSD, do not be discouraged!
Everything can be set up with just a little manual work.

## My cgit configuration

My new cgit instance is hosted on an [Alpine Linux](https://alpinelinux.org)
VM and it is running via [Lighttpd](https://www.lighttpd.net).
For the basic setup, I followed [this wiki
page](https://wiki.alpinelinux.org/wiki/Cgit) (note that lighttpd has a
`mod_cgi` module that replaces fcgiwrap entirely). Not much
to say here, just a little fiddling with lighttpd's configuration.

As for customization, my configuration files are available in my
[cgit-config](https://git.tronto.net/cgit-config) repository. The
main configuration file,
[cgitrc](https://git.tronto.net/cgit-config/tree/cgitrc), is
well-commented, and won't require further explanation.

There are a bunch of other files too, such as the custom
[about-filter.sh](https://git.tronto.net/cgit-config/tree/custom/about-filter.sh)
which, is used to display README files more nicely. As for the custom
[css](https://git.tronto.net/cgit-config/tree/custom/cgit.css), the
main feature is making the website a little more comfortable to
browse on mobile; I shamelessly copied this part from [another cgit
user](https://git.matejamaric.com/responsive-cgit-css).

## Pros and con(cern)s

So far, cgit seems to run pretty fast on my new VM with a single CPU
core and 1GB of RAM. It also looks pretty cool, even though I liked
stagit's simplicity.

Unfortunately, the nice download button that I added to each of my
repositories is now gone. cgit allows downloading tarballs of a repo,
but only from tags, not for the current state of the master branch.
Overall, stagit's simplicity also allowed for great deal of customizability.

I am also a bit concerned about AI
[crawlers](https://en.wikipedia.org/wiki/Web_crawler). I have heard horror
stories of people having to make their repositories private because of
bots scanning their pages to feed the slop machine overloading their servers.
However, I hope cgit being quite small compared to a
[forge](https://en.wikipedia.org/wiki/Forge_(software)) such as
[GitLab](https://en.wikipedia.org/wiki/GitLab) or
[Gitea](https://en.wikipedia.org/wiki/Gitea) will help my server
sustain the extra effort - if any bot is interested in my code at all.

In conclusion, stagit served me well for a while, and I think
cgit is better suited to my needs now.

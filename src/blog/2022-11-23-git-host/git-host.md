# Self-hosted git pages with stagit (featuring ed, the standard editor)

This is a follow-up to my earlier blog entry
[How I update my website](../2022-08-14-website).

If you work on one or more personal software projects as a hobby,
chances are you are using `git`. To publish your project online
you may be using a website like GitHub, or perhaps a more
open source friendly alternative such as
[GitLab](https://about.gitlab.com/) or [sourcehut](https://sourcehut.org/).

But have you considered hosting your repositories, and serving them
via web pages, on your personal server? In this post I am going to show
you how I do it, in the usual minimalist and
not-using-what-I-do-not-understand style.

You can see the final result on my [git pages](https://git.tronto.net).
The scripts and other files I use to set this up are accessible
[here](https://git.tronto.net/git-hooks).

## Hosting git repositories on your own server

This step is quite simple, and you can just follow
[Roman Zolotarev's tutorial](https://rgz.ee/git.html) like I did - adapting
the first few steps to your OS if you are not running OpenBSD.

To sum it up, you need to:

1. Create a dedicate `git` account on your server (optional, if you know
   what you are doing).

2. Add your public SSH key to the `~/.ssh/authorized_keys` file of your newly
   created remote account.

3. Initialize a git repository on your server with `git init REPOSITORY`.

4. Clone it via SSH with `git clone git@SERVER:REPOSITORY`.

And you are done! If you want to use multiple remotes, for example your private
server and GitHub, you can do so by adding a push-only URL with
`git remote set-url --add --push origin URL`. But don't trust me on this
exact command, I always have to look it up
- you should do the same before running it.

Now your repositories are online, but how can you make them browsable via web?

## stagit

The tool I use to serve my git repositories as static web pages is
[stagit](https://codemadness.org/stagit.html). It is very easy to describe what
stagit does: running it on a git reporitory produces some directories with
a bunch of html files that you can simply move to your www hosting directory.

After generating the pages you can personalize them by copying your logo,
[favicon](https://en.wikipedia.org/wiki/Favicon) or CSS style sheet. You can
use `stagit-index` to generate
[an index page for your repositories](https://git.tronto.net/). Since everything
consists of html files, you can simply edit them to personalize your git pages
even further - and below you'll see some examples.

But you definitely do not want to do this by hand every time you push a commit.
Since the pages stagit generates are *static*, they do not update
automatically: you'll have to run stagit again every time. You can automate
this for example by running stagit periodically with cron, but there is an
easier way:
[git hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).

## Git hooks

By saving suitably named executable files inside your project's
`.git/hooks` directory you can automate any process you want during
certain stages of your git workflow. For example you can use a `pre-commit`
script to run commands before you commit changes, or a `pre-push` script
to do something before pushing a commit.

The hooks are divided in client-side and server-side. We are interested in
the server-side `post-receive` hook, which is executed on the remote every
time a commit is received. This is the last ingredient we need for our setup:
a simple `post-receive` hook that runs stagit and copies the files it
generates to the appropriate folder will do the trick.

## My setup

Throughout the rest of the post I will use the following variables, to be
set at the beginning of the script:

```
yourname="Sebastiano Tronto" # Author's name
repo="$PWD" # The full path of the repository
name="$(basename $repo .git)" # The name of the repository
baseurl="https://git.tronto.net" # The base URL for the repository
basedir="/var/www/htdocs/git.tronto.net" # The base directory for www files
htdir="$basedir/$name" # The www directory for the repository
```

### Basic stagit usage

The first thing we want to do is to set up some basic information in the
`owner` and `url` files that stagit is going to use. The hook is run in the
repository's directory, so it is not necessary to specify a full path:

```
echo "$yourname" > owner
echo "$baseurl/$name" > url
```

Next we prepare the target directory by removing old files and creating
it if necessary:

```
rm -rf "$htdir"
mkdir -p "$basedir"
```

To make the repository clonable by anyone from the same URL used to
view it, we need to copy the whole directory to the
www directory we have just created:

```
cp -r "$repo" "$htdir"
```

And finally we can run stagit:

```
cd "$htdir"
stagit -l 100 "$repo"
```

The `-l` option is used to specify how many commits should be visibile
in the log page.

For some basic personalization we can choose a different default page (index
file). I like to have the file list:

```
cp "$htdir/files.html" "$htdir/index.html"
```

And we can use our css style sheet, logo and icon:

```
cp $filesdir/favicon.png ./
cp $filesdir/logo.png ./
cp $filesdir/style.css ./
```

### Bells and whistles

I like stagit's simplicity, but there are a couple of things that I want to
add or change:

* I would like every page to show a simple footer at the bottom of
  each page.
* I would like to have a download button so that people who don't use git
  can still download my files. This makes sense especially for those
  repos that are mostly documents, such as my
  [lecture notes](https://git.tronto.net/mathsoftware) or my
  [FMC tutorial](https://git.tronto.net/fmctutorial).
* I would like to convert README.md files to html.

If I were calling stagit by hand after each `git push`, I
could simply make these changes with a text editor. But I want to automate
this! How can we edit files in a shell script?

Enter `ed`, [the standard editor](https://www.gnu.org/fun/jokes/ed-msg.html).
`ed` is a [line text editor](https://en.wikipedia.org/wiki/Line_editor)
initially released with UNIX Version 1. I am going to talk about it more
extensively in the next episode of my
[man page reading club](../2022-05-29-man/)
series. Without going into detail, `ed` does not show you the text you
are editing in a 2-dimensional windows: instead, it offers you a command
line prompt that you can use to run editing commands, such as `a` to add
text or `p` to print one or more lines of the file.

This might seems like a totally cumbersome way of editing a file, but
there is one nice side-effect: `ed` is completely scriptable.  This means
that if you know exactly what the file you want to edit looks like,
you can write the commands you want to run in advance and feed them to
the editor via standard input, instead of typing them interactively.
This is exactly what we want to do!

Going back to my stagit setup, say we have a file `bottom.html` that
looks like this:

```
<hr class="line">
<footer> <table>
<tr> <td class="contact">
	Back to <a href="https://sebastiano.tronto.net"> sebastiano.tronto.net </a>
</td>
<td class="hosted">
	Generated with <a href="https://codemadness.org/stagit.html">stagit</a>
</td> </tr>
</table> </footer>
```

and we want to insert its content in the file `file.html`, before
the line that contains the closing tag `</body>`. We can use the
following one-liner:

```
printf '%s\n' "/<\/body>" i "$(cat bottom.html)" . w | ed -s file.html
```

Here the `printf` command is used to feed the tokens `/<\/body>`, `i`,
`$(cat bottom.html)`, `.` and `w` to `ed`. These are going to
be interpreted as: "search for the closing tag `</body>`;
insert the following text until you encounter a single dot on a line:
[contents of the file `bottom.html`] single dot; save."
If this seems obscure, I suggest you read
[`ed`'s manual page](https://man.openbsd.org/OpenBSD-7.2/ed), or wait
for my next blog post!

The command for adding the download button is similar, after we
generate a zip archive of the repository using `git archive`:

```
git archive HEAD -o "$basedir/$name.zip"
printf '%s\n' \
	"/log\.html\">Log<\/a>" i \
	"<a href=\"$baseurl/$name.zip\">Download</a> |" . w \
| ed -s file.html
```

Here I am using backlashes to ignore the newline character, so that
I can use more lines for readability.

The two code snippets above have to be run for every html file generated
by stagit. To loop over all these files, you can use `find`:

```
for f in $(find "$htdir" -name "*.html"); do
	[stuff...]
done
```

The command to turn README.md files into a formatted html page is a bit
more complicated, but I will try to keep the explanation short, since
this post is already quite long. Feel free to send me an email if you
have questions!

To have an idea of what the README.md.html file generated by
stagit looks like, you can check out the html of
[this page](https://codemadness.org/git/stagit/file/README.html),
for example (right click and "View page source" or something similar in
most browsers, or `curl [URL]` if you are cool).

First, since I am using bare git repositories, I need to actually "create"
the original README.md file - instead of using its rendered-as-plain-text
html version generated by stagit - using `git show`. Then we need to
remove from README.md.html all the lines that
are part of the code listing, i.e. all those that contain a `class="line"`
string.  The `ed` command to do this is `g/class=\"line\"/d`. Then we
need to remove a couple more lines and finally we can insert the result
of the command `lowdown file/README.md`, which converts the markdown
file to html, into the correct place. The final result is:

```
git show master:README.md > file/README.md
printf '%s\n' \
	g/class=\"line\"/d \
	"/<pre id=\"blob\">" d d i "$(lowdown file/README.md)" . w \
| ed -s file/README.md.html > /dev/null
```

### stagit-index

Just a quick mention to how I use stagit-index, the command used to
generate the index page.
The only change I make from the default configuration is to change
the links to each repository to point to the file list instead
of the log page. stagit-index writes its result to standard output, so 
I can simply use `sed`:

```
stagit-index /home/git/*.git | sed 's|/log\.html||g' > "$basedir/index.html"
```

And that's it. Well, I also copy the style files and add a bottom bar,
and change the title from a `<span class="desc">` to an `<h1>` element,
again using `ed`. If you want to see the details you can check them out
[here](https://git.tronto.net/git-hooks/file/post-receive-stagit.html).

## Conclusions

stagit is the perfect minimalist tool to publish your git repository
with a simple, static web interface. It requires nothing more than
an http server capable of serving html files. Static files are also
very simple to customize and tune to your needs.

I have wanted to make this post for quite some time now, mainly
as an excuse to clean up and document my scripts. I finally had some
time to work on this - even if scattered around multiple days.

As always, I have tried but failed to keep my post short - I am too
eager to explain everything I know as clearly as possbile!
I hope you enjoyed or found it useful. If you have questions or comments,
feel free to send me an [email](mailto:sebastiano@tronto.net).

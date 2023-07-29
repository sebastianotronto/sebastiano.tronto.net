# My minimalistic RSS feed setup

A couple of years ago I started using
[RSS](https://en.wikipedia.org/wiki/Rss)
(or [atom](https://en.wikipedia.org/wiki/Atom_(standard)))
feeds to stay up to date with websites and blogs I wanted to read.
This method is more convenient than what I used before (i.e. open
Firefox and open each website I want to follow in a new tab, one
by one), but unfortunately not every website provides an RSS feed
these days.

At first I used [newsboat](https://newsboat.org), but I soon started
disliking the curses interface - see also my rant on curses at the
end of [this other blog post](../2022-12-24-ed). Then I discovered
`sfeed`.

## sfeed

[`sfeed`](https://codemadness.org/sfeed-simple-feed-parser.html)
is an extremely minimalistic RSS and atom reader: it reads
the xml content of feed file from standard input and it outputs one line per
feed item, with tab-separated timestamps, title, link and so on. This tool
comes bundled with other commands that can be combined with it, such as
`sfeed_plain`, which converts the output of sfeed into something
more readable:

```
$ curl -L https://sebastiano.tronto.net/blog/feed.xml | sfeed | sfeed_plain
  2023-06-16 02:00  UNIX text filters, part 0 of 3: regular expressions                    https://sebastiano.tronto.net/blog/2023-06-16-regex
  2023-05-05 02:00  I had to debug C code on a smartphone                                  https://sebastiano.tronto.net/blog/2023-05-05-debug-smartphone
  2023-04-10 02:00  The big rewrite                                                        https://sebastiano.tronto.net/blog/2023-04-10-the-big-rewrite
  2023-03-30 02:00  The man page reading club: dc(1)                                       https://sebastiano.tronto.net/blog/2023-03-30-dc
  2023-03-06 01:00  Resizing my website's pictures with ImageMagick and find(1)            https://sebastiano.tronto.net/blog/2023-03-06-resize-pictures
...
```

One can also write a configuration file with all the desired feeds
and fetch them with `sfeed_update`, or even use the `sfeed_curses`
UI. But the reasons I tried out `sfeed` in the first place is that
I *did not* want to use a curses UI, so I decided to stick with
`sfeed_plain`.

## My wrapper script - old versions

In the project's homepage the following short script is presented to
demonstrate the flexibility of sfeed:

```
#!/bin/sh
url=$(sfeed_plain "$HOME/.sfeed/feeds/"* | dmenu -l 35 -i | \
	sed -n 's@^.* \([a-zA-Z]*://\)\(.*\)$@\1\2@p')
test -n "${url}" && $BROWSER "${url}"
```

The first line shows a list of feed items in
[dmenu](https://tools.suckless.org/dmenu)
to let the user select one, the second line opens the selected item
in a web browser. I was impressed by how simple and clever this
example was, and I decided to expand on it to build "my own" feed
reader UI.

In the first version I made, my feeds were separated in folders,
one per file, and one could select multiple feeds or even entire
folders via dmenu using
[dmenu-filepicker](https://git.tronto.net/scripts/file/dmenu-filepicker.html)
for file selection.
Once the session was terminated, all shown feeds were marked as
"read" by writing the timestamp of the last read item on a cache
file, and they were not shown again on successive calls.

This system worked fine for me, but at some point I grew tired of
feeds being marked as "read" automatically. I also disliked the
complexity of my own script.  So I rewrote it from scratch, giving
up the idea of marking feeds as read. This second version can still
be found in the *old* folder of my
[scripts repo](https://git.tronto.net/scripts), but I may remove it
in the future. You will still be able to find it in the git history.

I have happily used this second version for more than a year, but
I had some minor issues with it. The main one was that, as I started
adding more and more websites to my feed list, fetching them took
longer and longer - up to 20-30 seconds; while the feed was loading,
I could not start doing other stuff, because later dmenu would have
grapped my keyboard while I was typing. Moreover, having a way to
filter out old feed items is kinda useful when you check your feed
relatively often.  A few weeks ago I had enough and I decided to
rewrite my wrapper script once again.

## My wrapper script - current version

In its current version, my `feed` scripts accepts four sub-commands:
`get` to update the feed, `menu` to prompt a dmenu selection, `clear`
to remove the old items and `show` to list all the new items.
Since `clear` is a separate action, I do not have the problem I
used to have with my first version, i.e. that feeds are automatically
marked as read even if I sometimes do not want them to be.

Let's walk through my last iteration on this script - you can find
it in my scripts repository, but I'll include it at the end of this
section too.

At first I define some variables (mostly filenames), so that I can
easily adapt the script if one day I want to move stuff around:

```
dir=$HOME/box/sfeed
feeddir=$dir/urls
destdir=$dir/new
olddir=$dir/old
readdir=$dir/last
menu="dmenu -l 20 -i"
urlopener=open-url
```

Here `open-url` is another one of my utility scripts.

To update the feed, I loop over the files in my feed folder.  Each
file contains a single line with the feed's url, and the name of
the file is the name / title of the website. The results of `sfeed`
are piped into `sfeed_plain` and then saved to a file, and the most
recent time stamp for each feed is updated.

```
getnew() {
	for f in "$feeddir"/*; do
		read -r url < "$f"
		name=$(basename "$f")
		d="$destdir/$name"
		r="$readdir/$name"

		[ -f "$r" ] && read -r lr < "$r" || lr=0

		# Get new feed items
		tmp=$(mktemp)
		curl -s "$url" | sfeed | \
		awk -v lr="$lr" '$1 > lr {print $0}' | \
		tee "$tmp" | sfeed_plain >> "$d"

		# Update last time stamp
		awk -v lr="$lr" '$1 > lr {lr=$1} END {print lr}' <"$tmp" >"$r"
	done
}
```

The next snippet is used to show the new feed items.
The `for` loop could be replaced by a simple
`cat "$destdir"/*`, but I also want to prepend each line with 
the name of the website.

```
show() {
	for f in "$destdir"/*; do
		ff=$(basename "$f")
		if [ -s "$f" ]; then
			while read -r line; do
				printf '%20s    %s\n' "$ff" "$line"
			done < "$f"
		fi
	done
}
```

Finally, the following one-liner can be used to prompt the user to
select and open the desired items in a browser using dmenu:

```
selectmenu() {
	$menu | awk '{print $NF}' | xargs $urlopener
}
```

The "clear" action is a straightfortward file management routine,
and the rest of the script is just shell boilerplate code to parse
the command line options and sub-commands. Putting it all together,
the script looks like this:

```
#!/bin/sh

# RSS feed manager

# Requires: sfeed, sfeed_plain (get), dmenu, open-url (menu)

# Usage: feed [-m menu] [get|menu|clear|show]

dir=$HOME/box/sfeed
feeddir=$dir/urls
destdir=$dir/new
olddir=$dir/old
readdir=$dir/last
menu="dmenu -l 20 -i"
urlopener=open-url

usage() {
	echo "Usage: feed [get|menu|clear|show]"
}

getnew() {
	for f in "$feeddir"/*; do
		read -r url < "$f"
		name=$(basename "$f")
		d="$destdir/$name"
		r="$readdir/$name"

		[ -f "$r" ] && read -r lr < "$r" || lr=0

		# Get new feed items
		tmp=$(mktemp)
		curl -s "$url" | sfeed | \
		awk -v lr="$lr" '$1 > lr {print $0}' | \
		tee "$tmp" | sfeed_plain >> "$d"

		# Update last time stamp
		awk -v lr="$lr" '$1 > lr {lr=$1} END {print lr}' <"$tmp" >"$r"
	done
}

show() {
	for f in "$destdir"/*; do
		ff=$(basename "$f")
		if [ -s "$f" ]; then
			while read -r line; do
				printf '%20s    %s\n' "$ff" "$line"
			done < "$f"
		fi
	done
}

selectmenu() {
	$menu | awk '{print $NF}' | xargs $urlopener
}

while getopts "m:" opt; do
	case "$opt" in
		m)
			menu="$OPTARG"
			;;
		*)
			usage
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

if [ -z "$1" ]; then
	usage
	exit 1
fi

case "$1" in
	get)
		getnew
		countnew=$(cat "$destdir"/* | wc -l)
		echo "$countnew new feed items"
		;;
	menu)
		show | selectmenu
		;;
	clear)
		d="$olddir/$(date +'%Y-%m-%d-%H-%M-%S')"
		mkdir "$d"
		mv "$destdir"/* "$d/"
		;;
	show)
		show
		;;
	*)
		usage
		exit 1
		;;
esac
```

I personally like this approach of taking a simple program that
only uses standard output and standard input and wrapping it around
a shell script to have it do exactly what I want. The bulk of the
work is done the "black box" program, and the shell scripts glues
it together with the "configuration" files (in this case, my feed
folder) and presents the results to me, interactively (e.g. via
dmenu) or otherwise.

At this point my feed-comsumption workflow would be something like
this: first I `feed get`, then I do other stuff while the feed loads
and later, after a couple of minutes or so, I run a `feed show` or
`feed menu`.  This is still not ideal, because whenever I want to
check my feeds I still have to wait for them to be downloaded.  The
only way to go around it would be to have `feed get` run automatically
when I am not thinking about it...

## Setting up a cron job

My personal laptop is not always connected to the internet, and in
general I do not like having too many network-related jobs running
in the background.  But I do have a machine that is always connected
to the internet: the VM instance hosting this website.

Since my new setup saves my feed updates to local files, I can have
a [cron job](https://en.wikipedia.org/wiki/Cron_job) fetch the new
items and update files in a folder sync'd via
[syncthing](https://syncthing.net) (yes, I do have that *one* network
service constantly running in the background...). This setup is
similar to the one I use to [fetch my email](../2022-10-19-email-setup).

I rarely use cron, and I am always a little intimitaded by its
syntax. But in the end to have `feed get` run every hour I just
needed to add the following two lines via `crontab -e`:

```
MAILTO=""
0 * * * * feed get
```

This is my definitive new setup, and I like it. It also has the
advantage that I only need to install `sfeed` on my server and not
locally, though I prefer to still keep it around.

So far I have found one little caveat: if my feed gets updated after
I read it and before I run a `feed clear`, some items may be deleted
before I see them.  This is easilly worked around by running a quick
`feed show` before I clear the feeds up, but it is still worth
keeping in mind.

## Conclusions

This is a summary of my last script-crafting adventure. As I was
writing this post I realized I could probably use `sfeed_update`
to simplify the script a bit, since I do not separate feeds into
folders anymore. I have also found out that `sfeed_mbox` was created
(at least I *think* it was not there the last time I checked) and I
could use it to browse my feed with a mail client - see also
[this video tutorial](https://josephchoe.com/rss-terminal) for a demo.

With all of this, did I solve my problem in the best possible way?
Definitely not. But does it work for me? Absolutely! Did I learn
something new while doing this? Kind of, but mostly I have just
excercised skills that I already had.

All in all, it was a fun exercise.

# The man page reading club: shutdown(8)

*This post is part of a [series](../../series)*

I would like to write about more interesting things, but I do not have
time or energy to do so. I need to shut down for a little while.

## Sleeping in a sleepless time

*Reading. Learning. Fun. Tired.*

```
$ date 
Thu Jul  7 22:57:50 CEST 2022
```

*Not too late. You should do something.*

```
$ man man
NAME
	man - display manual pages
```

*No, you have already done that one. What should you do?*

```
$ date
Thu Jul  7 22:59:48 CEST 2022
```

*This is not going anywhere. Is it time to go to sleep? Who knows,
during the covid lockdown - ahem, nuclear winter - every hour looks the same.
Maybe it is time to go to sleep. To shutdown.*

## shutdown(8)

*Follow along at [man.openbsd.org](https://man.openbsd.org/OpenBSD-7.1/shutdown)*

```
SYNOPSIS
	shutdown [-] [-dfhknpr] time [warning-message ...]

DESCRIPTION
	shutdown provides an automated shutdown procedure for superusers to
	nicely notify users when the system is shutting down, saving them from
	system administrators, hackers, and gurus, who would otherwise not bother
	with such niceties.  When the shutdown command is issued without options,
	the system is placed in single user mode at the indicated time after
	shutting down all system services.
```

As it sometimes happens, the first few lines of the manual page hint to some
arcane background that you cannot quite grasp. However, the bottom line is
clear: `shutdwon` shuts the system down.

```
The options are as follows:
	-d	When used with -h, -p, or -r causes system to perform a dump.
		This option is useful for debugging system dump procedures [...].
```

Good to keep in mind. But this time we are not in for an in-depth analysis of
a classic UNIX command. We just want to shut down. Let's skip a few of the
other options.

```
	-p	The system is powered down at the specified time.  The -p flag is
		passed on to halt(8), causing machines which support automatic
		power down to do so after halting.

	-r	shutdown execs reboot(8) at the specified time.
```

Yes, these sound like things I would like to do. How do I tell it to
shut down now?

```
	time  time is the time at which shutdown will bring the system down and
	      may be the word now (indicating an immediate shutdown) or specify
	      a future time in one of two formats: +number or yymmddhhmm,
	      where the year, month, and day may be defaulted to the current
	      system values.  The first form brings the system down in number
	      minutes and the second at the absolute time specified.
```

Great!

```
	warning-message
		Any other arguments comprise the warning message that is
		broadcast to users currently logged into the system.
	-	If `-' is supplied as an option, the warning message is read from
		the standard input.
```

Who do we have to warn about the shutdown? We are the only user anyway, right?

```
# echo 'the hours rise up putting off stars and it is
> dawn' | shutdown -p now -
```

## Conclusions

At the moment of writing this blog post, I am tired. I had a busy week.
I wanted to write an interesting blog post about something like
sh(1), but I could not find the time. However, shutting down my pc earlier
today inspired me to write this short blog entry.

`shutdown` is an interesting command. It seems like it should be
straightforward: "computer, please shut down". But the syntax for
this simple instruction is quite complicated, and it offers us many
more options than we would ever want to use, at least in the 21st
century.  Moreover, as indicated by the `#` instead of the `$` in
the last command, one needs superuser privileges to shut down a
classic UNIX system.

This is because, in the time of mainframes, *shutting down* was not such a
simple operation: multiple users might have been connected to the main
computer, and shutting the whole system down without at least telling them
was rude. At least this is my guess, I was not there at the time.

It would certainly be interesting to dig into the history of computer systems,
mainframes and how administrators used to shut them down when multiple users
were logged in. But I am not going to do it now.

Good night.

*Next in the series: [sh(1) - part 1: shell grammar](../2022-09-13-sh-1)*

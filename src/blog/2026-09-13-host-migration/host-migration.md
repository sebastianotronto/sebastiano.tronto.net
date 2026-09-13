# Host migration

Since this website went online in 2022, It has lived
in a virtual machine on server 14 at [OpenBSD
Amsterdam](https://openbsd.amsterdam). This is a small, independent
VPS provider that donates large part of their profit to the
[OpenBSD foundation](https://www.openbsdfoundation.org). They
are pretty cool, and their service worked quite well for me.

Nonetheless, I have recently migrated to another provider, and I
am not going to renew my OpenBSD Amsterdam subscription next year.
There are a few reasons for this.

## Why switch?

First of all, I want to make clear that I did not have any issue
with OpenBSD Amsterdam. In fact, I think it was the right choice for
me 4 years ago, and I can strongly recommend it.

OpenBSD as well was a great OS choice, at the beginning.
The convenience of having many of the services I needed - such as
[httpd](https://man.openbsd.org/httpd),
[rsync](https://man.openbsd.org/openrsync),
[ssh](https://man.openbsd.org/ssh) - included in the base system and
well-documented was big. But OpenBSD is also an
[opinionated](https://www.merriam-webster.com/dictionary/opinionated)
piece of software,
and some of its "opinions" started feeling a bit restrictive.

For example, OpenBSD nudges you into using separate
[partitions](https://en.wikipedia.org/wiki/Disk_partitioning) for
different system folders, for security reasons. This is how the 50GB
of my OpenBSD Amsterdam VM are currently allocated:

```
[pizoc ~] $ df -h
Filesystem     Size    Used   Avail Capacity  Mounted on
/dev/sd0a      986M    111M    825M    12%    /
/dev/sd0k     17.4G    3.9G   12.6G    24%    /home
/dev/sd0d      3.2G    8.0K    3.0G     1%    /tmp
/dev/sd0f      5.2G    1.7G    3.3G    34%    /usr
/dev/sd0g      986M    545M    392M    59%    /usr/X11R6
/dev/sd0h      6.7G    184M    6.2G     3%    /usr/local
/dev/sd0j      5.8G    2.0K    5.5G     1%    /usr/obj
/dev/sd0i      1.9G    2.0K    1.8G     1%    /usr/src
/dev/sd0e      5.0G    4.4G    423M    92%    /var
```

My websites are in `/var/www`, and as you can see that partition
is almost full. I also use `/home` extensively - my git repositories
are in `/home/git` and a shared
[syncthing](https://syncthing.net) folder is in `/home/sebastiano`.
I have plenty of space still available in `/home`, but I can't
esily use it for hosting websites, because of httpd's chroot. See
[my previous post](../2026-09-05-cgit) for details on what this means.

Another downside of httpd is that it is not as feature-complete
as other web server. This can be considered an advantage, but
occasionally it requires some extra setup for certain use cases.
For example, [until
recently](https://undeadly.org/cgi?action=article;sid=20260725103657)
it did not support custom HTTP headers, so I had to combine it
with relayd when I wanted to experiment with a [web
application](https://h48.tronto.net) I was working on - see also
[my post on WebAssembly](../2025-06-06-webdev/) for context.
Once again, this was not a showstopper, but
it was unnecessary additional friction.

Lastly, my provider was a bit more expensive than I would have
liked: 71€ per year for a VM with 1GB of RAM and 50GB of
storage. For comparison, I am now paying 22€ per year for
a VM with the same RAM and 30GB of storage. To be fair,
OpenBSD Amsterdam is a small, independent provider, and they
donate a most of their revenuw to the OpenBSD foundation; I was
happy to support them. But I am also happy to save 49€
per year.

## The new stack

My new provider is [netcup](https://www.netcup.com/en), an established
German company. I don't personally know anyone hosting there,
but their prices are good and the reviews are positive. Their [smallest
VPS](https://www.netcup.com/en/server/vps-lite) is only 1.87€ per
month, and it is enough for my needs.

They support any operating system that can boot from a
[Qcow](https://en.wikipedia.org/wiki/Qcow) image, as you can upload your
own; so technically I could have stayed with OpenBSD. But I wanted
to change the OS for the reasons I gave in the previous section, so I
went with [Alpine Linux](https://alpinelinux.org), a lightweight
Linux distribution that I have been pleasantly using on my laptop for a
while now.

As for the web server, I did not give it much thought.
[Lighttpd](https://www.lighttpd.net) seems fairly lightweight and it
does what I need it to do, so I went with that.

## Migration hiccups

I initially planned to migrate my [git server](../2026-09-05-cgit)
and this website one at the time, but soon I realized that it would have
been less work and less risk to do everything at once. So I set aside
a full Sunday afternoon to move everything over.

Unfortunately, I had some issues. The biggest one, that took me over
three hours to work around, was related to setting up my SSL
certificates - the "S" in [HTTPS](https://en.wikipedia.org/wiki/HTTPS).
I wanted to use the same software I was using on OpenBSD,
[acme-client](https://man.openbsd.org/acme-client.1), but something
went wrong. I kept getting an HTTP 409 error with the following
explanation:

```
acme-client: transfer buffer: [{
"type": "urn:ietf:params:acme:error:conflict",
"detail": "Unable to update challenge :: failed to mark authz as processing: Authorization is already being validated. This may indicate your client attempted the same challenge multiple times, possibly due to a client bug.",
"status": 409
}] (296 bytes)
acme-client: bad exit: netproc(31648): 1
```

Searching online, I found out that I was [not the only
one](https://www.reddit.com/r/openbsd/comments/1vz4mcg/acmeclient_bad_http_409)
with this problem, so I decided to use [certbot](https://certbot.eff.org)
as a temporary workaround. But I still want to go back to
acme-client at some point.

The other issue was AI. And I am not talking about OpenAI's and
Anthropic's bots accessing my git pages every 0.9 seconds (that
is not an exaggeration, I `tail -f`'d the log file). I am
talking about actually trying to use these chatbots for their
intended purpose. Namely, instead of reading the manual pages
for lighttpd and writing a configuration file from scratch,
I asked AI (either [duck.ai](https://duck.ai)) or
[Kagi Assistant](https://kagi.com/assistant/), I forgot which one)
to translate my httpd configuration file to a lighttpd one. Then
I could look up the documentation for just the settings I was
using, saving some time. Or so I thought.

First of all, the initial response had more stuff than
I wanted. The bot just allucinated features that were not included
in the original configuration. But that's alright, it's just how
the slop machine works.

But then there were also errors, in particular with setting
up the redirects from my `http://*.tronto.net` domains to their
`https://` counterparts. I went through various iterations of
"this does not work, it does X instead of Y, please fix" and
"You are absolutely right! Here is the fixed version",
but somehow the bots could
never come up with a working configuration. I ended up fixing
it by hand like a caveman, as I should have done from the
beginning. What a waste of time.

But by the end of the afternoon, almost everything was working
as intended.

## My experience so far

So far everything is working smoothly. Once in a while I notice
a minor mistake I made during the setup and I fix it - for example,
I have just noticed this morning that lighttpd's access log was
eating most of my storage, so I disabled it. But everything is now
up and running, and this page you are reading is served by my new
stack - unless you are reading it years after I published this
post and I have changed my setup again in the meantime.

The only real difference I noticed is that when I use `rsync`
to update my website, the whole process is much, much faster
- like 10x faster. I don't know if this is because the new
server has a much faster hard drive or because OpenBSD's `rsync`
was much slower. In any case, it is a nice surprise!

# FOSDEM 2026

On January 31st and February 1st I went to [FOSDEM](https://fosdem.org),
the largest Open Source Software conference in the World. It happens every
year in Brussels, only a couple of hours of train away from where I live.
This is actually the second time I go: I was there in 2024 too.

If you have never been to FOSDEM, you may not know about the sheer size
of the thing. To give you an idea, this year there were around 1200
speakers. Yes, you read it right, not *attendees*, but *speakers*.
This means more than a thousand talks over the course of two days.

Obviously, talks are divided into tracks (called *dev rooms*),
and people move around from one to the other, hoplessly trying to attend
all the talks they interested in. Besides the talks, there are also
[community gatherings](https://fosdem.org/2026/schedule/track/bof/),
[lightning talks](https://fosdem.org/2026/schedule/track/dev-random/),
activities for children and so on.

Some people say FOSDEM is also a great place to socialize with like-minded
people, but I am not good at that. Unless sitting next to each other in
complete silence counts at socializing - in that case I am the master
of socializing!

Anyways, here is a short summary of my experience at FOSDEM 2026. If
you are interested in any of the talks I mention in this post, follow
the links I provide to watch the videos - those that have not already
been uploaded will be in a matter of days.

## Saturday

Eager not to miss any talk, I took the first train to Brussels on Saturday
morning. I arrived to the city very early, so I decided to walk the ~4.5km
from the station to the university campus where FOSDEM takes place,
and I was still well in time for the first talk. It was quite warm for
the end of January.

### Welcome to FOSDEM

I went to plenary
[introduction](https://fosdem.org/2026/schedule/event/SFKNTZ-welcome_to_fosdem_2026/)
where the organizers give some practical information about the conference.
Besides that, the speaker gave a rather political speach, where he talked
about the importance of Open Source software in preserving democracy in
current times. It was clearly very important to him, as he got emotional
during the short speech; but the crowd was supportive.

### FOSS on mobile devices

After the introduction I went straight to the [FOSS on mobile dev
room](https://fosdem.org/2026/schedule/track/foss-on-mobile/).
The first talk was entitled ["The state of FOSS on
mobile"](https://fosdem.org/2026/schedule/event/SW83YJ-state_of_foss_on_mobile/)
and, from what I gathered from this mornings talk, it could be summarized
with three words: very, very sad. At least on the Android side of
things: Google is making Android harder to work with for the open source
community, by developing it behind closed doors and releasing updates
only twice a year. The other talks described how [huge Android's code
base is](https://fosdem.org/2026/schedule/event/9DRDS7-deep-dive-aosp/)
(1.7TB, if you are curious), how hard it is to [port to other
architectures](https://fosdem.org/2026/schedule/event/SXX8HE-open_source_risc-v_aosp_porting_progress_challenges_and_upstream_work/)
and why it is [so slow to build
it](https://fosdem.org/2026/schedule/event/KX88W8-aosp-build/). Oh and
Android apps are going the Apple way and it may soon not be possible to
install them unless the developer officially received Google's blessing.

I wanted to follow also a couple of talks in the afternoon
about *mainline* Linux distributions for phones, such as
[PostmarketOS](https://postmarketos.org/), but the room was full so I
had to skip those. Hopefully things are going better on that front.

### Hare community meetup

After a short break that I spent "socializing"
(eavesdropping random conversations while passing by groups
of people counts, right?), I decided to join the [Hare community
meetup](https://fosdem.org/2026/schedule/event/EKCFEH-hare_community_meetup/).
In case you have never heard of it, [Hare](https://harelang.org/) is
a currently in-development programming language initially created by
[Drew Devault](https://drewdevault.com/).

I share a lot of ideas about what a programming language should
be like with the creators of Hare, and I am eagerly waiting
for the 1.0 release with its promised perpetual backwards
compatibility. Apart from this, my relationship with the Hare
community so far consists in having attended the [announcement
talk](https://harelang.org/blog/2022-04-25-announcing-hare/) back in 2022,
having read the [specification](https://harelang.org/specification/) once
and sent a patch for a couple of typos, and now joining this community
meetup. That's it.

The gathering lasted a little less than an hour and lots of
topics were briefly discussed, including some comparison with
[Zig](https://ziglang.org/).

I you want to see some Hare code, some time ago I
implemented a very simple (and very ugly) [minesweeper
clone](https://git.tronto.net/minesweeper) with it (using
[raylib](https://www.raylib.com/).

### Python

After the meetup I went to the Python dev room. I am currently working
with Python at my daily job, so I thought this could be useful.

I was there in time to attend [a talk on lazy
imports](https://fosdem.org/2026/schedule/event/HAAABD-the_bakery_how_pep810_sped_up_my_bread_operations_business/)
and one on the [GIL
removal](https://fosdem.org/2026/schedule/event/ABJMWD-the_gil_and_api_performance_past_present_and_free-threaded_future/).
Both were quite interesting.  I wanted to follow also [the next
one](https://fosdem.org/2026/schedule/event/WE7NHM-modern-python-monorepo-apache-airflow/),
but the room was way too hot for me, so I ran out and took another
break.

### How to make package managers scream

[This](https://fosdem.org/2026/schedule/event/DCAVDC-how_to_make_package_managers_scream/)
was a fun one. It was a tongue-in-cheek talk about all the things
developers do that make life hard for "package managers", i.e. people
that install and maintain software installations for other people. I
enjoyed it.

### gotwebd

Quite late in the day, at 18:15, there was [a
talk](https://fosdem.org/2026/schedule/event/K7YXFT-gotweb/) I was
very interested in. It was about [`got`](https://gameoftrees.org/), a
version control system compatible with git repositories, develop by some
[OpenBSD](https://www.openbsd.org/) people, and in particular about its
web server deamon, `gotwebd`.

Just a couple of months ago I started looking into alternative ways
to [host my git pages](../2022-11-23-git-host). I started configuring
[cgit](https://git.zx2c4.com/cgit/) (and at some point I'll finish the
work and write about it here), but I experienced some inconveniencies
when working with OpenBSD's httpd chroot. Since `got` is developed mainly
for OpenBSD, its web server should integrate quite well with the OS.

I am glad I went to this talk in the end, it motivated me to try out
`gotwebd`. And I managed to get back to the hotel in time to have dinner
with some colleagues of mine.

## Sunday

After drinking a couple of beers at [Delirium
Village](https://en.wikipedia.org/wiki/Delirium_Caf%C3%A9), sleeping
decently well and eating *like a pig* at the hotel's buffet breakfast,
I once again walked to the campus. Yes, I walked a lot this weekend.

My plan for the day was to split my time between the [Software
Performance](https://fosdem.org/2026/schedule/track/software-performance/)
and the [Rust](https://fosdem.org/2026/schedule/track/rust/) dev rooms,
and closing the day with the last 2 or 3 main track talks.

Walking back and forth between rooms is not ideal because you end up
wasting a lot of time queuing and you risk missing talks if the room
is full.  Luckily for me, it worked out, also thanks to the fact that
the Rust room was *huge*.

### Software Performance

In this room there was a good mix of talks about different aspects of
software performance: some talks were about low-level optimizations you
can make to your code, others about benchmarking, and others about how
to make your overengineered Kubernetes mess suck a bit less - these may
not be the exact words used by the speakers, I have not followed any
talk on overengineered Kubernetes messes.

[The first
talk](https://fosdem.org/2026/schedule/event/TYX3FF-accessible_software_performance/)
was in part an introduction to the room and in part an
overview of some compile-time optimization techniques, such as
[PGO](https://en.wikipedia.org/wiki/Profile-guided_optimization) and
[LTO](https://en.wikipedia.org/wiki/Interprocedural_optimization).

I came back to this room later in the
morning for [a talk about measuring performance
reliably](https://fosdem.org/2026/schedule/event/8AS3XD-how-to-reliably-measure-software-performance/).
I was afraid I would miss it because the room was so full, but I managed
to sneak in, even though I had to stand during the talk. In short, it was
a really nice talk, and I learnt a couple of tricks to make benchmarks
more consistent and reproducible.

Then, in the afternoon, I attended
a talk about [writing a fast JSON parser in
LUA](https://fosdem.org/2026/schedule/event/MFPHVE-ultrafast-lua-json-parsing/)
and another about
[`memcpy()`](https://fosdem.org/2026/schedule/event/PAXHDR-memcpy/).
Both were nice, especially the latter, and they were precisely about the
kind of low-level optimization stuff that I enjoy playing with recently.

### Rust

The Rust dev room was, as I expected, quite popular. But the organizers
wisely assigned it to a very large conference room, so nobody was stopped
from attending, as far as I know.

In the morning I saw a guy [talking
about](https://fosdem.org/2026/schedule/event/W3UFSK-rust-game-boy/)
how he wanted to write GameBoy games in Rust,
but the GameBoy's custom CPU is not supported by
[rustc](https://doc.rust-lang.org/rustc/what-is-rustc.html), so he had
to write a compiler first.  Pretty cool!

I came back to this room in the afternoon for two back-to-back talks. [The
first](https://fosdem.org/2026/schedule/event/RCFALN-rust-building-performance-critical-python-apps/)
was by someone who wanted to speed up their Python code base, and they
ended up replacing some default Python tools with Rust-based alternatives
- not because they necessarilly wanted to use Rust-based stuff, but
because they turned out to be the most performant.

[The last rusty
talk](https://fosdem.org/2026/schedule/event/GWRDNT-rust-type-checking-python/)
I attended was about [ty](https://docs.astral.sh/ty/), a type-checker for
Python that I will probably start using at work soon - and I am already
using other tools by the same developers. The talk went quite deep into
the details of the implementation. I would have preferred if they told
us a bit more about what the tool does instead, but this was the Rust
dev room after all, not the Python one.

### Lightning lightning talks

Later in the day, I was back in the main track
room in time for the second [Lightning Lightning
Talks](https://fosdem.org/2026/schedule/event/G3ZWYU-lightning_lightning_talks_2/)
session. Every speaker was given 256 seconds to present. I
was expecting the talks to be humorous, but actually most of
them were a bit boring. Shout out to the speakers who talked
about smart TVs, the [PostgreSQL Compatibility
Index](https://drunkdba.medium.com/postgresql-compatibility-index-the-fellowship-of-the-database-4005f818f97c)
and [rendering windows in a terminal](https://github.com/dextero/smithay),
I found these ones very entertaining!

### Open Source security in spite of AI

[Daniel Stenberg](https://daniel.haxx.se/), creator
and maintainer of [`curl`](https://curl.se/), gave the
final keynote talk, entitled [Open Source Security in Spite of
AI](https://fosdem.org/2026/schedule/event/B7YKQ7-oss-in-spite-of-ai/). He
presented his experience with AI, both the good and the ugly: he talked
about how slop spam forced him to close `curl`'s bug bounty program, but
also about the LLM-based code analysis tools that are helping him improve
the code. I highly recommend you watch the video if you want to know more.

I had already heard about the spam issues he was facing, so the part
about the useful AI tools was the most interesting for me. Normally when
I read comments on Hacker News or otherwise hear developers claiming that
<s>copy paste bots</s> AI coding tools can produce great code with little
supervision, I am very skeptical. My experience with these tools is that
they produce horrible code that is at best usable for throwaway scripts
that you are never going to look at again. But this talk was different,
it made complete sense. It makes sense that LLMs can compare your code
with the documentation and find inconsistencies. It makes sense that they
can guess edge cases that you forgot about. And it makes sense that they
make up inexistent vulnerabilities when asked to.

### Closing FOSDEM

After the closing talk I walked back to the station. I am now typing this
post on the train. I guess this is part of the FOSDEM weekend too, right?

## Miscellanea

I'll conclude this post with a list of random things that I could not fit
above. I'll do this in everyone's favorite literary style: an LLM-style
bullet point list.

*Sure! Here is a list of topics that have not been mentioned in this
post so far:*

* **Plan ahead:** I enjoyed this edition of FOSDEM more than the 2024
one, because I planned more carefully which talks I wanted to watch,
which backups I could attend if I changed my mind last minute, and when
to take breaks.
* **Laptop charging:** After using my laptop on the train and during the
talk, it was below 30% by 12:00. It was hard to find a place to plug it
in, so I ended up sitting on the floor in a corrdidor next to a power
outlet. Next time I should use pen and paper to take notes instead.
* **Physical exercise:** I walked at least 20km during the weekend,
not including moving from one dev room to the other between talks.
I could have used public transport more, but I enjoy walking.
* **Feeling motivated:** The performance-related
talks motivated me to continue improving my [Rubik's cube
solver](../2026-01-28-prefetch/). Maybe I'll start working on that
*microthreading* thing sooner rather than later!
* **Website improvements:** I should support
[IPv6](https://en.wikipedia.org/wiki/IPv6) on my website.  That should
be as easy as adding one configuration line in my host name records,
but I have never bothered so far. But now I'll have to, because next
year the FOSDEM public wifi won't support IPv4 anymore!  my website was
not reachable with the main FOSDEM wifi, and next year it is going to
be IPv6 only.

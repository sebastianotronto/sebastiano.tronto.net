# The gemini protocol

My website is also available as a *gemini capsule* at
[gemini://tronto.net](gemini://tronto.net).
Can't open this link? Of course, you'll need a *gemini* browser for that!

[Gemini](https://gemini.circumlunar.space) is a very young (2019) internet
protocol similar to the mcuh more famous
[HTTP](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol), with
the design goal of being much simpler.
Gemini pages are written in *gemtext*, a very simple markup language that
offers headers, hyperlinks, lists and little more - notably, there is no
inline formatting.

**Disclaimer**: I am not a networking expert, so I will keep this article
at a very basic level. Nonetheless I may end up writing wrong or inaccurate
things. If you know this stuff better than me and you spot a mistake, feel
free to [send me an email](mailto:sebastiano@tronto.net).

## Protocols: gemini:// and http://
In the context of computer networks, a *protocol* is a set of rules that
describes how two different machines should communicate to exchange data.
If you are viewing this page in a normal web browser, the address in your
address bar probably starts with `http://` (or `https://`, but let's pretend
they are the same thing). This means that your device is communicating with
the server where I have uploaded this page using the *Hypertext Transfer
Protocol*. Concretely, your browser has sent the server a message such as

```
GET /blog/index.html HTTP/1.1
Host: sebastiano.tronto.net
```

And the server has replied something like

```
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 1131
Content-Type: text/html
Date: Fri, 03 Jun 2022 14:34:22 GMT
Last-Modified: Sun, 29 May 2022 11:15:55 GMT
Server: OpenBSD httpd

<!doctype html>
<html lang="en">
<head>
	<title> Blog | Sebastiano Tronto </title>

(...Some more stuff...)

</html>
```

So there is some garbage that you don't care about (your browser does),
plus the actual content that you want to view. What exact garbage your 
browser and the server should exchange before one ships the actual content
to the other is exactly what the protocol defines. Calling it "garbage"
is a bit unfair, because there can be some useful information: for example,
when the page was last modified, so if your browser has already seen and
cached this page it does not need to download it again, but there could
be more stuff such as error messages or redirection paths.

In contrast, a gemini browser might send a request that looks like

```
gemini://tronto.net/blog/index.gmi
```

To which a gemini server would respond simply

```
20 text/gemini; 
# Blog

(...Some more stuff...)
```

Very briefly, this is how the two protocols work. You might be wondering how
exactly your browser is sending and receiving this information. Well, http
(and gemini) sit on top of other protocols which describe exactly this. These
other protocols in turn are on top of other protocols and... basically,
[it's protocols all the way down](https://en.wikipedia.org/wiki/Internet_protocol_suite).

(*If you are curious where I got the server responses from: the UNIX command
`curl` and the gemini browser [`gmni`](https://git.sr.ht/~sircmpwn/gmni)
have a `-i` option that allows to see the messages received from the server.*)

## The gemtext markup language

Web pages are usually written in the
[HTML](https://en.wikipedia.org/wiki/HTML) format. There are plenty of
resources to learn how HTML works, so I will not explain it here.
Very briefly,
using tag pairs such as `<h1></h1>`, `<p></p>` or `<a href="..."></a>`,
an html file tells your browser how to display its content. It may
also embed images, videos or even executable scripts.

Gemtext plays the same role for gemini pages, but it has (by design)
a much more restricted feature set. It's syntax is somewhat similar to
[Markdown](https://en.wikipedia.org/wiki/Markdown), another markup language.
For example, headings and (unordered) lists work in the same way:

```
# A title
## A second-level heading
There are only 3 levels of heading in gemtext
### This is the last level
Lists:
* one
* two
* three
```

There is however a fundamental difference in how lines are parsed: in gemtext,
newlines in the code are preserved. This sounds completely normal for anyone
used to modern word processors, but it is different from how HTML, Markdown
and LaTeX work, just to name a few. In practice, this means that in gemtext
you have to write your paragraphs as long lines, without inserting line breaks
unless you want the line to be broken at that specific point.
This may be annoying for people who use old-style line-based editors, such as
vi, but it makes parsing a gemtext file much simpler.

There are only three other things you can do in gemtext: links, block quotes
and preformatted text.

Links consist of a single line starting with `=>`, followed by a link and
(optionally) by the text you want to appear instead of the URL of the link.

```
=> gemini://tronto.net A link to my homepage
```

Blockquotes are simply lines starting with `>`:

```
> This is a quote
```

Finally, preformatted text is any text between two lines consisting of three
backticks. It is going to appear as it is when rendered, i.e. your browser
won't parse any gemtext syntax inside preformatted text.

````
```
This is preformatted text
It can be useful to display ASCII art, like this
 /\_/\
( o.o )
 > ^ <
=> This line will not be interpreted as a link
```
````

(*If you are reading this via gemini, the lines above are not properly
displayed.  I'll edit this page if I find a way to escape the triple backtick,
or fix the markdown-to-gemtext conversion*)

And that's it, you now know gemtext. There is no inline formatting, no
embedded media, no CSS - your browser will take care of the styling and
if you want to view a picture you can just download it and open it with
an external app.

## Gemini in practice

Gemini is basically a very stripped down version of the Internet. To me it
feels like some kind of very niche, underground web. Some *capsules* I like
browsing are [smol.pub](gemini://smol.pub) and
[midnight.pub](gemini://midnight.pub). I don't have an account there
yet, but I think I will make one at some point. I also check the
[Antenna feed aggregator](gemini://warmedal.se/~antenna) to discover new
stuff.

Basically, if you like the idea of a small and text-only version
of the internet, you should check out the gemini space.
The page [geminiquickst.art](http://geminiquickst.art) suggests some
browsers - I personally use gmnln, but it is more or less an interactive
curl, you probably won't like it.

## Conclusions

I think gemini is an interesting exercise of minimalism, which I like.
I am not a networking expert, so I don't know what the pros and cons of using
gemini:// rather than http(s):// are, but I quite like gemtext as a markup
language. I am not too fond of using long lines, but this is not
a deal-breaker. However, I still prefer making use of a few of the extra
features that html offers, such as inline formatting.

I will keep offering this website in gemtext via gemini://, but it will
stay html-first. This means that inline links will look a bit ugly in gemini
and, more annoyingly for the few gemini users, I am going to use
http(s) links even when a gemini counterpart is available.

*Update: as of August 2023, my website is still available on gemini,
but new blog posts are no longer mirrored there*

# Keeping my email sorted (the hard way)

I have recently made some changes to my email setup.  In this post I'll
explain the motivation behind these changes and what I did in practice.

## Self-hosting?

When I got my virtual machine up and running at
[openbsd.amsterdam](https://openbsd.amsterdam/) - the one where this
website is hosted - I originally planned to host my private email
server there too.  I knew this was probably a hard task, but you know,
everything is hard until you learn how to do it.

I wanted to do this for a couple of reasons. The main one was to use my
`@tronto.net` email address, but I also liked the idea of staying away
from large internet companies (my main email address was connected to my
Google account). Not that there is anything inherently wrong with using
services from this big companies, but I like the idea of not being too
dependent on them.

After reading
[a nice tutorial at poolp.org](https://poolp.org/posts/2019-09-14/setting-up-a-mail-server-with-opensmtpd-dovecot-and-rspamd/)
I was a bit discouraged. The guide was well-written, all the steps seemed
doable if taken one by one, and I was happy to have dug into this topic
because I learned a lot. However, an email server apparently consists of
a lot of moving pieces: an smtp server, spam filter, DNS, DKIM... it is
a lot to keep track of. Even assuming that I would be able to set this
thing up AND to keep in mind what each of these pieces does, as soon as a
problem of any kind arises - config-breaking updates? domain registration
expiring? me messing up with my VM and making it unreachable? - I knew I
had to be one to fix the mistake. And I cannot afford to be immediately
available whenever something bad happens. Sometimes I might just have a
full week were I don't have time to fiddle around with smtpd and whatnot,
and I can't afford being unreachable via email for a week.

## My old setup (until September 2022)

Having abandoned the idea of self-hosting, I looked for alternatives. I
figured that if my goals were just to use my own domain and stay away
from Google, I could sign up for a smaller email provider that offers
custom domains. It turns out there are a lot of them. After some careful
considerations I decided to go with [mailbox.org](https://mailbox.org). I
like their transparency and privacy focus and the fact that they are
based in the EU. I pay 3€ per month (the 1€ tier does not offer
custom domains) and I am happy with their service.

Setting up the server side was quite simle. Using custom domains
requires a tiny bit of work, but it was all well explained in the
[FAQs](https://kb.mailbox.org/en/private/custom-domains).

On my local machine I used (and still use) the amazing
[mblaze](https://github.com/leahneukirchen/mblaze), which is essentially
[MH](https://en.wikipedia.org/wiki/MH_Message_Handling_System)
for [Maildir](https://en.wikipedia.org/wiki/Maildir) folders.
In practice, mblaze is a set of commands to manage emails directly
from the command line, without using a graphical environment or a
[TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) like
[Mutt](https://en.wikipedia.org/wiki/Mutt_(email_client)).  This system
is incredibly flexible, check it out if you don't know it!

Being just a mail user agent, mblaze cannot retrieve or send
email.  These tasks can be accomplished by other small pieces of
software: I used [msmtp](https://marlam.de/msmtp) for sending
email and [mpop](https://marlam.de/mpop) for downloading it
from mailbox.org's server. As the name suggests, mpop uses the
[POP3](https://en.wikipedia.org/wiki/Post_Office_Protocol)
protocol instead of the more common
[IMAP](https://en.wikipedia.org/wiki/Internet_Message_Access_Protocol).
The main difference is that POP3 simply retrieves your email, while
IMAP keeps the server and client folders synchronized.  There are many
advantages and disadvantages to this choice, I won't go into detail on
them in this post.

As for my other devices, my local mailfolder is kept in sync with my
server using [syncthing](https://syncthing.net).  I also use an amail
client on my phone with IMAP, connected directly to the mail server.

## Nitpicking

Since I am subscribed to a couple of high-traffic mailing lists that
I read just for curiosity, it is necessary for me to have an easy way
to download and view regular emails separately from that coming from
mailing lists.

This was kinda easy to set up with mpop's filters, but my configuration
was a bit of a hack.  One disadvantage of this soution was that it
only solved the problem on my laptop(s). On my webmail and on my phone,
my inbox was a complete mess of mailing lists, newsletter and a few
important emails.

After thinking about it for a while I figured that an elegant solution
would be to set up alternative email addresses for receiving mailing
list emails, like `list@tronto.net`.  Then I would manage those different
mailboxes separately.

Setting the aliases up on mailbox.org was easy, but unfortunately all my
`@tronto.net` address used the same inbox, so I did not solve any problem
at all. I could add some sub-folders and set up filters so that incoming
mail gets sorted out, but the app on my phone could not read sub-folders
and mailbox did not allow top-level folders (or I could not find a way to
create them). Besides, tinkering with IMAP folders was not something
that I found particularly exciting.

But there was another solution...

## My current setup (since September 2022)

I decided to try and redirect the mailing list emails to my personal
server. Configuring OpenBSD's smtp to receive emails from one specific
outside source (my mailbox.org account) and sort them into some local
folders is order of magnitudes easier than setting up a full-fledged
email server. No problems with DKIM, no incoming spam, no nothing.

It took me a few hours to figure our how to do this, but in the
end it is just a matter of configuring a few filters on mailbox.org
and adding a couple of lines to `/etc/mail/stmp.conf`.

### mailbox.org filters

On my mailbox.org webmail I simply set up a filter to redirect any email
sent to `list@example.com` (a made-up name for the mailing list I am
subscribed to) to my private server. No copy of these emails is kept on
the server, so they don't clutter my normal (IMAP) inbox. I risk missing
a few of these emails if my server goes down, but it is a public mailing
list and I can always check the archives online.

I could not just send these emails to `something@tronto.net`, otherwise
they would simply be taken care of by mailbox - the MX records for my
domain point to their servers. But it turns out you can send mail to
a server using its IP address, as long as the server is configured to
accept such mail. So I set up the redirects to `list@[46.23.91.214]` -
where `46.23.91.214` is the IP address of my server.

### smtpd.conf

The second step is configuring smtpd, OpenBSD's default mail server
daemon, to deal with incoming email.

First of all we need to list the virtual user `list` in
`/etc/mail/aliases` so that any mail sent to it is interpreted as being
sent to my regular user.

```
# cat 'list: sebastiano' >> /etc/mail/aliases
```

Then we have to change the line `listen on lo0` to `listen on all`
in `/etc/smtp.conf`.

Then we need to add an `action` and a `match` lines to the same file:

```
# cat << EOF >> /etc/mail/smtpd.conf
> action "list" maildir "~/mail/list" alias <aliases>
> match from any for rcpt-to "list@[46.23.91.214]" action "list"
> EOF
```

And finally restart smtpd with `rcctl restart smtpd`.

This does the trick: now all email I receive from the `list@example.com`
mailing list is redirected by my mailbox account to my private server,
where smtpd takes care of sending it to the mail directory `~/mail/list`.

### No mpop needed

Once the mail is delivered to `~/mail/list`, I can get it from there
to my laptop in any way I like - for example using syncthing, like I
do for all my important files. In this way the mailing list emails are
regularly downloaded and kept in sync, and I don't need to use mpop to
retrieve them.

This is quite convenient, one less piece of software to keep track of!
In fact, I can do the same for all other email I receive. I just need
to set up the appropriate rules on mailbox: this time I want the mail
to be sent to `sebastiano@[46.23.91.214]` and *a copy to be kept on the
mailbox.org server*, so that I can easily access it from my phone's app as
well.  Then I add two slightly different lines to `/etc/mail/smtpd.conf`:

```
# cat << EOF >> /etc/mail/smtpd.conf
> action "seb" maildir "~/mail/inbox" user sebastiano
> match from any for rcpt-to "sebastiano@[46.23.91.214]" action "seb"
> EOF
```

And the new setup is ready!

### Sending email

I did not change the way I send email: I still use msmtp.

## Happy now?

Yes, this new setup works and I am always happy when things work.
Of course, one might make the case that things worked before as well...

I am happy that I could work my way around a basic smtpd configuration.
Besides being useful knowledge on its own, it may make a second attempt
at self-hosting my email less daunting. I don't know if I am ever going
to try that, though.

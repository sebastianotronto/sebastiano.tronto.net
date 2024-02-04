# Virtualization with vmm: brief history of a failure

I have been wanting to play around with OpenBSD's native virtualization
solution (vmm / vmd) for a while. It is what my VPS host
[openbsd.amsterdam](https://openbsd.amsterdam) uses, and I figured
having some minimal knowledge of how that works could come in handy
in case I mess something up with my virtual machine.

My goal was to set up a FreeBSD VM on an OpenBSD host, preferably
relying only official documentation - no DuckDuckGoing.

I am quite a noob when it comes to virtualization. I have used
VirtualBox ages ago, and a couple of months back I managed to spin
up a qemu VM mostly by copy-pasting commands from the internet.
All I know about vmm is that it consists of 3 pieces:
[vmm(4)](http://man.openbsd.org/vmm),
[vmd(8)](http://man.openbsd.org/vmd)
and [vmctl(8)](http://man.openbsd.org/vmctl).
After a quick scan of the man pages I figured out that vmm is the
device driver (whatever that means), vmd is the deamon and vmctl
the actual program I want to use to create, start up and shut down
the VM.

Keep in mind that this post *does not* contain instructions to be followed.
This is just the cronicle of my first attempt at using this tool.

## First steps

The first thing I did was heading to the
[FreeBSD website](https://www.freebsd.org)
and download an image of the recently released FreeBSD 14. I started
downloading the .iso image, but I soon realized that telling my VM
to boot from it would be yet one more thing to figure out.  FreeBSD
also offers
[VM images](https://download.FreeBSD.org/releases/VM-IMAGES/14.0-RELEASE/amd64/Latest)
in [qcow2](https://en.wikipedia.org/wiki/Qcow2) format, the one
used by vmm, so I got one of these instead.

Following the examples in vmctl(8), I tried:

```
$ vmctl start -d frr.qcow2 freebsd
vmctl: connect: /var/run/vmd.sock: No such file or directory
```

Mmh, ok. There is a missing (socket) file. I don't know how to create
it, and I don't think I should do it. After a little thinking I realize
I should probably start the deamon:

```
# rcctl -f start vmd
vmd(failed)
```

That's not good, and the error message does not say much. As an
aside, I have to point out that this is a constant annoyance I have
with OpenBSD: the tools are generally good, the documentation is
amazing, but oh god the feedback on error is terrible.

Anyways, after some more man page reading I realize I probably need
to install some firmware with fw_update(8) with

```
fw_update vmm
```

It was a bit of a guess game to figure out what driver I had to
install, but I got it on my second attempt (my first try was
`vmm-bios`).

The command indeed does something, so I try starting the deamon
again:

```
# rcctl -f start vmd
vmd(failed)
```

I took me relatively long to learn that `rcctl` has a `-d` option
to turn on some diagnostics (`-d` is for "debug", but why not a more
familiar `-v` for "verbose"?). So I try:

```
# rcctl -f start vmd
doing _rc_parse_conf
vmd_flags empty, using default ><
doing rc_check
vmd
doing rc_configtest
configuration OK
doing rc_start
doing _rc_wait_for_start
doing rc_check
doing _rc_rm_runfile
(failed)
```

That is a bit cryptic, but at least it's something.

## Walking in circles

At this point I stopped making progress. It looks like the output
above is just generic service-starting stuff, and it has nothing
to do with my specific problem.

I tried rebooting, but nothing changed. After reading the man pages
more carefully, I thought that maybe enabling the service to start
automatically at boot instead starting it manually could do something.
It would be weird if it worked, but it was worth a shot. So I enabled
it with

```
# rcctl enable vmd
```

And rebooted. But still:

```
vmd(failed)
```

I found out about yet another man page,
[vm.conf(5)](http://man.openbsd.org/vm.conf).
I read some of it, but I quickly convinced myself that my error was
not related to configuration. It looks like anything you can do
from vm.conf you can also do by providing the correct options and
arguments to vmctl.

As a last resort, I looked at
[intro(4)](http://man.openbsd.org/man4/amd64/intro.4),
but I did not find anything useful.

## The FAQ

I finally gave up and decided to read the
[official online FAQ](https://www.openbsd.org/faq/index.html).
I don't like relying on them, because it is not something I always
have access to - for example if I am travelling and don't have an
internet connection.

The [Virtualization section](https://www.openbsd.org/faq/faq16.html)
gave me an answer:

```
Prerequisites

A CPU with nested paging support is required to use vmm(4). Support can be
checked by looking at the processor feature flags: SLAT for AMD or EPT for
Intel. In some cases, virtualization capabilities must be manually enabled in
the system's BIOS. Be sure to run the fw_update(8) command after doing so to
get the required vmm-firmware package.

Processor compatibility can be checked with the following command:

$ dmesg | egrep '(VMX/EPT|SVM/RVI)'
```

And sure enough that command returns nothing on my machine. That is
is because I am doing this experiment on my
[Netbook](../2022-09-10-netbooks),
and its old
[Intel Atom N450 CPU](https://ark.intel.com/content/www/us/en/ark/products/42503/intel-atom-processor-n450-512k-cache-1-66-ghz.html)
does not support virtualization. Bummer.

## Conclusion

In the end, I was not able to set up my virtual machine, but that
was neither my fault nor OpenBSD's. At least I did not waste much
time with this - I did all of the above in little more than one
hour. I guess this is what they call "fail fast?"

status: (failed)

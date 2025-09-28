# Declarative package management with Alpine Linux

It has been almost two months since my last update, and it feels a
bit weird because I have done plenty of tinkering that would be a
good fit for this blog! But for one reason or another, I did not
feel like writing about any of this in the usual level of detail.

However, one of the last things I did is quite simple to explain, so here
is a short post about it.

## Alpine linux

A couple of days ago I decided to try out
[Alpine Linux](https://www.alpinelinux.org), a lightweight distro that
uses [musl libc](https://www.musl-libc.org/) instead of GNU libc and
[busybox](https://busybox.net) instead of GNU coreutils.

Alpine's package manager is called Alpine Package Keeper (APK, not to
be confused with Android Package, which also goes by APK). It is very
fast and simple to use, and it has an especially cool feature: the
list of all manually installed packages is kept in the plain text file
`/etc/apk/world`.  This file can be edited by hand, and running `apk fix`
will then add or remove packages to satisfy the list in the file. Neat!

## Declarative package management

Unfortunately, APK will also overwrite `/etc/apk/world` by removing
empty lines and sorting the packages in alphabetical order, one per
line. Moreover, there is no option to write comments in this file.
So one cannot really use it as a (commented) list of the packages they
want to keep installed.

At first I thought I could keep such a list in a separate file, and write
a script to parse this file, remove the comments, write the result to
`/etc/apk/world` and then run `apk fix`.

But then I thought it would be even better to merge the two, and here
is the result:

```
#!/bin/sh

# Make a backup copy of the previous /etc/apk/world
cp /etc/apk/world /etc/apk/world.backup

echo "

# Base system packages (installed by default)
alpine-base busybox-mdev-openrc doas grub-efi openssh openssl

# Firmware (installed by default, system-dependent)
linux-firmware-i915 linux-firmware-intel linux-firmware-mediatek linux-firmware-other
linux-firmware-rtl_bt linux-firmware-rtl_nic linux-firmware-xe linux-lts

# Documentation
docs mandoc-apropos

# Wifi and other hardware control
iwd openresolv pciutils bluez

# Audio
pulseaudio pulseaudio-bluez pulseaudio-alsa alsa-plugins-pulse pulseaudio-utils pulsemixer

# Core tools (non-X)
coreutils-fmt curl imagemagick ffmpeg tmux ghostscript ncurses shellcheck
kbd # For console keyboard configuration
syncthing fzf sfeed yt-dlp mblaze msmtp oath-toolkit

# Development tools
build-base git gdb valgrind clang20 python3 rust cargo hare
lowdown darkhttpd # Both used for updating my website
libx11-dev libxft-dev libxinerama-dev

# Xorg xorg-server
xinit eudev mesa-dri-gallium xf86-video-intel xf86-input-libinput xf86-input-synaptics
setxkbmap xsel xbanish xsetroot xwallpaper xev slock

# X applications
firefox libreoffice telegram-desktop vlc imv-x11
zathura-djvu zathura-pdf-mupdf zathura-ps
arandr

# Fonts, but like a gazillion of them
font-terminus font-noto font-noto-extra font-arabic-misc
font-misc-cyrillic font-mutt-misc font-screen-cyrillic
font-winitzki-cyrillic font-cronyx-cyrillic font-noto-arabic
font-noto-armenian font-noto-cherokee font-noto-devanagari
font-noto-ethiopic font-noto-georgian font-noto-hebrew font-noto-lao
font-noto-malayalam font-noto-tamil font-noto-thaana font-noto-thai

" | sed 's/#.*//' | grep -v '^[:space:]*$' > /etc/apk/world
apk fix
```

The bulk of the file is a
[here document](https://en.wikipedia.org/wiki/Here_document) with a long
list of all the packages I want installed - Alpine is really minimal! The
few lines of code above and below this list are there to make a backup a
copy of the old `/etc/apk/world`, filter out the comment from the new list
using [sed](../2023-12-03-sed) and [grep](../2023-08-20-grep),
copy the new list to `/etc/apk/world` and finally run `apk fix`.

Now when I want to add a new piece of software to my system
I edit this file and then run it as root.  A dead simple
way to do declarative package management - take that,
[Nix](https://en.wikipedia.org/wiki/Nix_(package_manager))!

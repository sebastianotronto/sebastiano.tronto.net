# Getting started with QT, without the nonsense

At work I have recently (yesterday) ended working on a big project and
I am now waiting for a new assignment. While I wait, I decided that I
should take some time to learn something that could be useful both at
work and for my personal projects.  After some thought, I settled on QT
development with C++.

Any tutorial on this topic tells you to start by downloading QT Creator,
an full-blown IDE, and set up a new project from there. In a few clicks
you'll have a couple of source code files and a CMakeLists.txt full of
[CMake](https://nl.wikipedia.org/wiki/CMake) magic. Ready to go!

But there is a problem. I don't like full-blown IDEs (although admittedly
QT Creator seems quite snappy), and I don't like being locked into specific
tools such as CMake. I tried to look online how to set up a QT project
without these, but I could not find anything, so I had to figure it out on
my own. And then I wrote this post so you don't have have to waste your
time like I did :)

You can find the source code for this tiny project
[here](https://git.tronto.net/minimal-qt) (or
[here](https://github.com/sebastianotronto/minimal-qt)) if you have bad
tase and prefer github over my [self-hosted](../2022-11-23-git-host/)
git instance. If you just want to try it out you can run, from the
project's main folder:

```
make && run
```

But keep reading if you want to understand how this works!

## Requirements

* A C++ compiler (tested with GCC 14.2.1 and Clang 19.1.7, both on Linux-x86_64)
* QT libraries and headers
* The QT development tools `moc` and `uic`

On Fedora Linux they are contained in the `qt6-qtbase-devel` package.
I have not tested this on other operating systems.

## Explanation

Following the most basic QT Creator template, there are 4 source code files:

* `main.cpp`: the main source file
* `mainwindow.h`: the header file for the main window of the application
* `mainwindow.cpp`: the C++ source for the main window
* `mainwindow.ui`: the UI file with an XML description of the main window

The compilation is done in 3 steps:

1. Pre-process `mainwindow.h` with `moc` to obtain `moc_mainwindow.cpp`
2. Compile `mainwindow.ui` with `uic` to obtain `ui_mainwindow.h`
3. Compile the C++ files, including `moc_mainwindow.cpp`

The `Makefile` implements these three steps.

The first two steps are straightforward: first you need to locate the
`moc` and `uic` commands. They are usually in the QT installation
folder - for example I have them in `/usr/lib64/qt/libexec`. Then run:

```
/usr/lib64/qt/libexec/moc mainwindow.h > moc_mainwindow.cpp
/usr/lib64/qt/libexex/uic mainwindow.ui > ui_mainwindow.h
```

These steps can be skipped if one prefers to write the `moc_` and `ui_`
files directly, removing the dependency on the two tools.

For the last step, one needs to include the header files and link with
the QT libraries.

On my system the header files are in `/usr/include/qt6`. This means I
need to add the option `-I /usr/include/qt6` to my `g++` command. This
project also requires headers contained in a subfolder of this,
so I will add a second `-I` option (see the full command below).

As for the shared libraries, in my case they are installed in a system
folder that is scanned by default by the linker, so I don't have to
specify the path.  We need the files `libQt6Widgets.so`, `libQt6Core.so`
and `libQt6Gui.so`, which we can include with
`-lQt6Widgets -lQt6Core -lQt6Gui`. If your linker does not find them,
locate them and include their folder with `-L /path/to/the/folder`.

So the command for step 3 becomes:

```
g++ main.cpp mainwindow.cpp moc_mainwindow.cpp \
	-I /usr/include/qt6 -I /usr/include/qt6/QtWidgets \
	-lQt6Widgets -lQt6Core -lQt6Gui
	-o run
```

And finally you can enjoy your new app:

```
./run
```

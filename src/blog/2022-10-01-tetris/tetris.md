# The man page reading club: tetris(6)

Sometimes you just need to relax and have some fun :-)

## Boredom

*"Phew, that was a long read!" you think as you reach the end of the
`sh(1)` manual page. After such an intense brain-workout you would
normally have a nice walk outside - but the Geiger counter on the wall
tells you that this might not be a good idea in this timeline. Your second
choice would be to have a beer and listen to some good music or watch a
movie, but none of these options is available in the bunker. It's almost
as if the nuclear winter is...  bad?*

*You try to think what else you can do to ease your boredom.
There's no internet, no books, no videogames... wait a minute!*

```
$ man man
```

*You scroll down until you see the list of available sections, and
you find the one you were looking for:*

```
	6         Games.
```

*Yes! You thought you saw this 
[some time ago](https://sebastiano.tronto.net/blog/2022-05-29-man),
but you had ignored it. You also remember that the `intro(1)` page
mentioned analogous intoductory pages for each section. So you type:*

```
$ man 6 intro
```

*And so you discover that the folder `/usr/games` contains dozens of
games and other fun little programs. These are already installed in your
system, no need to download files or insert CD roms.*

*There is so much choice, so many games you have never heard of.  But for
this time you decide to go with a classic.*

## tetris(6)

*Follow along at [man.openbsd.org](https://man.openbsd.org/OpenBSD-7.1/tetris)*

Before starting the game it is better to learn the rules, so let's type
`man tetris` first!

```
DESCRIPTION
     The tetris command runs a display-based game.  The object is to fit
     shapes together to form complete rows, which then vanish.  When the
     shapes fill up to the top, the game ends.
```

The default control keys are listed below:

```
       j        move left
       k        rotate 1/4 turn counterclockwise
       l        move right
       <space>  drop
       p        pause
       q        quit
```

Some of the options are quite straightforward: `-c` to play in "classic
mode", with a slightly different graphics and shapes that turn clockwise;
`-l` to specify a level; `-p` to show the next shape that will drop, in
exchange for a lower score; `-s` to print the highscores and exit. The
most interesting is `-k`:

```
     -k keys
             The default control keys can be changed using the -k option. The
             keys argument must have the six keys in order; remember to quote
             any space or tab characters from the shell.
```

The sections PLAY and SCORING explain the gameplay and the criteria for
assigning points. There is also an ENVIRONMENT section with a single line:

```
    LOGNAME               Name displayed in high score file.
```

This means that you can set that shell variable to have your score
saved in the `$HOME/.tetris.score` file under a different name -
this can be useful for example when lending your pc to someone else
to let them play.

## Having fun

*"Enough of this reading, let's just play!"*

*You decide to remap the keys to play with your left hand, and to use the
old nick name you used on online forums, when the internet still existed.
And why not trying the "classic" mode as well?*

```
$ LOGNAME=porkynator tetris -c -k 'asd pq'
```

*And you start playing the night away*

```
Score: 47              []                    []
                       []                    []
                       []                    []
                       []        []          []
                       []      [][]          []
                       []      []            []
                       []                    []
                       []                    []
                       []                    []
                       []                    []
                       []                    []
                       []                    []
                       []                    []
                       []                    []
                       []                    []
                       []                    []
                       []                  [][]
                       [][][]              [][]
                       [][][][]            [][]
                       [][][][]            [][]
                       [][][][][][][][][][][][]

a - left   s - rotate   d - right   <space> - drop   p - pause   q - quit
```

## Conclusions

This was a short and unimportant post meant to cool down after last month's
double post on the shell. I'll take it as an excuse to mention that `/usr/games`
[won't be in the default `$PATH`](https://undeadly.org/cgi?action=article;sid=20220810120423)
starting from OpenBSD 7.2. If you want to have a fun tetris session,
in the future you might have to specify the full path

```
$ /usr/games/tetris
```

or just update your `$PATH`.

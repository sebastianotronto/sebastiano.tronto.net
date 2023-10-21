# The man page reading club: sh(1) - part 2: commands and builtins

*This post is part of a [series](../../series)*

This is the second and last part of our exciting sh(1) manual page
read.  This time we are going to learn about *commands* and *builtins*.
In case you have missed it, check out the [first part](../2022-09-13-sh-1)
where we dealt with the shell's grammar.

I'll spare you the fan fiction this time - let's go straight to the
technical part!

As usual, you can follow along at
[man.openbsd.org](https://man.openbsd.org/OpenBSD-7.1/sh)

## Commands

The Commands section of the manual page starts like this:

```
     The shell first expands any words that are not variable assignments or
     redirections, with the first field being the command name and any
     successive fields arguments to that command.  It sets up redirections, if
     any, and then expands variable assignments, if any.  It then attempts to
     run the command.
```

The next few paragraphs describe how the name of a command is
interpreted.  There are two distinct cases: if the name contains
any slashes, it is considered as a path to a file; if it does not,
the shell tries to interpret it as a special builtin, as a shell
function, as a non-special builtin (the difference between these
two types of builtins will be explained later) or finally as the
name of an executable file (binary or script) to be looked for in
`$PATH`.

The meaning of this variable is explained in the `ENVIRONMENT`
section:

```
PATH    Pathname to a colon separated list of directories used to search for
        the location of executable files.  A pathname of `.' represents the
        current working directory.  The default value of PATH on OpenBSD is:

            /usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/bin
```

### Grouping commands

The manual page continues with explaining how to group commands
together to create more complex commands. There are five ways to
create a list of commands, and their syntax is always of the form

```
	command SEP command SEP ...
```

where `SEP` is one of the separators described below.

* *Sequential lists*: One or more commands separated by a semicolon `;`
  are exectuted in order one after the other.
* *Asynchronous lists*: One or more commands separated by an ampersand `&`
  are executed in parallel, each in a different subshell.
* *Pipelines*: Two or more commands separated by a pipe `|` are executed
  in order, using the output of each command as input for the next one.
  Together with I/O redirection, that we have seen last time, pipelines are
  one of the "killer features" of UNIX that makes its shell such a powerful
  language that it is still widely appreciated more than fifty years after
  its introduction.
* *AND lists*: Two or more commands separated by a double ampersand `&&`
  are executed in order, but a command is only run if the exit status of
  the previous command was zero.
* *OR lists*: Two or more commands separated by a double pipe `||`
  are executed in order, but a command is only run if the exit status of
  the previous command was different from zero.

The AND and OR lists can be combined by using a mix of `&&` and
`||`.  The two operators have the same precedence.

The exit status of a list of commands is equal to the exit status
of the last commands executed, except for asynchronous lists where
the exit status is always zero. For pipelines, the exit status can
be inverted by putting an exclamation mark `!` at the beginning of
the list.

Now that I think about it, I have mentioned the exit status of a
command a few times here and in the last episode, but I have never
explained what it is.  Basically, every command concludes its
execution by returning a number (exit status), which may be zero
to indicate a succesful execution or anything different from zero
to indicate a failure. This will become even more relevant soon.

Finally, a list of commands can be treated as a single command by
enclosing it in parentheses or in braces:

```
     Command lists, as described above, can be enclosed within `()' to have
     them executed in a subshell, or within `{}' to have them executed in the
     current environment:

	   (command ...)
	   { command ...; }

     Any redirections specified after the closing bracket apply to all
     commands within the brackets.  An operator such as `;' or a newline are
     needed to terminate a command list within curly braces.
```

### Flow control

Much like any imperative programming language, the shell has some
constructs that allow controlling the flow of the execution. The
*for loop* is perhaps the most peculiar one. Its format is:

```
	for name [in [word ...]]
	do
		command
		...
	done
```

The commands are executed once for every item in the expansion of
`[word ...]` and every time the value of the variable `name` is set
to one of these items.  (check [the last episode](../2022-09-13-sh-1)
for an explanation of text expansion).

*While loops* are perhaps more familiar to regular programmers: a
command called *condition* is run, and if its exit code is zero the
body of the while loop is executed, and so on. The format is

```
	while condition
	do
		command
		...
	done
```

There is an opposite construct with `until` in place of `while`
which executes the body as long as `condition` exits with non-zero
status.

A *case conditional* can be used to run commands depending on
something matching a pattern. The format is

```
	case word in
		(pattern [| pattern ...]) command;;
		...
	esac
```

Where `pattern` can be expressed using the usual filename globbing
syntax that we briefly covered last time - see
[glob(7)](https://man.openbsd.org/OpenBSD-7.1/glob.7) for more
details.

As an example, this short code snippet tries to determine the type
of the file given as first argument from its extension:

```
case "$1" in
	(*.txt) echo "Text file";;
	(*.wav | *.mp3 | *.ogg) echo "Music file";;
	(*) echo "Something else";;
esac
```

Note that double quotes around the `$1` to avoid file names with
spaces being considered as multiple words.

The *if conditional* is also a classic construct that programmers
are very familiar with. Its general format is

```
	if conditional
	then
		command
		...
	elif conditional
	then
		command
		...
	else
		command
		...
	fi
```

Like for the `while` construct, `conditional` is a command that is
run and its exit status is evaluated. `elif` is just short for
"else, if...".

Finally, the shell also has functions, that are basically groups
of commands that can be given a name and executed when using that
name as a command. Their syntax may be simpler than you expect:

```
	function() command-list
```

When defining functions it is common to write `command-list` in the
`{ command ; command ; ... ; }` format. Replacing the semicolons
with newlines we get the more familiar-looking structure

```
	function() {
		command
		command
		...
	}
```

## Builtins

The builtins are listed in alphabetic order in the manual page,
which is very convenient when consulting it for reference, but it
is not the best choice for a top-to-bottom read. So I'll shuffle
them around and divide them into a few groups. I'll skip some stuff,
but I'll try to cover what is important for regular use.

But first, as promised at the beginning of the previous section,
we need to explain the difference between "special" and regular
builtins.

```
     A number of built-ins are special in that a syntax error can cause a
     running shell to abort, and, after the built-in completes, variable
     assignments remain in the current environment.  The following built-ins
     are special: ., :, break, continue, eval, exec, exit, export, readonly,
     return, set, shift, times, trap, and unset.
```

### More programming features

As we have seen, the shell language includes some classical programming
constructs, like `if` and `while`. There are more builtins that can be
helpful these constructs: for example `true` and `false` are builtins
that do nothing and return a zero and a non-zero value respectively,
thus acting as sort of "boolean variables".

The builtins `break` and `continue`, used inside a loop of any kind,
behave exactly as in C.  The builtin `return` is used to exit the current
function. An exit code may be specified as a parameter, to indicate
success (0) or failure (any other number).

### Variables

The builtin `read` can be used to get input from the user - or
indeed from anywhere else, thanks to redirection:

```
read [-r] name ...
	Read a line from standard input.  The line is split into fields, with
	each field assigned to a variable, name, in turn (first field
	assigned to first variable, and so on).  If there are more fields
	than variables, the last variable will contain all the remaining
	fields.  If there are more variables than fields, the remaining
	variables are set to empty strings.  A backslash in the input line
	causes the shell to prompt for further input.

	The options to the read command are as follows:

	   -r	    Ignore backslash sequences.
```

As an example of reading from something other than standard input,
this short script takes a filename as an argument and prints each
line of the file preceded by its line number:

```
i=0
while read line
do
	i=$((i+1))
	echo $i: $line
done < $1
```

Notice that the redirector `< $1` is placed at the end of the `while`
commend, after then closing `done`.

The builtins `export` and `readonly` deal with permissions: the
first is used to make a variable visible to all subsequently ran
commands (by default it is not), while the latter is used to make
a variable unchangeable. The syntax is the same for both:

```
	command [-p] name[=value]
```

If `=value` is given, the value is assigned to the variable before
changing the permissions. The option `-p` is used to list out all
the variables that are currently exported or set as read-only.

### Running commands

If you want to run the commands contained in `file`, you can do so
by using `. file` (the single dot is a builtin). For example you
can list some commands that you want to run at the beginning of
each shell session (e.g. aliases, see the next section) and run
them with just one command.  Many other shells, such as ksh, run
certain files like `.profile` at startup, but sh does not.

If the commands you want to run are saved in variables or other
parameters you can use `eval`. For example, the following script
takes a command and its arguments as parameters, runs them and
returns a different message depending on the exit code:

```
if eval $@
then 
	echo "The command $@ ran happily"
else
	echo "Oh no! Something went wrong!"
fi
```

### Aliases

Aliases provide a nice shortcut sometimes, for example for shortening
a long command name or for adding a certain set of options by
default.

Using `alias name=value` makes it so every time `name` is read by
the shell as a command (i.e. not when it is an argument) it is
replaced by `value`. For example using `alias off='shutdown -p now'`
can be used to easily call the `shutdown` command with the common
option `-p now` - check out [an older blog entry](../2022-07-07-shutdown)
to learn about this surprisingly feature-rich command!

Using just `alias name` tells you the value of the corresponding alias,
if it is set. Using `alias` with no argument returns a list of all
currently set aliases.  Contrary to variables, aliases are visible in
every subshell.

Finally, `unalias name` can be used to unset the corresponding
alias; `unalias -a` unsets all currently set aliases.

### Moving around directories

Next (a meaningless word, since we are going in our own completely
arbitrary order) we have `cd` and `pwd`, which can be used to move around
in the directory tree.

`pwd` simply prints the current path - it is short for "Print Working
Directory". The working directory is where files are looked for by
the shell, for example when used as arguments for commands. If a
file is not in the current working directory, its full path has to
be specified in order to refer to it.

The working directory can be changed with `cd path/to/new/directory`.
If the path is not specified, it defaults to `$HOME`, the home
directory of the current user. The path can also be a single dash
`-`, meaning "return to the previous working directory". Finally,
if the path does not start with a slash and is not found relatively
to the current working directory, the variable `CDPATH`, which
should contain a colon-separated list of directories, is read to
try and find the new directory starting from there.

### Jobs

The builtins `jobs`, `kill`, `bg` and `fg` can be used to manage multiple
jobs running in the same shell. For example you can can run a command in
the background with `command &`, and later kill it with `kill [id]` or
bring it to the foreground with `fg [id]` (the `id` of the command will
be printed by the shell when you run `command &`).

I wanted to write something more about this, but I found the man
page for sh a bit lacking. I had to rely on other resources, such
as the manual page of [ksh(1)](https://man.openbsd.org/OpenBSD-7.1/ksh).
I think I'll postpone *job control* to another entry. Stay tuned!

*Update: [here](../2023-02-25-job-control) is the post on job control.*

### And finally...

```
exit [n]
    Exit the shell with exit status n, or that of the last command executed.
```

## Conclusion

I have skipped a few sections of the man page and many of the
builtins, but I am happy with the result and I think we can end it
here. After all, if I did not make any selection at all for these
"reading club" entries, you could just read the manual page yourself,
so what would the point be?

I am not sure what I am going to cover in the next episode. On the one
hand I should alternate between shorter pages and longer ones, mainly
to avoid burning out by taking on too many huge projects. But on the
other hand long pages are often more interesting.

Anyway, I hope you enjoyed this long double-post and that you may have
learnt something new. See you next time!

*Next in the series: [tetris(6)](../2022-10-01-tetris)*

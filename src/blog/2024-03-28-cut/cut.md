# UNIX text filters, part 2.4 of 3: cut

*This post is part of a [series](../../series)*

Have you ever had to extract a bunch of data from a
[CSV](https://en.wikipedia.org/wiki/Comma-separated_values) file?
CSV is a common file format where multiple values are stored
in each line of a plain text file, separated by a comma or some
other separator.
In most cases it is quite a simple file format to deal with, unless
you want to write a generic parser that has to take into account
all the special cases. But let's say you just want to write a quick
and dirty shell script to read some values out of a single file.
With `cut` you can get the job done pretty quickly!

## cut

Getting straight to the point, if you want to print columns 1, 3
and 4 of each line of `myfile.csv` you can use:

```
$ cut -f 1,3,4 -d , myfile.csv
```

Let's break this down.

## Fields, characters and bytes

The `-f` option tells `cut` that you want to read lines field-by-field,
where fields are are separated by the argument to the `-d` option.
In our example the separator is a comma, but you can use any
character.  If unspecified, the separator defaults to a TAB.

Instead of `-f` you could use `-c` (character) or `-b` (byte). If
you pick one of these, the separator is not to be specified, and
instead of field-by-field the rows are read character-by-character
or byte-by-byte. The difference between a byte and a character
depends on your
[locale](https://en.wikipedia.org/wiki/Locale_(computer_software)),
more specifically on the value of the environment variable `LC_CTYPE`.

## Picking columns

Columns are 1-based, hence the argument `1,3,4` gets, surprise
surprise, the first, third and fourth columns of each line. The
order you write the column indices does not matter: if you write
`3,4,1` you still get the columns in the order they appear in the
original file. If you repeat some indices, e.g. `1,3,4,1`, the
repeated column is printed only once.

You can also use ranges: for example `1,2,5-10` will print the first
column, the second, and all the ones from the fifth to the tenth;
as another example, `-3` will print the first 3 columns - unbounded
ranges are interpreted as "from the start" and "until the end".

## Examples

Let see some examples!

### Simple csv parsing

Let's say `myfile.csv` is the following:

```
2024-01-13,-,4.50,out
2024-02-04,groceries,52.42,out
2024-02-20,reimbursement,89.99,in
2024-03-10,stuff,1.01,out
```

Then running the following command command:

```
$ cut -f 3,4 -d , myfile.csv
```

will result in:

```
4.50,out
52.42,out
89.99,in
1.01,out
```

### Fixed-width table

Say you have a table like this in `table.txt`:

```
|   WCA ID   |  Type  | Result | Days |
---------------------------------------
| 1982THAI01 | Single |  22.95 | 7749 |
| 2014CZAP01 | Single |   0.49 | 2443 |
| 2011TRON02 | Single |     16 | 1747 |
| 2015GORN01 | Single |   0.91 | 1673 |
| 2015DUYU01 | Single |   3.47 | 1660 |
| 2009ZEMD01 | Single |   6.88 | 1617 |
```

and you want to print out only the first and last columns. These
columns are from character 2 to 13 and 33 to 38 respectively, or
1-14 and 32-29 if you include the borders. So you can select them
with the `-b` or `-c` option (they are equivalent in this case)
like this:

```
$ cut -c 1-13,32-39 table.txt
```

and you will get:

```
|   WCA ID   | Days |
---------------------
| 1982THAI01 | 7749 |
| 2014CZAP01 | 2443 |
| 2011TRON02 | 1747 |
| 2015GORN01 | 1673 |
| 2015DUYU01 | 1660 |
| 2009ZEMD01 | 1617 |
```

Since the ranges start at 1 and end at the last index, the following
command would produce the same result:

```
$ cut -c -13,32- table.txt
```

## Conclusion

I have not used `cut` much until today, the main reason being that
the rare times I needed to parse a csv file I usually had to do
something more complicated with the data than just printing it out.
For this reason I have always relied on more complete languages,
like C or Python, rather than shell scripting. But `cut` is definitely
a convenient tool to be familiar with, given how simple it is!

*Next in the series: [expand and unexpand](../2024-04-07-expand-unexpand)*

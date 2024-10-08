# How to write a Python module in C

Something I may want to do in the near future is making a tool /
library I am developing in C available in Python. I know it is
possible, but I have never done before, so yesterday I wrote
[my first Python module in C](https://git.tronto.net/python-c),
just to see how hard it is.

The answer is: it's easy, but the documentation is not great. The
[official guide](https://docs.python.org/3/extending/extending.html)
is quite lengthy, but somehow it does not even explain how to build
the damn thing! Don't get me wrong, I am a fan of the "theory first"
approach, but at some point I would expect a code snippet and a
command that I can just copy-paste on my terminal and see everything
work. Nope!

So here is my step-by-step tutorial. You can find all the code in
[my git repository](https://git.tronto.net/python-c).

## 1. Write your C library

Well I guess this is actually step zero, but today we are 1-based.

My beautiful library consists of only one source file `sum.c`:

```
int sum(int a, int b) { return a+b; }
```

and one header file `sum.h`:

```
int sum(int, int);
```

## 2. The adapter code

As you may expect, you need some kind of glue code between the raw
C library and the Python interpreter. This is largely boilerplate.
I put mine in a file called `sum_module.c`.

First you include `Python.h` and your library header:

```
#define PY_SSIZE_T_CLEAN
#include <Python.h>

#include "sum.h"
```

(I am not sure what the `PY_SSIZE_T_CLEAN` macro does, but the official
tutorial suggets defining it, so I have kept it there.)

Then for each of your library's function you need a corresponding
wrapper that takes Python objects, converts them to C objects, calls
the functions and converts the results back:

```
static PyObject *csum(PyObject *self, PyObject *args) {
	int a, b, result;

	if (!PyArg_ParseTuple(args, "ii", &a, &b))
		return NULL;

	result = sum(a, b);
	return PyLong_FromLong(result);
}
```

The `PyArg_ParseTuple()` function looks a bit magical. It is a
variadic function that takes the Python objects contained in `args`
and converts them following the given pattern - in this case "ii" for
two integers.

Then we need to map the wrapper functions to their python name. Here
I chose to call my function `sum_from_c`:

```
static PyMethodDef SumMethods[] = {
	{ "sum_from_c", csum, METH_VARARGS, "Sum two integers." },
	{ NULL, NULL, 0, NULL }
};
```

Finally, we just need some more boilerplate for creating the module:

```
static struct PyModuleDef summodule = {
	PyModuleDef_HEAD_INIT, "sum", NULL, -1, SumMethods
};

PyMODINIT_FUNC PyInit_sum_module(void) {
	return PyModule_Create(&summodule);
}
```

And we are ready to build! Kind of...

## 3. Install the Python development packages

To build the code above you need the `Python.h` header. Depending
on your system, this may be included in the default Python installation
or in a separate package. For example in Void Linux I needed to
install the `pytnon3-devel` package.

Anyway, once you have installed the correct package, you can check
where this library header file is with

```
$ python3-config --includes
```

This command will return a string like `-I/usr/include/python3.12`.
Keep it in mind for the next step!

## 4. Build the damn thing!

First, build the C library code:

```
cc -c -o sum.o sum.c
```

Here `-c` tells the compiler to skip the
[linking](https://en.wikipedia.org/wiki/Linker_(computing)) step -
otherwise it would complain about a missing `main()` function.  The
`cc` command should be, on any UNIX system, a link to either `gcc`
or some other C compiler. You can use `gcc` instead, if you prefer.

Then we need to build the adapter code to create the actual module:

```
$ cc -shared -I/usr/include/python3.12 -o sum_module.so sum.o sum_module.c
```

Here the `-shared` option tells the compiler to build a
[shared object](https://en.wikipedia.org/wiki/Shared_library),
the equivalent of a DLL in Windows. This is a compiled library than
can be dynamically loaded into a running program.

## 5. Import and run

And finally, you can open the Python REPL and run your code. From the same
directory where the `sum_module.so` file is:

```
>>> import sum_module
>>> sum_module.sum_from_c(23, 19)
42
```

Enjoy!

## 6. All the rest

There are still a couple of things I need to check before I can
repeat these steps with a more complex library. Namely, I need
convert more complex data types from Python to C, for example some
function pointers that I am using for
[callback](../2024-06-20-callback-log).  I'll check again the
official documentation when I get to that point, but for now I am
happy that this simple example works!

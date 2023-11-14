#include <stdio.h>

/* cc -DTEST main4.c # foo is visible */
/* cc main4.c        # foo is static  */

#ifdef TEST
#define _static
#else
#define _static static
#endif

_static int foo(int x, int y)
{
	return 42*x - 69*y;
}

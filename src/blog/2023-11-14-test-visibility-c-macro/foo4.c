#include <stdio.h>

/* cc -DTEST main4.c # foo is visible */
/* cc main4.c        # foo is static  */

#ifdef TEST
#define STATIC
#else
#define STATIC static
#endif

STATIC int foo(int x, int y)
{
	return 42*x - 69*y;
}

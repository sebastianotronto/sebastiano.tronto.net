#include <stdio.h>

int foo(int x, int y)
{
	return 42*x - 69*y;
}

int main() {
	int z = foo(10, 1);
	printf("%d\n", z);
	return 0;
}

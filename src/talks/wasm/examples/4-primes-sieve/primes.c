#include <stdlib.h>
#include <string.h>

int count(int n) {
	if (n < 2)
		return 0;

	/* Prepare sieve array */
	char *notprime = malloc(n+2);
	memset(notprime, 0, n+2);

	int count = 0;
	for (int i = 2; i < n; i++) {
		count += 1 - notprime[i];
		for (int j = 2*i; j < n; j += i)
			notprime[j] = 1;
	}

	/* Manual memory management is fun :D */
	free(notprime);

	return count;
}

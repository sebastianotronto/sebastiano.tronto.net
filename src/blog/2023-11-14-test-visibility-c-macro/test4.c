#include <stdio.h>

int foo(int, int);

int main() {
	int result = foo(1, 1);

	if (result == -27) {
		fprintf(stderr, "Test passed\n");
		return 0;
	} else {
		fprintf(stderr, "Test failed: expected -27, got %d\n", result);
		return 1;
	}
}

#if 0

bin="$(mktemp)"
cc -o "$bin" "$(realpath $0)"
"$bin"

exit 0
#endif

#include <stdio.h>

int main() {
	printf("Hello, world!\n");
	return 0;
}

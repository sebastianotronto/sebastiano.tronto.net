int is_prime(int n) {
	if (n < 2)
		return 0;
	for (int i = 2; i*i <= n; i++)
		if (n % i == 0)
			return 0;
	return 1;
}

int count(int n) {
	int count = 0;
	for (int i = 0; i < n; i++)
		count += is_prime(i);
	return count;
}

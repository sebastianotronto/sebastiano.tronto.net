import Primes from "./primes.mjs";

var primes = await Primes();

var input = document.getElementById("input");
var wasm_button = document.getElementById("wasmButton");
var js_button = document.getElementById("jsButton");
var resultText = document.getElementById("resultText");

var count_wasm = (n) => primes._count(n);

var is_prime = (n) => {
	if (n < 2)
		return false;
	for (var i = 2; i * i <= n; i++)
		if (n % i == 0)
			return false;
	return true;
}

var count_js = (n) => {
	var count = 0;
	for (var i = 0; i < n; i++)
		count += is_prime(i);
	return count;
}

var timerun = (count, tag) => {
	var n = Number(input.value);
	var msg = "Counting primes less than " + n + " with " + tag;
	console.time(msg);
	var c = count(n);
	console.timeEnd(msg);
	resultText.innerText = "There are " + c + " primes less than " + n;
}

wasm_button.addEventListener("click", () => timerun(count_wasm, "WASM"));
js_button.addEventListener("click", () => timerun(count_js, "JS"));

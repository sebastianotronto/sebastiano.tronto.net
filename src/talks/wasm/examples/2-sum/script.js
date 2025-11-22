import SumLibrary from "./sum_library.mjs";

var sumLibraryInstance = await SumLibrary();

var aInput = document.getElementById("aInput");
var bInput = document.getElementById("bInput");
var button = document.getElementById("goButton");
var resultText = document.getElementById("resultText");

button.addEventListener("click", () => {
	var a = Number(aInput.value);
	var b = Number(bInput.value);
	resultText.innerText = sumLibraryInstance._sum(a, b);
});

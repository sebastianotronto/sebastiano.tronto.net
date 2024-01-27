#!/bin/sh

invert() {
	# To invert an alg, replace R2 with RR, B' with B3 and then BBB
	# and similar. Then reverse the string and triple every letter.
	# It's a ugly hack, but it works.
	alg="$(echo "$1" | tr -d ' ' | tr \' 3)"
	echo "$alg" | sed -E 's/(.)(3)/\1\1\1/g' | \
		sed -E 's/(.)(2)/\1\1/g' | sed 's/./&&&/g' | rev
}

gen() {
	[ -e "trigger_$1.png" ] || cubeviz trigger "$1" > /dev/null 2>&1
}

printitem() {
	alg="$1"
	if [ -n "$alg" ]; then
		inv="$(invert "$alg")"
		echo "Working on alg $alg with inverse $inv" 1>&2
		gen "$inv"
		printf '<td style="font-size:16pt; text-align:center" '
		printf 'width="20%%">%s</td>\n' "$alg"
		printf '<td><a href="trigger_%s.png">\n' "$inv"
		printf '<img src="trigger_%s.png" ' "$inv"
		printf 'style="height:100px"></a></td>\n'
	else
		printf '<td width="20%%"><td width="30%%">\n'
	fi
}

maketable() {
	alg1="$(echo "$1" | sed 's/;.*$//' | tr -d '!')"
	alg2="$(echo "$1" | sed 's/.*;//')"
	printf '<table><tr>\n'
	printitem "$alg1"
	printitem "$alg2"
	printf '</tr></table>\n'
}

while read -r line; do
	algs="$(echo "$line" | grep '^!')"
	if [ -z "$algs" ]; then
		echo "$line"
	else
		maketable "$line"
	fi
done

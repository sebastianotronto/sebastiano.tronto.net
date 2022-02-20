#!/bin/sh

recursivebuild() {
	local destdir=$(echo $1 | sed 's|^src|http|')
	mkdir -p "$destdir"
	for file in $(ls $1); do
		if [ -d "$1/$file" ]; then
			mkdir -p "$destdir/$file"
			recursivebuild "$1/$file"
		else
			extension=$(echo "$file" | sed 's/.*\.//')
			if [ "$extension" = "md" ]; then
				sed "s/TITLE/$(grep '^\# ' < "$1/$file" \
					| sed 's/^\# //')/" < top.html \
					> "$destdir/index.html"
				lowdown "$1/$file" >> "$destdir/index.html"
				cat bottom.html >> "$destdir/index.html"
			elif [ "$extension" = "html" ]; then
				cat top.html "$1/$file" bottom.html \
					| sed "s/TITLE/$(grep '<!--TITLE: ' <\
							"$1/$file" \
						| sed 's/^<!--TITLE: //' \
						| sed 's/-->$//')/" \
					> "$destdir/index.html"
			else
				cp "$1/$file" "$destdir/$file"
			fi
		fi
	done
}

recursivebuild src

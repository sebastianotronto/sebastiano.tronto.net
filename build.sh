#!/bin/sh

recursivebuild() {
	local destdir=$(echo $1 | sed 's|^src|http|')
	local destdir_gmi=$(echo $1 | sed 's|^src|gemini|')
	mkdir -p "$destdir"
	mkdir -p "$destdir_gmi"
	for file in $(ls $1); do
		if [ -d "$1/$file" ]; then
			mkdir -p "$destdir/$file"
			mkdir -p "$destdir_gmi/$file"
			recursivebuild "$1/$file"
		else
			extension=$(echo "$file" | sed 's/.*\.//')
			if [ "$extension" = "md" ]; then
				sed "s/TITLE/$(grep '^\# ' < "$1/$file" \
					| sed 's/^\# //')/" < top.html \
					> "$destdir/index.html"
				lowdown "$1/$file" >> "$destdir/index.html"
				cat bottom.html >> "$destdir/index.html"

				# TODO: the following lines contain a dirty fix
				# to deal with a bug in lowdown. Remove all the
				# sed lines when fixed.
				lowdown -Tgemini --gemini-link-roman \
					"$1/$file" \
					| sed '/```./i```' \
					| sed '/```./ s/```//' \
					> "$destdir_gmi/index.gmi"
				cat bottom.gmi >> "$destdir_gmi/index.gmi"
			elif [ "$extension" = "html" ]; then
				cat top.html "$1/$file" bottom.html \
					| sed "s/TITLE/$(grep '<!--TITLE: ' <\
							"$1/$file" \
						| sed 's/^<!--TITLE: //' \
						| sed 's/-->$//')/" \
					> "$destdir/index.html"
			elif [ "$extension" = "gmi" ]; then
				cat "$1/$file" bottom.gmi > \
					"$destdir_gmi/index.gmi"
			else
				cp "$1/$file" "$destdir/$file"
				cp "$1/$file" "$destdir_gmi/$file"
			fi
		fi
	done
}

makeblog() {
	bf=src/blog/blog.md
	ff=src/blog/feed.xml

	printf "# Blog\n\n[RSS Feed](feed.xml)\n\n" > $bf
	cp feed-top.xml $ff

	for i in $(ls src/blog | sort -r); do
		if [ -d src/blog/$i ]; then
			f="src/blog/$i/*.md"
			d=$(echo $i | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
			t=$(head -n 1 $f | sed 's/# //')
			echo "* $d [$t]($i)" >> $bf

			echo "<item>" >> $ff
			echo "<title>$t</title>" >> $ff
			echo "<link>https://sebastiano.tronto.net/blog/$i</link>" >> $ff
			echo "<description>$t</description>" >> $ff
			echo "<pubDate>$d</pubDate>" >> $ff
			echo "</item>" >> $ff
			echo "" >> $ff
		fi
	done

	echo "" >> $ff
	echo "</channel>" >> $ff
	echo "</rss>" >> $ff
}

gemblog() {
	bg=gemini/blog/index.gmi

	printf "# Blog\n\n=> feed.xml RSS Feed\n\n" > $bg
	for i in $(ls src/blog | sort -r); do
		if [ -d src/blog/$i ]; then
			d=$(echo $i | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
			t=$(head -n 1 src/blog/$i/*.md | sed 's/# //')
			echo "=> $i $d $t" >> $bg
		fi
	done
	echo "" >> $bg
	cat bottom.gmi >> $bg
}

makeblog
recursivebuild src
gemblog

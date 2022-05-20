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

makeblog() {
	bf=src/blog/blog.md
	ff=src/blog/feed.xml

	printf "# Blog\n\n[RSS Feed](feed.xml)\n\n" > $bf
	cp feed-top.xml $ff

	for i in $(ls src/blog | sort -r); do
		if [ -d src/blog/$i ]; then
			f="src/blog/$i/*.md"
			d=$(grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' $f)
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

makeblog
recursivebuild src

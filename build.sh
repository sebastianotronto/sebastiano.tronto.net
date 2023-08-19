#!/bin/sh

recursivebuild() {
	local destdir=$(echo $1 | sed 's|^src|http|')
	mkdir -p "$destdir"
	for file in $(ls $1); do
		if [ -d "$1/$file" ]; then
			mkdir -p "$destdir/$file"
			recursivebuild "$1/$file"
		else
			copyfile "$1/$file" "$destdir"
		fi
	done
}

copyfile() {
	file=$1
	dest=$2
	ind=$dest/index.html
	extension=$(echo "$file" | sed 's/.*\.//')
	case "$extension" in
	md)
		t="$(markdowntitle $file)"
		sed "s/TITLE/$t/" < top.html > "$ind"
		lowdown "$file" >> "$ind"
		cat bottom.html >> "$ind"
		;;
	html)
		t="$(htmltitle $file)"
		cat top.html "$file" bottom.html | sed "s/TITLE/$t/" > "$ind"
		;;
	*)
		cp "$file" "$dest/$(basename $file)"
	esac
}

markdowntitle() {
	grep '^# ' $1 | head -n 1 | sed 's/^# //'
}

htmltitle() {
	grep '<!--TITLE: ' "$1" | sed 's/^<!--TITLE: //' | sed 's/-->$//'
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

			thisyear=$(echo $d | sed 's/-.*//')
			if [ "$thisyear" != "$lastyear" ]; then
				printf "\n## $thisyear\n\n" >> $bf
				lastyear=$thisyear
			fi

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

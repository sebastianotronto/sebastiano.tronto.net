#!/bin/sh

recursivebuild() {
	local destdir=$(echo "$1" | sed 's|^src|http|')
	mkdir -p "$destdir"
	for file in "$1"/*; do
		if [ -d "$file" ]; then
			mkdir -p "$destdir/$(basename "$file")"
			recursivebuild "$file"
		else
			copyfile "$file" "$destdir"
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
		t="$(markdowntitle "$file")"
		sed "s/TITLE/$t/" < top.html > "$ind"
		lowdown "$file" >> "$ind"
		cat bottom.html >> "$ind"
		;;
	html)
		t="$(htmltitle "$file")"
		cat top.html "$file" bottom.html | sed "s/TITLE/$t/" > "$ind"
		;;
	*)
		cp "$file" "$dest/$(basename "$file")"
	esac
}

markdowntitle() {
	grep '^# ' "$1" | head -n 1 | sed 's/^# //'
}

htmltitle() {
	grep '<!--TITLE: ' "$1" | sed 's/^<!--TITLE: //' | sed 's/-->$//'
}

makeblogindexandfeed() {
	mkdir -p http/blog
	bf=http/blog/index.html
	ff=http/blog/feed.xml

	sed "s/TITLE/Blog/" < top.html > "$bf"
	{ echo '<h1 id="blog">Blog</h1>';
	  echo '<table id="blog">';
	  echo '<a href="../series">Blog series</a> - ';
	  echo '<a href="feed.xml">RSS feed</a>'; } >> "$bf"

	cp feed-top.xml "$ff"

	for i in $(ls src/blog | sort -r); do
		[ -d "src/blog/$i" ] || continue

		f="src/blog/$i/*.md"
		d="$(echo "$i" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')"
		t="$(head -n 1 $f | sed 's/# //')"

		thisyear="$(echo "$d" | sed 's/-.*//')"
		if [ "$thisyear" != "$lastyear" ]; then
			echo "<tr><td><h2>$thisyear</h2></td></tr>" >> "$bf"
			lastyear=$thisyear
		fi

		{ echo "<tr><td>$d</td>";
		  echo "<td><a href=\"$i\">$t</a></td></tr>"; } >> "$bf"

		{ echo "<item>";
		  echo "<title>$t</title>";
		  echo "<link>https://sebastiano.tronto.net/blog/$i</link>";
		  echo "<description>$t</description>";
		  echo "<pubDate>$d</pubDate>";
		  echo "</item>";
		  echo ""; } >> $ff
	done

	echo '</table>' >> "$bf"
	cat bottom.html >> "$bf"

	{ echo ""; echo "</channel>"; echo "</rss>"; } >> "$ff"
}

makeblogindexandfeed
recursivebuild src

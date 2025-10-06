#!/bin/sh

basedir="$(pwd)"

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

mdpreprocess() {
	file="$1"
	if [ "$(echo "$file" | sed 's/.*\.//')" = "m4" ]; then
		printf 'm4_include(macros.m4)m4_dnl\n%s\n' "$(cat "$file")" | \
			m4 -P -I "$basedir/utils"
	else
		cat "$file"
	fi
}

copyfile() {
	file=$1
	dest=$2
	ind=$dest/index.html
	extension=$(echo "$file" | sed 's/.*\.//')
	case "$extension" in
	md|m4)
		t="$(markdowntitle "$file")"
		sed "s/TITLE/$t/" < top.html > "$ind"
		mdpreprocess "$file" | \
			lowdown --html-no-skiphtml --html-no-escapehtml \
			>> "$ind"
		cat bottom.html >> "$ind"
		;;
	html)
		t="$(htmltitle "$file")"
		cat top.html "$file" bottom.html | sed "s/TITLE/$t/" > "$ind"
		;;
	raw)
		namenoraw="$(basename "$file" | sed 's/\.raw$//')"
		cp "$file" "$dest/$namenoraw"
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
		t="$(markdowntitle $f)"
		link="https://sebastiano.tronto.net/blog/$i"

		thisyear="$(echo "$d" | sed 's/-.*//')"
		if [ "$thisyear" != "$lastyear" ]; then
			echo "<tr><td><h2>$thisyear</h2></td></tr>" >> "$bf"
			lastyear=$thisyear
		fi

		{ echo "<tr><td>$d</td>";
		  echo "<td><a href=\"$i\">$t</a></td></tr>"; } >> "$bf"

		dd="$(echo "$d" | sed 's/.*-//')"
		mm="$(echo "$d" | sed 's/....-//' | sed 's/-.*//')"
		mon="$(month "$mm")"
		{ echo "<item>";
		  echo "<title>$t</title>";
		  echo "<link>$link</link>";
		  echo "<guid isPermaLink=\"true\">$link</guid>";
		  echo "<description>$t</description>";
		  echo "<pubDate>$dd $mon $thisyear 00:00:00 GMT</pubDate>";
		  echo "</item>";
		  echo ""; } >> $ff
	done

	echo '</table>' >> "$bf"
	cat bottom.html >> "$bf"

	{ echo ""; echo "</channel>"; echo "</rss>"; } >> "$ff"
}

month() {
	case "$1" in
	01)
		echo "Jan"
		;;
	02)
		echo "Feb"
		;;
	03)
		echo "Mar"
		;;
	04)
		echo "Apr"
		;;
	05)
		echo "May"
		;;
	06)
		echo "Jun"
		;;
	07)
		echo "Jul"
		;;
	08)
		echo "Aug"
		;;
	09)
		echo "Sep"
		;;
	10)
		echo "Oct"
		;;
	11)
		echo "Nov"
		;;
	12)
		echo "Dec"
		;;
	esac
}

makeblogindexandfeed
recursivebuild src

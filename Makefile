DEST="tronto.net:/var/www/htdocs/sebastiano.tronto.net"
DESTGEMINI="tronto.net:/var/gemini"

all: clean
	./build.sh

clean:
	mkdir -p http
	rm -r http

deploy: syncgemini synchttp

syncgemini:
	rsync -rv --delete --rsync-path=openrsync gemini/ ${DESTGEMINI} || \
	openrsync -rv --delete --rsync-path=openrsync gemini/ ${DESTGEMINI}

synchttp:
	rsync -rv --delete --rsync-path=openrsync http/ ${DEST} || \
	openrsync -rv --delete --rsync-path=openrsync http/ ${DEST}

.PHONY: all clean deploy syncgemini synchttp

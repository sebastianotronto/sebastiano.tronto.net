DEST="tronto.net:/var/www/htdocs/sebastiano.tronto.net"

all: clean
	./build.sh

clean:
	mkdir -p http
	rm -r http

deploy: all
	rsync -rv --delete --rsync-path=openrsync http/ ${DEST} || \
	openrsync -rv --delete --rsync-path=openrsync http/ ${DEST}

.PHONY: all clean deploy

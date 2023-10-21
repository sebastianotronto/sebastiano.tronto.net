DEST="sebastiano@tronto.net:/var/www/htdocs/sebastiano.tronto.net"
RSYNC=$$( (command -V rsync 2>&1 > /dev/null && echo rsync) || echo openrsync)

all: clean
	./build.sh

clean:
	rm -rf http
	mkdir -p http

deploy: synchttp

synchttp:
	${RSYNC} -rv --delete --rsync-path=openrsync http/ ${DEST}

.PHONY: all clean deploy synchttp

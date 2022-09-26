DEST="tronto.net:/var/www/htdocs/sebastiano.tronto.net"
DESTGEMINI="tronto.net:/var/gemini"
RSYNC=$$( (command -V rsync 2>&1 > /dev/null && echo rsync) || echo openrsync)

all: clean
	./build.sh

clean:
	rm -rf http gemini
	mkdir -p http gemini

deploy: syncgemini synchttp

syncgemini:
	${RSYNC} -rv --delete --rsync-path=openrsync gemini/ ${DESTGEMINI}

synchttp:
	${RSYNC} -rv --delete --rsync-path=openrsync http/ ${DEST}

.PHONY: all clean deploy syncgemini synchttp

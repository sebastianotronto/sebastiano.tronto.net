all: clean
	./build.sh

clean:
	mkdir -p http
	rm -r http

deploy: all
	rsync -rv --delete --rsync-path=openrsync \
		http/ tronto.net:/var/www/htdocs/sebastiano.tronto.net

.PHONY: all clean deploy

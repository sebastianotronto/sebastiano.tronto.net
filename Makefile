all: clean
	./build.sh

clean:
	rm -r http/*

deploy:
	rsync -rv --delete --rsync-path=openrsync \
		http/ tronto.net:/var/www/htdocs/sebastiano.tronto.net

.PHONY: all clean deploy

all:
	jekyll build

upload:
	rsync -avz _site/ ndevenish.com:ndevenish.com/

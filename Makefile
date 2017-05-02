all: render

render:
	boring markdown/ templates/ static/

publish: render
	rsync -av --progress static/ hosting.bolddaemon.com:/var/www/deftly/

watch:
	boring -w -wdir markdown -wcmd "make"

sign: render
	(cd static; sha256 posts/*.html > posts/SHA256)
	gpg2 --output static/posts/SHA256.sig --detach-sig static/posts/SHA256


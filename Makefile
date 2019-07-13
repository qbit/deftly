all: render

render:
	boring markdown/ templates/ static/

publish: sign render
	rsync -av static/ web.akb.io:/var/www/deftly/
	rsync -av markdown/ root@web.akb.io:/var/gopher/articles/

watch:
	boring -w -wdir markdown -wcmd "make" -wsrv static/

sign:
	(cd static; sha256 posts/*.html > posts/SHA256)
	gpg2 --output static/posts/SHA256.sig --detach-sig static/posts/SHA256


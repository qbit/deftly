all: render

render:
	boring markdown/ templates/ static/

publish: render
	#rsync -av --progress static/ akb.io:/var/www/deftly/
	rsync -av --progress static/ hosting.bolddaemon.com:/var/www/deftly/

watch:
	boring -w -wdir markdown -wcmd "make"


all: render

render:
	boring markdown/ templates/ static/

publish:
	rsync -av --progress static/ akb.io:/var/www/deftly/


all: render

render:
	boring markdown/ templates/ static/

publish: render
	rsync -av --progress static/ akb.io:/var/www/deftly/


author: Aaron Bieber <aaron@bolddaemon.com>
title: Websockets with OpenBSD's relayd
description: Using websockets with relayd is EASY (unless you are on safari)!
tags: OpenBSD,relayd
date: Wed, 23 Oct 2019 08:00:00 MST

# The need

I am in the process of replacing all my NGINX instances with [httpd](https://man.openbsd.org/httpd)/[relayd](https://man.openbsd.org/relayd).
So far this has been going pretty smoothly.

I did, however, run into an issue with websockets in Safari on iOS and
macOS which made me think they weren't working at all! Further testing proved
they were working fine in other browsers, so .. more digging needs to be done!

# The configs

I tested this in a VM running on OpenBSD. It's 'external' IP is 10.10.10.15.

This config also works with TLS but for simplicity, this example will be plain
text.

## relayd.conf

```
ext_addr="10.10.10.15"

log connection errors

table <websocketd> { 127.0.0.1 }

http protocol ws {
	match request header append "X-Forwarded-For" value "$REMOTE_ADDR"
	match request header append "X-Forwarded-By" \
		value "$SERVER_ADDR:$SERVER_PORT"
	match request header "Host" value "10.10.10.15" forward to <websocketd>

	http websockets
}

relay ws {
	listen on $ext_addr port 8000
	protocol ws
	forward to <websocketd> port 9999
}
```

Here we are setting up a "websocket" listener on port `8000` and forwarding
it to port `9999` on `127.0.0.1` where we will be running [websocketd](http://websocketd.com/).

The key directive is `http websockets` in the `http` block. Without this the
proper headers won't be set and the connection will not work.

## httpd.conf

```
# $OpenBSD: httpd.conf,v 1.20 2018/06/13 15:08:24 reyk Exp $

server "10.10.10.15" {
	listen on * port 80
	location "/*" {
		directory auto index
	}
}
```

Pretty simple. We are just going to serve the html file below.

### /var/www/htdocs/index.html

This html blurb simply creates a websocket and pumps the data it receives into
a div that we can see.

```
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>ws test</title>
</head>
<body>
  <div id="output"></div>
</body>
<script>
let ws = new WebSocket("ws://10.10.10.15:8000/weechat");
let d = document.getElementById('output');
ws.onopen = function() {
  ws.send("hi");
};

ws.onmessage = function (e) { 
  d.innerText = d.innerText + " " + e.data;
};

ws.onclose = function() { 
  d.innerText += (' done.'); 
};
</script>
</html>
```

## websocketd

Now we use `websocketd` to serve up some sweet sweet websocket action!

```
#!/bin/sh

echo 'hi'

for i in $(jot 5); do
	echo $i;
	sleep 1;
done
```

Use `websocketd` to run the above script:

```
websocketd --port 9999 --address 127.0.0.1 ./above_script.sh
```

Now point your browser at [http://10.10.10.15/](http://10.10.10.15/)! You will
see "hi" and every second for five seconds you will see a count appended to
`<div id="output"></div>`!

# The issues

The error I saw on Safari on iOS and macOS is:

```
'Connection' header value is not 'Upgrade'
```

Which is strange, bucaese I can see that it is infact set to 'Upgrade' in a
tcpdump.

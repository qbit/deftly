author: Aaron Bieber <aaron@bolddaemon.com>
title: Concurrent Hello with Erlang
description: A concurrent Hello World with Erlang
tags: Erlang
date: Fri, 12 Mar 2010 12:01:00 MST

I recently picked up a copy of Joe Armstrong’s superb Programming Erlang book ( from the folks @ pragprog.com ). While reading the chapter on concurrent programming I was completely stumped by one of the examples. It basically creates a “server” and “client” and allows for message passing between the two. I found it very difficult to follow the passing of messages from a to b, and back.

Enter `chello.erl`! I created a slightly modified version of Joe’s example that uses some `io:format` to tell you what’s going on. Hope someone finds this useful.

``` erlang
-module (chello).
-export ([loop/0, rpc/2]).

rpc(Pid, Request) ->
    io:format("rpc[~p]  sending ~p to ~p~n", [self(), Request, Pid]),
    Pid ! {self(), Request},
    receive
        Response ->
            io:format("rpc[~p]  responding with : ~p~n", [self(), Response]),
            {Pid,Response}
    end.

loop() ->
receive
    {From, {hello}} ->
        io:format("loop[~p] received info from: ~p~n", [self(), From]),
        From ! {self(), "Hello"},
        loop();
    {From, {goodbye}} ->
        io:format("loop[~p] received info from: ~p~n", [self(), From]),
        From ! {self(),"Goodbye"},
        loop();
    {From, Other} ->
        io:format("loop[~p] received info from: ~p~n", [self, From]),
        From ! {self(),{error, Other}},
        loop()
    end.
```

Run from the erl shell with:

    1> Pid = spawn(fun chello:loop/0).

    <0.38.0>

    2> chello:rpc(Pid, {hello}).
    rpc[<0.31.0>] sending {hello} to <0.38.0>

    loop[<0.38.0>] received info from: <0.31.0>

    rpc[<0.31.0>] responding with : {<0.38.0>,”Hello”}

    {<0.38.0>,{<0.38.0>,”Hello”}}

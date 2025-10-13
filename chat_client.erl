-module(chat_client).
-export([init_chat2/1]).

init_chat2(RemoteNode) ->
    io:format("Enter Your Name: "),
    {ok, [Name]} = io:fread("", "~s"),

    %% Start listener process first
    ListenerPid = spawn(fun() -> listen_messages() end),

    %% Notify host with listener PID
    {chat_room, RemoteNode} ! {join, ListenerPid, Name},

    %% Begin sending messages
    send_messages(Name, RemoteNode, ListenerPid).

send_messages(Name, RemoteNode, ListenerPid) ->
    Msg = io:get_line(Name ++ ": "),
    Text = string:trim(Msg),

    {chat_room, RemoteNode} ! {msg, Name, Text, ListenerPid},

    if
        Text == "bye" ->
            io:format("Disconnected.~n"),
            ok;
        true ->
            send_messages(Name, RemoteNode, ListenerPid)
    end.

listen_messages() ->
    receive
        {chat_msg, Msg} ->
            io:format("~s", [Msg]),
            listen_messages()
    end.
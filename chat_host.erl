-module(chat_host).
-export([init_chat/0]).

init_chat() ->
    io:format("Starting chat room server...~n"),
        
    register(chat_room, spawn(fun() -> chat_room_loop([]) end)),
    
    io:format("Chat room registered as 'chat_room' on ~p~n", [node()]),
    io:format("Chat room server started successfully!~n"),
    io:format("Users can now connect using: chat_client:init_chat2('~p')~n", [node()]),
        
    receive
        stop -> 
            io:format("Shutting down chat host...~n"),
            exit(chat_room, normal)
    end.

chat_room_loop(Clients) ->
    receive
        {join, ListenerPid, Name} ->
            NewClients = [{Name, ListenerPid} | Clients],
            io:format("~s joined the chat room (~p clients total)~n", [Name, length(NewClients)]),
                        
            broadcast_message(NewClients, ListenerPid, 
                io_lib:format("~s has joined the chat room~n", [Name])),
            
            chat_room_loop(NewClients);
            
        {msg, Name, Text, SenderPid} ->
            case Text of
                "bye" ->                    
                    RemainingClients = lists:keydelete(SenderPid, 2, Clients),
                    io:format("~s left the chat room (~p clients remaining)~n", 
                             [Name, length(RemainingClients)]),
                                        
                    broadcast_message(RemainingClients, none, 
                        io_lib:format("~s has left the chat room~n", [Name])),
                    
                    chat_room_loop(RemainingClients);
                    
                _ ->                    
                    Message = io_lib:format("~s: ~s~n", [Name, Text]),
                    io:format("~s: ~s~n", [Name, Text]),
                    
                    broadcast_message(Clients, SenderPid, Message),
                    chat_room_loop(Clients)
            end;
            
        stop ->
            io:format("Chat room shutting down...~n"),
            broadcast_message(Clients, none, "Chat room is shutting down...~n"),
            ok;
            
        _ ->
            chat_room_loop(Clients)
    end.

broadcast_message([], _SenderPid, _Message) ->
    ok;
broadcast_message([{_Name, ListenerPid} | Rest], SenderPid, Message) ->    
    if
        ListenerPid =/= SenderPid ->
            ListenerPid ! {chat_msg, Message};
        true ->
            ok
    end,
    broadcast_message(Rest, SenderPid, Message).
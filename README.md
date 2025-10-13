# Erlang Distributed Chat System

This is a distributed chat system implemented in Erlang, designed as a team exercise with clear task distribution between Person A (Host) and Person B (Client).

## Project Structure

- `chat_host.erl` - Host implementation (Person A)
- `chat_client.erl` - Client implementation (Person B)
- `README.md` - This documentation file

## Team Task Distribution

### Person A (Host – init_chat/0)
- ✅ Implement `init_chat/0` – starts and registers the chat room process
- ✅ Build `chat_room_loop(Users)` – manages joins, messages, and exits
- ✅ Create `broadcast(Users, Msg)` – sends messages to all participants
- ✅ Handle adding/removing users in `chat_room_loop`
- ✅ Handle user exit ('bye') to disconnect cleanly

### Person B (Client – init_chat2(RemoteNode))
- ✅ Implement `init_chat2(RemoteNode)` – connects to the host and joins the chat room
- ✅ Build `chat_client(Name, RoomNode)` – handles send and receive operations
- ✅ Create `send_messages(Name, RoomNode)` – continuously reads and sends user input
- ✅ Implement `listen_messages()` – listens and displays received broadcasts

## How to Run

### Prerequisites
- Erlang/OTP installed on your system
- Two terminals or two machines

### Starting the Host (Person A)

1. Open terminal 1 and start an Erlang node:
```bash
erl -name host@localhost -setcookie secret
```

2. In the Erlang shell, compile and start the host:
```erlang
c(chat_host).
chat_host:init_chat().
```

The host will display:
```
Starting chat room server...
Chat room registered as 'chat_room' on host@localhost
Chat room server started successfully!
Users can now connect using: chat_client:init_chat2('host@localhost')
```

### Starting a Client (Person B)

1. Open terminal 2 and start an Erlang node:
```bash
erl -name client1@localhost -setcookie secret
```

2. In the Erlang shell, compile and connect:
```erlang
c(chat_client).
chat_client:init_chat2('host@localhost').
```

3. Enter your name when prompted and start chatting!

### Adding More Clients

You can add more clients by repeating the client setup process with different node names:
```bash
erl -name client2@localhost -setcookie secret
erl -name client3@localhost -setcookie secret
```

## Features

### Message Broadcasting
- All messages are broadcast to all connected users
- Users see messages in the format: `[Username]: Message content`

### User Management
- Users can join and leave the chat room
- System notifies all users when someone joins or leaves
- Users can type `bye` to leave gracefully

### Error Handling
- Connection validation before joining
- Graceful disconnection handling
- Server shutdown notifications

### Shared Coordination
- Uses registered name `chat_room` for the server process
- Uses same cookie (`secret`) for node communication
- Consistent message format across all components

## Testing & Integration

### Basic Testing
1. Start host node
2. Connect multiple clients
3. Test message broadcasting
4. Test user join/leave notifications
5. Test graceful disconnection with `bye`

### Multi-User Testing
1. Start host on one machine/terminal
2. Connect 3-5 clients from different terminals
3. Send messages from different clients
4. Verify all clients receive all messages
5. Test users leaving and rejoining

## Message Types

### Client to Server
- `{join, UserName, FromPid}` - User joining
- `{message, UserName, Message}` - User sending message
- `{leave, UserName, FromPid}` - User leaving
- `{list_users, FromPid}` - Request user list

### Server to Client
- `{message, UserName, Message}` - Broadcast message
- `{user_joined, UserName}` - User joined notification
- `{user_left, UserName}` - User left notification
- `{server_shutdown}` - Server shutting down
- `{user_list, Users}` - Response to user list request

## Cleanup

### Stop Host
```erlang
chat_host:shutdown().
```

### Stop Client
```erlang
chat_client:leave_chat().
```

## Notes

- All nodes must use the same cookie for communication
- Node names should be unique across the network
- The system handles unexpected messages gracefully
- Users can reconnect after disconnection


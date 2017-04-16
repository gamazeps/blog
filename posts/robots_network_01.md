---
title: Sending and receiving message to distant actors.
date: 2015-12-27 20:12:00
Category: RobotS
Tags: RobotS, rust
author: Felix Raimundo
---

# Sending messages accross network.

We now have a kinda working actor system on a local instance, this is good, but not good enough.
We would like to have multiple actor systems accross many machines and have them comunicate with
each other. Even better we would like our actors to be able to communicate from an instance to another
one in a transparent way.

## A better ActorPath.
To do so we will have to add some information on our ActorPath. 
Previously it only contained a path to the actor in the form of a string (a bit like a URI),
for example: `/user/big_actor/small_actor`, this is all fine and dandy but that will not help us go
very far.

The idea for an improvement would be the following:

```rust
struct ActorPath {
    path: Arc<String>,
    machine_info: MachineInfo,
}

enum MachineInfo {
    Local,
    Distant(ConnectionInfo),
}

struct ConnectionInfo {
    address: Arc<String>,
    port: u32,
}
```

And we change the `path(&self)` method in the `CanReceive` trait to give an `ActorPath` instead of
an `Arc<String>`.

## Sending messages to distant actors.

Now when we want to send a message to a CanReceive we will check wether it is local or not, if it
is local, then we do not change a thing from what we used to do before. 
Now if this is not local we will send it to the `system actor`.

The `system actor` is the actor which manages the system related actions, for example sending messages
to distant actors and creating the dead letters actors (that's all for now, but the idea is that it
manages actors needed for the actor system to work).

The point of having a system actor is that it manages its thread separately from the ones of the user.

So the system actor will have a child in charge of sending messages to distant actors, let's call it
`network actor`. This `network actor` will receive the message from our local actor, and send it to
the address on the specified port.

*  If it encounters this (address, port) pair for the first time it will create an actor to open a
   socket and it will send the message with this socket (without closing it). The network actor will
   then store a CanReceive to this actor.
*  If it has already encountered this (address, port) pair, it sends it to the actor created above.

The message will be sent under the form (it will be serialized, but this si just to give a rough
idea):

```rust
struct DistantMessage {
    from: ActorPath,
    to: ActorPath,
    message: InnerMessage, // This is what is used to represent messages in the local case.
}
```

We can now send to a distant actor, now let's see how we receive from a distant actor.

## Receiving messages from distant actors.

The system actor provides a network actor and he is in charge of connections to distant actor
systems.

In order to be able to receive from another actor system we first need to open a connection to it.
This connection can either:

*  Have already been created while sending messages to this actor system.
*  Have to be explicitly created. This will be done by asking the actor system to explicitly start
a connection (with a method like `start_connnection(&self, address: String, port: u32)`).

We thus have to listen on taht socket and when something is received, the actor will send the
message to the targetted actor (we thus need a way to obtain a CanReceive from a local ActorPath),
and put the distant actor as the sender.

And that's about it!

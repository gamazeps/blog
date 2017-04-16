---
title: Actors Adressing.
date: 2016-01-06 19:33:00
Category: RobotS
Tags: RobotS, rust
author: Felix Raimundo
---

# Objectives.

Having a unified addresssing system for all struct that act as actors, whether local or distant.

The current problem right now is that too many structure implement the CanReceive trait: root actors,
regular actors and futures. It was choosen at first to have structures implement the CanReceive trait
in order to enable the user to define his own interafces, but after some reflection it seems like
it was a bad idea: the user should not have to do that and should simply use actors, if he can't do
that then there is a problem either on RobotS or his logic, which can either be solved with a PR or
cannot be solved at all anyway.

Thus I we will hide everyhthing under a new ActorRef structure with an enum inside it for the
different kinds of struct that can act as actors, it would look like.

```rust
pub enum InnerActor {
    Cthulhu(Cthulhu),,
    Actor(ActorCell),
    Future(Futures),
}
```

# Changes in the Root Actors.

We will implement Root Actors (user actor and system actor), as regular actors. They will create
spawn actors when receiving a message. 
Indeed in the previous version we had a custom implementation because we wanted them to have an
`actor_of` method through their references, here we will just have:

```rust
pub struct RootActor;

impl Actor for RootActor {
    fn receive(&self, message: Box<Any>, context: ActorCell) {
        if let Ok(message) = Box::<Any>::downcast::<(Box<ActorFactory>, String)>(message) {
            let (props, name) = *message;
            let actor_ref = context.actor_of(props, name);
            context.tell(context.sender(), actor_ref);
        }
    }
}
```

This means that the `actor_context.actor_of` method will return a `Future` instead of an `ActorRef`.

This change in the root actors is a good thing because their code was a copy of the one for ActorRefs.

# Actor Path and ActorRef API

Since we tried to stabilize the RobotS API we will try not to change too many things, hopefully it
will be almost invisible for the user (we already used a type called `ActorPath`).

The ActorPath should be like:

```rust
pub enum ActorPath {
    Local(String), // Local logical path.
    Distant(ConnectionInfo)
}

struct ConnectionInfo {
    distant_logical_path: String,
    ip_addr_port: String, // A bit ugly but that's for the v1, looks like "0.0.0.0:10000".
}
```

And the `ActorRef` should look like:

```rust
pub struct ActorRef {
    inner_actor: Option<InnerActor>, // None if the underlying actor is distant.
    actor_path: Arc<ActorPath>,
}
```

Note that the infrmation on the fact that an actor is local or distant is there twice:

  * Whether `inner_actor` is `None` or not.
  * Whether the ActorPath enum is in the LOcal or Distant variants.

This is not incredibly good from a software perspective, but it allows to have exactly the same
interface for actor whether they are local or distant.

Now the API should stay pretty much the same:

```rust
    fn receive_system_message(&self, _system_message: SystemMessage) {
        //...
    }

    fn receive(&self, _message: InnerMessage, _sender: ActorRef) {
        //...
    }

    fn handle(&self) {
        //...
    }

    fn path(&self) -> Arc<ActorPath> {
        //...
    }

    pub fn tell_to<MessageTo: Message>(&self, to: ActorRef, message: MessageTo) {
        //...
    }

    pub fn ask_to<MessageTo: Message, V: Message, E: Send + 'static>(&self,
                                                                     to: ActorRef,
                                                                     message: MessageTo)
                                                                     -> Future<V, E> {
        //...
    }
```

And that's about it.

Cheers, 
gama

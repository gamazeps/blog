---
title: Notes 9
date: 2016-02-12 13:00:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

# Failure / Termination handling.

Now that we have nice Futures we would like to be able to react if they fail, or else our application might deadlock
waiting for an answer.

On the same idea, the current way to handle actors failures is not so good, indeed the code used to handle the failure is
*in* the library code and thus is very hard to change.

The solution I'm thinking about is to register a function to be called once an actor failed or is terminated.

```rust

context.register_failure_handler(actor, |context, failure| {
   // ...
}

```

This would do two things:
  * Ask the targetted actor to notify us when he fails.
  * Saving this closure and use it when the notification is received.

We could still keep the current behaviours by putting them as default handlers, which can be overwritten when needed.

## Implementation

We will use a hashtable with ActorRef/ActorPath as keys and the closure as values.

Before doing that we will also ensure that no two actors with the same path can be created (this was not done before),
to do so we will simply check that when creating an actor, the father has no children with the same  path.
We will also need to check that the user does not include separators `/` in the name provided for his actor to avoid traversal
(just like directory traversal in security stuffs).

# Failure creation.

For failures I propose the following structure:

```rust
struct Failure {
    source: ActorRef,
    reason: &'static str,
}
```

When an actor panics we have no way of knowing the reason why he panicked so the reason would be 'panic'.

Thus we need to add a method to have an actor fail.

```rust
fn fail(self, context: ActorCell, reason: &'static str) {
    let me = context.actor_ref();
    for actor in context.monitored().iter() {
        context.tell(Failure::new(me.clone(), reason));
    }
}
```

# Registering for termination notice.

This will be done by sending a message to an actor.

# Overall call history.

The calling order will be the following:
  * Send a Register(ACtorRef) to an actor.
  * Check if the actor is still alive, if not call the closure.
  * The actor receives the message and puts its sender in the list of actors to notify.
  * The actor fails and sends a notification to all its registered actors.
  * The registerd actors receives a failure, checks if the source is an actor it monitors, if so calls its handler and
    unregisters.

Note that with this we do not need to differenciate between children and other actors, as the only difference will be the
handler. Nevertheless we still need to keep the children's actor refs in the father as they are the only strong ref to them.

---
title: Why Box&lt;Any>
date: 2016-01-12 13:36:00
Category: RobotS
Tags: RobotS, rust
author: Felix Raimundo
---

# Why using Box&lt;Any>

Indeed that is a question that I am always asked (and that I also often ask myself), so I thought
it would be a good idea to put the reaons here, who knows someone might find a flaw in them.

It is also a nice way of rubber ducking for me.

## Different message types.

Well it's not really a big problem, but not having a Box&lt;Any> as messages implies that Actors can
only receive a single type of messages. Indeed the mailbox cannot contain messages of just any type
except if it uses an Any.

Indeed the mailbox looks like:

```rust
/// Struct that contains everything around the actor for it to work.
struct ActorCell {
    //...
    mailbox: Mutex<VecDeque<T>>,
}
```

So different types may imply a Box&lt;Any>.

But "Why not use enums?" you will tell me. Rust enums are very powerful and would allow us to
receive many messages, that is indeed a good idea but it fails in the long run, let's see why.

## Why not enums?

Now if we have an enum, that we will call E, we could have the following:

```rust
enum E {
    A(A),
    B(B),
}
```

And thus:

```rust
    mailbox: Mutex<VecDeque<E>>,
```

Except that all actors do not acccept the same message set (note: or could they?), thus we need to
have the ActorCell generic aver this enum:


```rust
struct ActorCell<E> {
    //...
    mailbox: Mutex<VecDeque<E>>,
}
```

The problem is that now, since ActorRef (addresses used to communicate with actors) can contain
an ActorCell (they contain an enum which can have an ActorCell variant), they also need to be generic
over the message set.

```rust
pub struct ActorRef<E> {
    innerActor: InnerActor<E>,
}

enum InnerActor<E> {
    Actor(ActorCell<E>),
    // ...
}
```

And problems appear now!

Remember how we represented the mailbox ? That was a bit of a lie, indeed this mailbox does not keep
the sender information, and we want to have them.

Thus we have Envelope&lt;E> instead of E in the mailbox, with

```rust
struct Envelope<E> {
    message: E,
    sender ActorRef,
}
```

But remenber, we just made ActorRef generic over the type of messages they receive, thus we have:

```rust
struct Envelope<E, F> {
    message: E,
    sender ActorRef<F>,
}
```

But now our mailbox cannot hold Envelopes with different F, so it would mean that an actor can only
receive message from a single type of actors, and that is pretty bad...

Here it is, the horrible reason why we have Box&lt;Any>.

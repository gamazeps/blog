---
title: Notes 3
date: 2016-01-25 19:36:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

# Rethinking the idea of macros.

Maybe using macros is not the best idea when i could be using functions instead for some calls,
at first i was not so sure of creating functions for handling future in the ActorContext as
they are actors, so these functions could be called on regular actors.

Nevertheless I think that it is a price worth paying as it will avoid using a few macros.

# Trait issues.

Now everything is fine and dandy with this design, but the messages to Futures are neither
Clone nor Sync, which is pretty bad...

Let's try to make this better.

```rust
pub enum FutureMessages {
    Complete(Arc<Any + Send>),
    Calculation(Arc<Fn(Box<Any>, ActorCell) -> FutureState>),
}
```

We may have to use some mem::transmute there to...

AN hour into it, and that seems pretty hard to have my enum be safe, and then castable into a
Box&lt;Any>, the people on #rust think the same unfortunately, rust is definitely not
nice when you try to type it dynamicaly...

Funny thing, my questions about how to cas a Arc&lt;Send + Sync> into a Box&lt;Any + Send> lead
some compiler devs to find a bug in the compiler while we brainstormed on how to implement that.

Almost done with the message passing for futures, I got stuck a little while trying to cast
a &mut ref A + B into a \*mut A + C (where B => C), because the compiler thinks I'm trying to
add C to the result of the cast. This was solved by creating a trait D, where D: A + C, that's
rather ugly in my opinion...

Ok... It has now been a good hour on this cast and it's still not working...

Found the issue, the main problem was that I was trying to cast a ref that did not contain
Any into a pointer that contained Any. In theory this should not be an issue as all types
are supposed to be Any, but in practice it is as the types have to be Any, once I added an
Any in the types required everything went as planned !

I had a small scare for the definition of my extraction macro, hopefully it seems to be doable.
Indeed I would need to define a local Actor and I didn't know if it was possible in the middle
of a function, but hopefuly it was, as you can see in the following snippet:

```rust
trait Tata {
    fn hi(&self);
}

fn main() {
    struct Toto {
        a: i32
    }
    impl Tata for Toto {
        fn hi(&self) {
            println!("hi");
        }
    }
    impl Toto {
        fn new() -> Toto {
            Toto {
                a: 0
            }
        }
    }
    
    let x = Toto::new();
    x.hi();
}
```

Thinking about the `extract!` macro I think I wil only implement it for when we are outside of an
actor, as it seems quite the bad practice to use it inside an actor.

So inside actors we need a way to:

* Complete the future.
* Send calculations to the future.
* Send the results to an actor by message passing.

Here we have one issue, completing a future needs to be done by calling the `complete` method,
thus it does not technically act as an actor (here we have to know that this is a future), but
it kinda makes sense as it can be considered the protocol to interract with this special actor.

Note that we need the extraction to be done in a closure, because we need the closure to type
the value inside the Future before sending it to an actor.

There is also a new change: since actor creation by the user and system actor use futures, we
can no longer use futures to get the actors they created, Indeed we would need to create an actor
using one of them (and thus loop indefinitely creating actors).

Thus ActorRefs of actors created by the system and user actors will be communicated with channels.

Now can we guarantee that the ActorRef we will receive is the same we asked for (i.e no race
condition) ?

The simplest way is to create a channel for each actor created this way, it may sound horribly
slow, but it's actually ok, as creating new actor hierarchies all the time is not the use case
of this crate.

While implementing the use of my new futures I encountered a race condition again (the program
will block while creating the name resolver), once again I had to add a lot of debugs, thus
my next stop will be to add a proper logging system (otherwise I might go crazy when implementing
the remoting).

---
title: Notes 1
date: 2016-01-21 16:36:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

# Some notes

I recently realized that while working I had a lot of notes on many different and unreliable
supports, this is bad...

So I'm going to put my research notes about robots in a series of notes posts, this way it
will be easier to document the design choices, dead ends and openings I found.

# Some coding.

The design mentionned in the previous post is kinda implemented, I'm still trying to figure out
how to get a proper API.

My current issue is with the extraction of the value contained in the future (equivalent to
akka's `pipeTo`). Indeed at first I wanted to have an `extract!` macro, but it had a small
issue.

Indeed extracting the value is nice, but i want to be able to destroy my future once this is
done.

In the same way I needed to know how to complete my future.

The first idea that came to my mind was to have an enum for the messages a future would receive:

```rust
enum FutureMessages {
    Complete(Box<Any>),
    // Note that the Send in the Box is so that the Future actor is Send as it has to store
    // this inside it.
    // Here I put an Option, but it is supposed to act as an Error, I just wanted to have
    // first version rolling.
    Calculation(Box<Fn(Box<Any>, ActorCell) -> Option<Box<Any + Send>>>),
    Extract,
}
```

The API issue with this is that the extract has to send the content of the future which is
an Option&lt;Box&lt;Any + Send>>.

*  This content is not Send nor Sized, which thus cannot be used with the usual tell method.
*  The recepient of the extracted value will receive a Box&lt;Any> that he will have to
cast in a Option&lt;Box&lt;Any>> (plus what will be needed to have the messages be Send), and
then cast it again in the desired type. This is super bad...

I'll look into it by using enums as a return of an extract value.

The two casting parts is hard to avoid, because we cannot have an Extract&lt;T> message to send
to the Future, and if we put the genericity in a regular calculation closure

A solution could be t have functions that return an enum instead of an option, such as

```rust
enum CalculationResult {
    Exracted,
    Result(Box<Any + Send>),
    // NOTE: no idea how to integrate this in the API.
    Error,
}
```

and macros that would generate the following code:

`extract!(future, Type)` =>

```rust
context.tell(future, |message, context| {
    match Box::<Any>::downcast::<Type>(message) {
        Ok(message) => {
            context.tell(context.sender(), *message);
            CalculationResult::Extracted
        },
        Err(_) => Error,
    }
});
```

`then_do!(future, some_func)` =>
    
```rust
context.tell(future, |message, context| {
    Result(Box::new(some_func(message, context)) as Box<Any + Send>)
});
```

Thus we would be able to have the user feed us functions that can return any type that is `Send`
which is much nicer, this will just require some more internal logic than the actual
implementation.

# Some readings.

Having recently realized that I have to implement my own futures and protocols for the
networking, I decided to spend the day reading papers by Joe Armstrong to get some wisdom
and experience.

I started with: ["Message passing concurrency in Erlang"](http://qconlondon.com/london-2010/qconlondon.com/dl/qcon-london-2010/slides/JoeArmstrong_MessagePassingConcurrencyInErlangAnArchitecturalBasisForScalableFaultTolerantSystems.pdf) by Joe Armstrong.
hoping to get some nice insights on how this was done in Erlang. It gave me the idea to
get a lok at amqp and rabitmq for sending my messages instead of havin my own protocol.

This also scares me a little, since the slides 45-46 tend to suggest that Erlang found its power
in its dynamic type system and encoding.  

Except for this part I feel that my current design and implementation are OK by what he describes
as goodpractices (the big GOOD IDEA in his slides), which is nice.

I then read ["A concurrency system for IDRIS & ERLANG"](http://lenary.co.uk/publications/dissertation/Elliott_BSc_Dissertation.pdf)
by Archibald Samuel Elliott on the advice of `geal` from mozilla's irc (he is the one responsible
for the nom crate).

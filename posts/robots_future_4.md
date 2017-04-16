---
title: Designing Robots Futures - Part 4
date: 2016-01-18 22:11:00
Category: RobotS
Tags: RobotS, rust, Future
author: Felix Raimundo
---

# Futures as Actor

Today I got a good idea, instead of just having futures behave as actors, why not have them *be*
actors ?

*  This would solve the issue of passing them context.
*  This would solve the issue of scheduling them.
*  This would solve the issue of monitoring them.

Overall it sounds like a pretty good deal.

Now what is the drawback in that ?

The api might be a bit messier, indeed we would need to 'send' them a message.

```rust
context.tell(future, |msg, context| { // do some stuff
	context.tell(foo, bar);
});
```

The nice thing is that in order to get the value of the end calculation we would simply do

```rust
let f = Future::new(); // or let f = some_acor.ask(foo)?
// Let's schedule some calculations.
context.tell(f, some_func_1);
context.tell(f, some_func_2);
// Let's get the result of the calculation in a message.
context.tell(f, |msg, context| {context.tell(context.sender(), msg)});
```

Now the API issue could be solved with some nice macros such as:

```rust
// Sending a mesdsage to the future.
then_do!(future, {some.code()});
// Getting the value out the future.
extract_value!(future);
```

So this seems like a good deal overall, there is only one issue left here: with this model we lose
the abality to fail when completing a future twice, indeed the caller will interract with a simple
actor, so it will be the Future's job to refuse the second completion (it could send an Error to
the actor trying to complete the future a second time, but there is thus some rror handling needed).

We could send a special message to have the caller fail (send him a panic message for example).

Overall I am quite satisfied with this design idea as it solves most of m issues in a rather elegant
manner, the main drawbacks being API and error handling, which can both be solved in a rather
satisfying manner.

I think I will implement Futures this way tomorrow and see how it goes (since I use them inside my
core code I will be able to see if this API is really correct or not).

# Some more details

What we would have is the something looking like the following:

```rust
struct Future {
    value: Mutex<Option<Box<Any>>>,
}

impl Actor for Future {
    fn receive(&self, msg: Box<Any>, context: ActorCell) {
        let mut value = *self.value.lock().unwrap();
        let v = value.take();
        match v {
            None => *value = Some(msg),
            Some(v) => {
                // try to cast the msg in a closure that we will call f.
                let v = Some(f(context, v));
                match v {
                    // If the closure returns a correct value we update the value inside the Future.
                    Ok(v) => *value = Some(v),
                    // Otherwise we die, this will be able to send termination notices.
                    Err(_) => context.kill_me(),
                }
            }
        }
    }
}
```

This is a rough draft, but you get the idea (some error handling is obviously missing here).

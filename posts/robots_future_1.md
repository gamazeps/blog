---
title: Designing Robots Futures - Part 1
date: 2016-01-12 14:31:00
Category: RobotS
Tags: RobotS, rust, Future
author: Felix Raimundo
---

# Objectives.

We are making and actor system and in such an system asynchronicity is a fundamental.

Communication from one actor to another is made by sending messages, but what if we wanted an answer
to our message? That's where Futures come in!

The way we want them to work is the following:

````rust
fn receive(&self, message: Box<Any>, context: ActorCell) {
    let future = context.sender().ask("hi".to_owned());

    future.do(|message| {
        // Some stuff.
    });
}
```

Or the following:

````rust
fn pre_start(&self, context: ActorCell) {
    let future = context.identify_actor("/user/foo/bar");

    future.do(|actor_ref| {
        match actor_ref {
            Some(actor_ref) => context.tell(actor_ref, "baz".to_owned()),
            None => println!("The requested actor does not exist, this is very sad..."),
    });
}
```

With the closure in the `do` being called when an answer to the `ask` message is sent.

We have now defined our objective, let's try to fulfill it!

---
title: Notes 8
date: 2016-02-09 18:00:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

# Coding with no Anger.

Well, now that I know that there are no elegant (or rustic) implementation of what I wanted to
do I went with a non elegant one and it works perfectly.

The solution was to have two types of message

```
pub struct Complete {
    complete: Box<Any + Send>,
}

pub enum Computation {
    Computaton(Func),
    Forward(ActorRef, Func),
}
``` 

and to try to downcast the message the Future receives twice.

The first message is put directky in the mailbox of the Actor without using `context.tell`,
thus the `context.complete` code is a close duplication of the code in the tell method,
but it's really because of an edge case so it seems OK to me.

# Plan for today.

Now I wil need to add a good error handling for the Futures, so that we can make actors fail
if they try to complete a Future twice (plus having a way to make actors fail seems pretty useful
on its own).

I also realized yesterday that I need to add unit tests for basic behaviours, such as receiving
a single message or asking something. This behaviour is already tested in bigger tests, but
not having tests for these behaviours is pretty bad.

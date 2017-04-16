---
title: Designing Robots Futures - Part 2
date: 2016-01-16 20:01:00
Category: RobotS
Tags: RobotS, rust, Future
authors: Felix Raimundo
---

# Some issues.

We mentionned what we wanted, let's talk about some of theproblem we might encounter during the
design. 

First there is a rather obvious lifetime issue. Indeed as we said last time we want to be able to
free the thread as soon as possible (when returning from the `receive` function) and thus simply
tell the future what it should be doing when the answer is received.

Thus when the future that the `ask` method gives us is dropped, the information we gave it must not
be lost.

The second lifetime issue is the can be simply seen in the folowing case:

- Actor A asks something to Actor B.
- In his future, the closure takes the context (it is clonable), and uses some methods of it when
  it will be completed.
- Actor A is terminated for some reason.
- Actor B receives the message and answers.
- The closure is called and tries to use the context of a no longer existing actor (A).

Now this is hopefuly not to bad, as ActorCell can kinda gracefuly handle themselve when the actor has
been dropped.

A question that might be asked from this is whether or not Actor A should be kept alive or not as long
as a future it spawned is alive ?

Now another thing that we may want would be to be able to do the following:

````rust
let future = some_actor_ref.ask(());

let x = future.do(|| {//...});
// y's closure is launched at about the same time as x's, and gets the same value as input.
let y = future.do(|| {//...}); 
```

This seems like a nice to have but not incredbly necessary (we could try to reimplement
[eventual](https://github.com/carllerche/eventual)'s `Async`).

## Handling double answers.

Now we also need to handle the case were an actor answers twice to the mesage, what should happen in
this case ?

The current design idea would be to have the actor fail, but not the future (as a future could only
be completed once in theory) since the failure does not come from the Future.

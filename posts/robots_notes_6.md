---
title: Notes 6
date: 2016-01-28 21:00:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

# Futures

Yay !

I finally made everything compile, which is nice, now let's adapt the code to use the new
futures.

I nevertheless found an issue with my implementation, this requires to know when we are
addressing a future and we are not.

Thus my `forward_to` functions needs to be different when we forward to an actor and when
we forward to a future (when we chain futures).

In my implementation I thought we needed to send specific messages, because otherwise the Future
has no way of knowing if a message it receives is a completion message or a closure (in the case
the future wants to be completed with a closure).

This is a bit tricky because I both want my futures to act as actors and I also want them to
be able to hold any type of value...

I did not find a way to do that, so it seems that the API will be a bit different when extracting
a future to an actor or another future, this is not optimal but it will have to do.

I also realized that I need to have a special message for extraction / forward. Indeed I need
to pass the address to which send the extracted value, but I cannot create a closure with
it inside (in retrospect I should have seen this issue earlier), so I will pass that as an
argument.

I could just send the ActorRef, but I prefer to also send a closure so that we can type the
message, that is send a T instead of a Box&lt;Any + Send> that would need to be casted (and is
also not `Sync`).

Thus we will have an enum for computations that looks like the following:

```rust
enum computation {
    Forward(actorref, closure)
    Complete(actorref, closure)
    computaion(closure)
}
```

Note: This blog post has been posted a long time after the time it was written.

---
title: Notes 2
date: 2016-01-24 19:36:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

# Today's plan

The plan today is to finish reading the paper about Idris and Erlang, then read Joe's
Armstrong paper about the history (and design decisions) of Erlang.

Eventually I'd like to finish implementing the Futures.


# Reality

## A concurrency system for IDRIS & ERLANG.

I just finished reading the article about Idris and Erlang (["A concurrency system for IDRIS & ERLANG"](http://lenary.co.uk/publications/dissertation/Elliott_BSc_Dissertation.pdf)),
it was very interesting as it showed how someone would go about having type safety with an
actor system. 
A conclusion of this article would be that typing an actor system is very hard, and some
features (forwarding, getting type information about the sender, using Erlang's `become`) are
still not implemented yet anywhere.

Nevertheless, using traits for defining the interface of actors could be a solution.
Indeed, traits allow us to *pick* types, using them as markers (just like `Send` and `Sync` are
marker traits) we could have actors only acepting messages of a given trait. One small issue
with that is that to my knowledge structs can only be generic over a type and not over a trait.

Overall this article was rather interresting, even though its results are not directly applicable
to my project (as this paper talks about writting IDRIS code with dependant types that can be
checked by its compiler and then compiling it to Erlang code). 
We may think that the same approach could be used to take advantage of Rust's lifetime properties,
but we will not follow this approach.

## A history of Erlang.

This article: ["A History of Erlang"](http://dl.acm.org/citation.cfm?id=1238850&dl=ACM&coll=DL)
by Joe Armstrong presents the history and design desicions behind Erlang, from
its creation up to 2007 (time of the paper).

Well this one was a biggy, but really instructive articles. It explains how Erlang was designed,
what lead to some design choices (immutable messages, having a VM, building OTP and why they
used prolog).

It's a bit long so I'll only put a few notes on it in order to keep things short and readable.

* Using immutable *copyable* messages is very important. The insistance on the copyable aspect
guarantees that no memory corrruption can appear and that if a process fails he doesn't mess up
the other ones. This is guaranted in RobotS by having messages be `Copy + Sync` (and `Send`, as
the two imply the third even if the compiler does not guess it, see [this article](http://huonw.github.io/blog/2015/02/some-notes-on-send-and-sync/)). 
* GC is important. This is handled in RobotS thanks to Rust RAII and by actor supervision. Indeed
when an actor fails, its parent is noticed and drops it if necessary (or restarts it).
* Mutexes are hard to use in a complex system. This is kinda solved in Robots for the user and
will be solved by giving the `Sync` trait to actors (as they are `Sync` since the `ActorCell`
wrapper guarantees the accesses).
* Fault-tolerance and error handling are super important. This is still very much a work in 
progress for RobotS, I don't know if I will have time to do that before the end of the semester
(but it should happen afterwards, as being unemployed leaves some spare time).
* Having everything act as a process (in interface at least) implies type information losses
`When you send a message to a process, there should be no way of knowing is the process was some
hardware device or just another process`. Having everything act as black boxes implies some
dynamic typing / introspection by design.
* Communication with remote instances is also based on TCP/IP sockets, this confirms my design
for RobotS.
* Sending binary data is not exactly done with copying and is needed for sending messages through
sockets, this is nice because this is a probelematic area of my design, knowing that it was
problematic for Joe Armstrong makes me feel better.
* There have been many efforts to introduce type systems to Erlang, they all failed, the
one that got the closest at the time of writting of the paper was [Dialyzer](http://erlang.org/doc/man/dialyzer.html),
which is 'just' a static analysis tool. The other approach is to use code generation, which
is what we saw in the previous paper. This means that type guarantees have to be checked
dynamically which is what is currently done in RobotS (another approach can be done and will be
expanded on in the next paragraph).

Now some notes on the way Erlang was implemented, it first started as a prototype with a very
fast development cycles with many breaking changes, this lasted a few years before going
to a more structured approach (design docs, then implemenation). 
Another common approach in the development was to test an idea, implement it for a few weeks,
delete everything and reimplement it in a few hours.

It reassures me a little to read this because this is kinda the approach taken during the early
development of RobotS...

Overall seeing how such a big project was created is very interesting and brings some insight in
the design decisions of Erlang.

# Some thoughts about types.

As said before trying to push types in a system that was not thought with types is doomed to fail,
this is why even now we don't really have typed actor systems besides akka's attempt at it.

An idea that came to my mind is to have protocols (and not types) as first order objects, this
would ease the compiler's job a lot and allow us to remove a lot of dynamic checks.

Nevertheless it would imply that the user would need to consider protocols as a fondamental part
of its application (even more than the main job of its actors / processes), it might come as a
big thing to ask from the user, but I believe that this would result in much sounder code and
would be a huge gain in time as the eventual application would be much more structured and easy
to understand.

I think I will explore this area and revamp the whole project with that idea in mind in a few
monthes (as it is likely to fail I'd rather have a working system before doing experiments).

# Let's get back to futures.

After some thoughts on the API I think I will have 4 ways to interract with Futures (all
done with macros):

*  `complete!(future, value)`: This will complete the future with the provided value.
*  `do_calculations!(future, closure)`: This will apply the closure to the value inside the
Future, and then write the result of the calculation in the Future.
*  `send_result!(future, actor_ref)`: This will take the value in the future and send it
to the actor_ref, then it will drop the future.
*  `extract!(future, Type) -> Type`: This will get the value inside the future in a synchronous
way. This is a way that should be avoided as much as possible.

The plan for implementing the `extract!` macro is to create a channel of type `Type`, spawn
an actor with this channel, have the actor ask for the result to the Future, when the result
is received, send it through the channel and kill itself.

This is the only way I found to extract the value from the future in a synchronous manner and
this should be used as infrequently as possible. The only use case would be if we need to
get values from a future outside of an actor or during the initialization of the actor system
(otherwise we can use `send_result!`), we will mostly need it for tests and the initialization
of the actor system.

So let's get going !

I will make some more notes tomorrow, but the biggest changes now are:

* ActorRef no longer hold a CompleteRef, if we want a Future we have a real one which is
an actor under the hood.
* `ask` disapeared from ActorRef, now we will need to go through the ActorCell or the ActorSystem.

The second one may seem a bit tough, but since Futures are actors now, we need a way to spawn them
which can only be done from an Actor with its ActorCell or by the ActorSystem.

I guess that's it for tonight !

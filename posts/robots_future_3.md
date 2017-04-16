---
title: Designing Robots Futures - Part 3
date: 2016-01-17 20:01:00
Category: RobotS
Tags: RobotS, rust, Future
author: Felix Raimundo
---

The next series of posts on Futures will be my personal notes while implementing, they may not
reflect the final implementation. 
So if you want to see a post detailing the architecture, these are not the post you will be looking
for, nevertheless you may find this read interesting to see how I came to design them the way they
are.

# Looking at what is done elsewhere.

I spent some time looking at the implementation of carllerche's eventual future this weekend.

This has solved some of my issues, first most `Async` operation consume the Future (takes a `self`),
so this solves the issue mentionned on the last post.

This however raises another issue: this means that all calls create a new future, thus the complete
that we keep is not relevant if many closures are called on the future. Thus we can't keep the future
outside of the actor, and the Future is dropped at the end of the `receive` call.

Eventual future thus seem not to work very well for our case.

# Let's implement our own.

Since we want our futures to be closely integrated with the actor system, it seems simpler to just
go and implement futures instead of depending on the ones in eventual.

It does sound like it wil end up in reinventing some form of wheel, but the other option is to
hack / patch around eventual's futures which were not planned to be used in our use case.

## What we want.

As before we want actors to interract with futures as if they were actors and we want them to be
asynchronous (i register closures that wil do something on the result).

A nice to have feature would be to have timeouts and notification  in the case of failures.

## Issue ahead.

We want to store the closures in the Future, but these are most likely not `'static` as we can see in
this [code snippet](https://github.com/gamazeps/RobotS/commit/19b1efda7da7b97479d6de85baaf2958c1bae3ce#diff-e0ac5767a085357f3382796f2aacebd3R59).

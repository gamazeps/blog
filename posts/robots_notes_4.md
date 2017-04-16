---
title: Notes 4
date: 2016-01-26 20:36:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

Today will be a short day on RobotS.

This night I realized that there is a flaw in my implementation of futures. Indeed since
messages are treated in the order they are received my Futures will try to apply the closures
even though they have not been completed yet.

To solutions can be done:
*  Reimplement them by copying a lot of code from the actorcell so that they wait to be completed
to kick in the calculations. But that would imply a fair amount of code duplication.
*  Have the future contain a FIFO of closures and launch them when it receives a completion
message. This is likely less efficient, but requires much less code duplication and is more
consistent, this is the approach I wil follow.

This will imply that I need a way to reschedule an actor 

I think I will also pause a little the work on the future to implement a proper logging / debug
system. This should only take a day, but will likely make the development cycle much faster, it
will also be useful for the users to have logging / debug included in the crate so it seems
like a good feature overall (and a fair way to spend my time).

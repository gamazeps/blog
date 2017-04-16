---
title: Notes 5
date: 2016-01-27 20:36:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

Tonight we will get some things done !

First the logging, needs to be correct.

# Logging

On the advices of people on #rust, I chose to use the `log` and `env_logger` crates, the first
one allows to have simple logging, the second one allows to print the logs.

Overall it is extremely straightforward to include in the code :)

# Debugging the race condition

Activating the logging makes my actor system work, not activating it makes my actor system be
stuck. If i had any doubts about a race condition, now I don't anymore.

The funny thing is that using simple println! instead of info! does not make my system work,
this might be a bit tricky to solve... Doing the logging was a good idea it seems.

Ok... changing all the println! into info! makes the race condition go away (meaning the system
works, the source of the issue is not identified yet).

Ok... The system not working is not reproducible (I mean, not every single time), this is pretty
bad.

It seems that the issue is solved by waiting before exiting the main, this might mean that the
initialization of the system is much slower than before. I have not been able to re reproduce
the problem once I waited longer before xiting my main, thus the explanation might simply be
that the reason why my actors did not print "hello world" is simply that it did not have enough
time to do so.

I'm updating the code in the tests to use the new futures and I'll see if this still happens.

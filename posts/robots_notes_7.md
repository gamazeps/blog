---
title: Notes 7
date: 2016-02-08 21:00:00
Category: RobotS
Tags: RobotS, rust, notes
author: Felix Raimundo
---

# Futures

Now we need to implement the features mentionned in the previous post.

Since I used actors and message passing for the interface it should be pretty easy to change
the previous implementation into the new one, indeed only the logic about how to handle
messages in the Future will need to be changed (or else I coded badly).

Changing the message type was realy fast since I already had my API, so this was nice.

# Work done

I got time to change the implementation of the Future and it works on the examples.

I'm trying to fix the tests now, next will be a documentation update to be done (I know
that i'm supposed to write it as I code, but since the code was *super* unstable it felt like
a waste of time).

While working on the tests it seems that i managed to create a segfault (signal 11) that only
happens when testing (the code in the test is basically the same that `examples/panic.rs`.

The output is pretty fun

```
running 5 tests
test resolve_name_fake_path ... FAILED
test ask_answer_twice ... FAILED
test resolve_name_real_path ... FAILED
thread '<unnamed>' panicked at 'The actor panicked as it was asked to.', test/test.rs:49
test recover_from_panic ... ok
Process didn't exit successfully: `/home/gamazeps/dev/RobotS/target/debug/test-88599447cc0525b5` (signal: 11)

Caused by:
  Process didn't exit successfully: `/home/gamazeps/dev/RobotS/target/debug/test-88599447cc0525b5` (signal: 11)
```

That's pretty weird since it only happens when the actor that is supposed to panick, panicks.
Furthermore, the test exits even before sending any messages, which is incredibly weird.

This segfault issue appeared in other tests, I will need to investigate this more, but this
is very weird. Indeed segfault are only supposed to happen in rust in unsafe code and my
code only contains a single piece of `unsafe`, but the part where it could have caused an issue
went fine.

Actually after some investigation it seems that the issue might very well come from my unsafe
piece. Indeed it takes the value from an Arc and puts it in a box with a `from_raw` and the
value is lastly dereferenced in the `FutureExtractor`.

Sooo I found the issue, I actually misread the [doc](http://doc.rust-lang.org/std/boxed/struct.Box.html#method.from_raw)
when i wrote that unsafe part, `from_raw` can only be used if it comes from an `into_raw`.

Ok so I found why I had this issue, my future can be completed with any given type, I thus needed
to send it a Box&lt;Any>, except that this is obviously not `Sync`, thus I chose to use an
Arc&lt;Any + Send + Sync> and then try to put the content of the Arc into the future.
But doing that was not supported in an obvious way by rust, so I tried to trick it and that was
not smart of me.

I'll try to find a better to send the complete message to a future but i might just put the
message in the mailbox myself.

It is bad because it breaks an invariant which is that messages are copyable.

It is ok, because the data will be put in the future's mailbox and it will then become copyable.

So it does not really break the invariant in the facts, it just feels incredibly fishy.

Sooooo that did not work, because our enum had a variant that was Send + Sync, and one that was
not, so when I try to call a function that requires Send + Sync with the good variant the compiler
complained (it seems that types are determined for the enum, not the variants...).

I also learned that Box&lt;SyncType> was Sync, even though it was nowhere to be found (a core dev
told me so and linked me to the issue on [rustdoc](https://github.com/rust-lang/rust/issues/17606)
) so I tried to put a variant with Arc&lt;Box&lt;Any + Send + Sync + Clone>> but that did not
work because of the [E0225](https://doc.rust-lang.org/error-index.html#E0225) since Clone is
not a builtin trait.

This made me rather unhappy because I have no way to put my completed value directly in the enum
or in an Arc because of the two issues mentionned above.
The only solution left is to put the Box in a Arc&lt;&lt;Mutex>> so that we get Syn, but that's
ridiculisly overkill, especially since we will also need to wrap it in an option to get it out
of the mutex...

I will implement this tomorrow, coding in anger is a bad idea...

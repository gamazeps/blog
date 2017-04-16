---
title: Work Journal again
date: 2016-06-20 21:36:00
Category: Work journal
Tags: notes
author: Felix Raimundo
---

# Rationale

I have not been super efficient these last months code wise and I realized that keeping a work
journal helped me focus on what to do and where to go, thus I am doing that again !


# ChibiOS/RT's tutorial

I started this project a while ago and was not able to continue it.  
But it's changing now, I wrote an article on how to upload a program to an stm32f407discovery board.

I also thought a bit about where I wanted to go with this tutorial and the idea right now would be
to take someone who:

*  Can read and write some C.
*  Knows what a makefile is, but not really how to use it.
*  Some knowledge of threads, mutex and semaphores (I will still provide some link to learn more
   about them).
*  No knowledge of ChibiOS/RT at all.

And bring them to a point where they are confident:

*  Structuring a ChibiOS/RT's project.
*  Reading and writting configuration files for ChibiOS/RT's.
*  Configuring board description files.
*  Instantiate and use the HAL drivers.
*  Writting a ChibiOS/RT's application from the beggining to the end.

This is a bit of an ambitious goal, but it should be doable in a few months and hopefully useful to
a few people.

The structure will be rather short articles to keep it readable and allow people to pick the parts
that they are interested in, but if enough people manifest an interest I could try to structure it
in a book (but that would be in the far too long term for me to say anything).

# RobotS

I also left RobotS hanging for a few months, this was a bad thing to do and I started working on it
again.
Right now I am getting myself familiarized with the code again (and my comments are not so good it
seems, so I'll have to fix that too) and working through estimating the work left to be done.

Basically the most urgent part is to work on the serialization of the data. I think I am going to do
what Roger Johansson did on his [go actor model](https://github.com/rogeralsing/gam) and go for
either protobuf or capnproto everywhere.

Indeed if I want some sort of remoting I will need to send data accross machines, and downcasting
Anys won't do at all, so serialization will be needed super soon.

The real question will be whether to serialize locally to instead of using Any. I find this solution
quite elegant as this makes the code much more consistent.

The only issue I have with this idea is that it is does not let the user chose its serialization
method. But let's consider that this is not a big issue for now and start have something running
first.

# What I did before

I was busy starting a new job, then leaving this job, then looking for a new job so it took some
time... I also followed a few MOOCs that were super interesting (John Hopkins' ones on fMRI are
super cool as are most of their healthcare realted ones).

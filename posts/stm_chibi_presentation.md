---
title: ChibiOS/RT Presentation
date: 2016-02-20 19:36:00
Category: ChibiOS
Tags: chibios, stm32, tutorial
author: Felix Raimundo
---

# What is an embedded Operating System

![ChibiOS](/images/ChibiOS_Embeddedware_Official_Logo.jpg)

I kept on mentionnning that ChibiOS is an embedded OS or embedded RTOS, but what are these things
and why do we need them ?

## Embedded OS

An embedded operating system is basically a small operating system that we can use on embedded
systems, this means that it is light in memory (about 5.5KiB) and gives us some primitives.

Primitives are `blocks` that allow us to do some smart stuff.

In this case, ChibiOS provides us with:

-  Concurency primitives such as mutex, semaphores and threads.
-  Board startup and initialisaton.
-  HAL: Hardware Abstraction Layer, this means that we do not need to code drivers for everything
(we obviously could code our own UART, IC2 or PWM drivers, but not having to do that is rather
nice).
-  Integration with other open source project for file system or networking stack.

You can find some more informations on the
[project's website](http://wiki.chibios.org/dokuwiki/doku.php?id=chibios:documents:introduction)
if you want to.

## Embedded RT/OS

Now what does this RT means ? It means Real Time.

ChibiOS/RT's [website](http://wiki.chibios.org/dokuwiki/doku.php?id=chibios:articles:rtos_concepts)
offers a great explanation of the different concepts.

If you want a quick (and thus less formal) definition of an RTOS: it is an operating system whose
behaviour is deterministic and whose response time is predictable.

In our case we will most likely not have to work on real time problems so this is not a big issue.

Another wildly used RTOS is [FreeRTOS](http://www.freertos.org/index.html), nevertheless it does not
have a HAL and thus we would have some more coding to do in order to get the drivers. Since drivers
are not the focus of this tutorial, I thought that ChibiOS/RT was a better choice.

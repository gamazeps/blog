---
title: What are ChibiOS's drivers ? 
date: 2016-06-25 23:33:00
Category: ChibiOS
Tags: chibios, stm32, tutorial
author: Felix Raimundo
---

In this article I am going to explain what are drivers and why you should use them, thus most people
may not need to read this.

# What's a driver ?

A driver is a software interface that allows you to interract with your hardware. Its job is to make
this interraction much simpler by doing most of the configuration for you, handling interruptions,
running the appropriate code at the appropriate time...

A driver also allows to have a nice abstraction: you don't have to read / write to registers but
simply to use the driver (it does that for you), thus the code is much more portable.

# ChibiOS's HAL

ChibiOS provides a Hardware Abstration Layer with many drivers in it, and these are the ones we are
talking about.

The way to use them is quite similar for each of them:

* Make sure that the support is activated in halconf.h
* Set the driver that you will want to use to `TRUE` in the mcuconf.h
* Generate a configuration for the driver.
* Start the driver with the given configuration.
* Use it :)

# Naming conventions

There are many drivers, but the naming conventions of ChibiOS are pretty straightforward:

If you want to use PWM1 of your board then the corresponding driver is PWMD5.
If you want to use I2C2 of your board then the corresponding driver is I2CD2.
And so on...

In the next articles we will see how to use some specific common drivers such as UART, serial and
PWM.

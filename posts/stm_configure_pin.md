---
title: Configuring a pin
date: 2016-02-21 20:36:00
Category: ChibiOS
Tags: chibios, stm32, tutorial
author: Felix Raimundo
---

# What does configuring a pin means ?

In the last article we saw this line:

```c
// Configures GPIOD pin 14 as output pushpull
palSetPadMode(GPIOD, 14, PAL_MODE_OUTPUT_PUSHPULL);
```

It was explained by saying that we were "configuring" the pin, but what does that mean ?

Most microprocessors have a lot of cool hardware inside them:

*  Timers
*  [PWM]({filename}/blog/stm_pwm_driver.md)
*  ADC
*  DAC
*  I2C
*  SPI
*  UART
*  And so on...

Each pin has access to a few of these hardware functions and thus we have to say which one it is
going to use.

The reason why a lot of hardware function are available to each pin is because this way the
microcontroller is much more multi purpose, which allows to use it for many application cases and
thus makes it cheaper to build than a microcontroller for each application.

Chosing the function you want is done by writting the appropriate configuration in the
microcontroller's register. We could do this by hand or enjoy the use of an abstraction, and ChibiOS
gives us two !

The one that we already saw allows us to configure the pin after the initialization of the board,
but this is not really the recommanded way.

Anyway here is another example of config done this way (repetition is good for learning ;) )

```c
palSetPadMode(GPIOB, 4, PAL_MODE_ALTERNATE(2));
```

Which configures the pin B4 to its Alternate Mode 2 (here a PWM).

The second method is to describe your pinout (what your pins do) in your `board.h` file, but we will
see that later.


# What are all the cool hardware mentionned above ?

Well they will be the subject of following articles that will be added here as they are written.

The basic idea is that your pins can do more than just be set high and low with `palSetPad` and
`palClearPad`.

A pin that only 'knows' HIGH and LOW is called a GPIO, this means General Purpose Input Output,
since it is general it doesn't do much, it can be an output or an input and that's about it.

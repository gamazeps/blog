---
title: Anatomy of a ChbiOS/RT project
date: 2016-06-25 21:33:00
Category: ChibiOS
Tags: chibios, stm32, tutorial
author: Felix Raimundo
---

# Main files of a ChibiOS/RT application

When you created your first ChibiOS/RT project I had you copy an existing one and tweaking it a
little. While it allowed you to have something working quickly we did not explain exactly what were
the files in the project, let's do that now.

A simple `ls project` will give you:

```
➜  ls project 
build  chconf.h  halconf.h  main.c  Makefile  mcuconf.h  readme.txt
```

Let's go over each of these files.

## chconf.h

This file allows you to configure the OS part of ChibiOS/RT.

Here you can enable (or disable) many features, such as threading, synchronization, checks and
options about how your threads run.

The default values in this configuration file are usually correct, so you will probably never have
to change it.

## halconf.h

This file allows you to configure the HAL (Hardware Abstraction Layer) of your project.

Here you can enable or disable device drivers, this is something that you will have to do quite
often.

For example, defining `HAL_USE_I2C` to `TRUE` will allow you to use I2C related code, otherwise the
code will not compile.

```C
/**
 * @brief   Enables the I2C subsystem.
 */
#if !defined(HAL_USE_I2C) || defined(__DOXYGEN__)
#define HAL_USE_I2C                 FALSE
#endif
```

You can see that in the hello LED project that you have `HAL_USE_PAL` set to `TRUE`, indeed we
used the PAL driver when we did:

```C
    palSetPadMode(GPIOD, 15, PAL_MODE_OUTPUT_PUSHPULL);
    // ....
        palSetPad(GPIOD, 15); // sets GPIOD 15 high
        palClearPad(GPIOD, 15); // sets GPIOD 15 low
```

## mcuconf.h

This file allows you to configure the drivers of your project (we will talk later about what the
drivers are).

Let's see what this looks like for the PWM driver:

```c
/*
 * PWM driver system settings.
 */
#define STM32_PWM_USE_ADVANCED              FALSE
#define STM32_PWM_USE_TIM1                  FALSE
#define STM32_PWM_USE_TIM2                  FALSE
#define STM32_PWM_USE_TIM3                  FALSE
#define STM32_PWM_USE_TIM4                  FALSE
#define STM32_PWM_USE_TIM5                  FALSE
#define STM32_PWM_USE_TIM8                  FALSE
#define STM32_PWM_USE_TIM9                  FALSE
#define STM32_PWM_TIM1_IRQ_PRIORITY         7
#define STM32_PWM_TIM2_IRQ_PRIORITY         7
#define STM32_PWM_TIM3_IRQ_PRIORITY         7
#define STM32_PWM_TIM4_IRQ_PRIORITY         7
#define STM32_PWM_TIM5_IRQ_PRIORITY         7
#define STM32_PWM_TIM8_IRQ_PRIORITY         7
#define STM32_PWM_TIM9_IRQ_PRIORITY         7
```

Here you can activate the PWM drivers (there is one for each PWM), and their respective interruption
priorities (we will talk about what that means later).

You can also configure the PLLs of your main clock, this means that you can change the frequency of
your processor clock (we will also talk about that later).

## main.c

You should know what this is :)

## Makefile

The Makefile contains the build instructions of your code, I assume that you have some knowledge of
what a Makefile is, but we will go deeper on how to use ChibiOS/RT's one later.

## board.c, board.h and board.mk

These two files are not present in this demo project (so don't panic if you can't see them), as it
uses the ones of the demo project inside ChibiOS/RT's sources.

These two files allow you to separate the application code from the board configuration, and thus
allowing you to have a more portable code that can be used on multiple boards.

### board.h

This allows you to configure the pins on your board.

You can configure the mode of the pin, its pull-up or pull-down resistors, which alternate function
to use and so on.

It is also good practice to:

* define macros for your pins there (such as `BLUE_LED` or `LEFT_MOTOR`).
* configure your pins in this file instead of using `palSetPadMode`.

### board.c

You can write your board specific initialization code here.

### board.mk

Board specific Makefile, you usualy won't need to have more than:

```Makefile
# List of all the board related files.
BOARDSRC = ../board/board.c

# Required include directories
BOARDINC = ../board
```

You could even get rid of it if your board does not need a Makefile and define these in the
application's Makfile.

# How to organize your project

It is considered a good practice to have a tree looking like:

```
- ChibiOS/RT
- boards
  - board_1
    - board.c
    - board.h
    - board.mk
  - other_boards
- src
  - chconf.h
  - halconf.h
  - main.c
  - Makefile
  - mcuconf.h
  - other.c and .h files
```

That's about it, I hope that this gave you a better understanding on what are the files in a
CHibiOS/RT's project and where to put them.

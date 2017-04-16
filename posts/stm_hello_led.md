---
title: Hello LED !
date: 2016-02-20 20:36:00
Category: ChibiOS
Tags: chibios, stm32, tutorial
author: Felix Raimundo
---

# Hello world !

Just like in most tutorial we will start with a hello world here.

The only issue is that we don't yet know how to make our board print things, so we will have to
make do with blinking an LED (just like in most microcontrollers tutorial actually).

# First things first.

You will need an STM32F407 discovery board for most of these tutorial, so better get one.

![stm32](/images/stm32.jpg)

Once you have that you will need to plug your board to your computer, for that use a mini USB
wire.

![MiniUSB](/images/Mini_usb_AB.jpg)

And that's about it, indeed we are going to use the LEDs already on the board.

# Create a project.

In theory we are supposed to describe which microcontroller we are using, what is plugged
to its pins and so on, hopefully since the board we are using is a common one, there is
already an example in ChibiOS/RT's demos, so let's borrow it.

Remember the file structure we are supposed to have: ChibiOS's sources are at the same
level that the folders that will contain your projects.

```bash
# Go to the folder above chibios.
cp -r ChibiOS/demos/STM32/RT-STM32F407-DISCOVERY Hello
```

Now you need to update the location of ChibiOs's sources in your projects's Makefile. To do so
set the `$CHIBIOS` variable to `../ChibiOS` in Hello/Makefile

You can also change the PROJECT variable to hello instead of ch, it will simply change the name of
the generated binaries to hello.\* instead of ch.\*.

Check that you are able to compile your project:

```
cd Hello
make -j8
```

# Write some code

Now that we have a nice empty project we can start writting some code !

First erase the main.c of the project, we want to write our own one.

Now replace it with the following:

```c
// Include the hardware abstraction layer.
#include “hal.h”
// Inlude ChibiOS's primitives.
#include “ch.h”

int main(void) {
    halInit(); // Initializes hardware abstraction layer.
    chSysInit(); // Initializes ChibiOS kernel.

    // Configures GPIOD pin 15 as output pushpull
    palSetPadMode(GPIOD, 15, PAL_MODE_OUTPUT_PUSHPULL);

    while(1) {
        palSetPad(GPIOD, 15); // sets GPIOD 15 high
        chThdSleepMilliseconds(500); // sleeps for 500ms
        palClearPad(GPIOD, 15); // sets GPIOD 15 low
        chThdSleepMilliseconds(500); // sleeps for 500ms
    }

    // Even though we will never return we still need to add a return value.
    return 0;
}
```

This will make a LED blink on the board with a switch every 0.5 second.

Now let's see what this code does.

```c
// Include the hardware abstraction layer.
#include “hal.h”
// Inlude ChibiOS's primitives.
#include “ch.h”
```

This includes the appropriate libraries to use the HAL (for controlling the LED) and ChibiOS
(for the sleeps).

```c
int main(void) {
    // ...
    // ...
}
```

This is our `main` function, that is (as a first approximation) where we put our code to do things
with the board. Once it returns, the processor will stop doing things.

```c
    halInit(); // Initializes hardware abstraction layer.
    chSysInit(); // Initializes ChibiOS kernel.
```

This initializes the HAL and ChibiOS, you will have that in pretty much all your projects' `main`.

```c
    // Configures GPIOD pin 15 as output pushpull
    palSetPadMode(GPIOD, 15, PAL_MODE_OUTPUT_PUSHPULL);
```

This configures the pin on which the LED is soldered to act as a simple binary output, we will
go into further details into what this configuration means in a later post.

```c
    while(1) {
        palSetPad(GPIOD, 15); // sets GPIOD 15 high
        chThdSleepMilliseconds(500); // sleeps for 500ms
        palClearPad(GPIOD, 15); // sets GPIOD 15 low
        chThdSleepMilliseconds(500); // sleeps for 500ms
    }
```

This is our main execution loop, the program will stay in it (it's a simple `while(true)`).

The `palSetPad` and `palClearPad` functions allow us to set a pin to HIGH or LOW state.  They take
two arguments:

*  The port: In real life, pins are grouped in packs of 16, each pack is called a port (A, B, C...).
*  The pin number: The number of the pin.

Here we want to modify the pin D15, so the port is GPIOD (a pin whose logical state we modify is
called a GPIO) and the pin number is 15.

More documentation can be found
[here](http://chibios.sourceforge.net/docs3/hal/group___p_a_l.html#gaf2c820c1657afa77cdce398329baaf68).

The last function that we see here is `chThdSleepMilliseconds` which simply makes `main` sleep for
500 milliseconds. This actually works for all threads, but we will go into deeper details on that in
posts about threads.

Well that's about it for the code, now you just have to compile it !

```bash
make -j8
ls build # See the generated files.
```

# And now what ?

Now we will need to put the generated binary on the board, but we will see that in the next post,
indeed I do not currently have a board on me so I can't check that what I am saying is correct :/

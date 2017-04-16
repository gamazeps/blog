---
title: Using the PWM driver
date: 2016-06-25 01:33:00
Category: ChibiOS
Tags: chibios, stm32, tutorial
author: Felix Raimundo
---

Disclaimer, this article is currently a work in progress.

In this article we will learn how to configure and use the PWM driver.

# What is PWM ?

PWM stands for Pulse Width Modulation.

This generates a square wave, of which you can control the frequenc, period and ratio of on/off time.
Usually the frequency and period stay the same and what changes is the on/off ratio also called `duty
cycle`.

In the case of your stm32f407discovery board, this signal is a logical one, which means that it goes
from 0V to 5V, and has a low current (about 20mA), it should not be used directly to drive
components that use a lot of current as the board will not be able to provide it and will thus be
damaged.

PWM outputs of a board are usually linked to a reguler timer of your board, each timer can generate
4 PWM channels. These channel have the same clock frequency and period but can have different duty
cycles.

If you want to learn more about them, google is your friend :)

# What's the point of a PWM ?

This part might be the one that will interest you the most.

Since you control the on / off ratio of the PWM, you control the average value of the output, thus
it can be used as a cheap way to generate an analog signal.

Of course the signal is not really analog (you would have to use a DAC for that), but if the
frequency divided by the period is high enough, it can look a lot as if it were (mechanical objects
tend to work as a low pass filter, and thus do the smoothing for you).

You can use this to control the intensity of a LED or the speed of a motor for example (you will
have to use an H bridge in between the board and the motor though).

Some components also use PWM as a way to transmit data, that is the case of some analog servo motors
that take a PWM as input, some sensors also use a PWM as an output (some sonars do that).

# Finding which driver and channel to use

There are three main documents that will be useful to you:

* [STM32f407 reference manual](http://www.st.com/content/ccc/resource/technical/document/reference_manual/3d/6d/5a/66/b4/99/40/d4/DM00031020.pdf/files/DM00031020.pdf/jcr:content/translations/en.DM00031020.pdf)
* [STM32f407 discovery user manual](http://www.st.com/content/ccc/resource/technical/document/user_manual/70/fe/4a/3f/e7/e1/4f/7d/DM00039084.pdf/files/DM00039084.pdf/jcr:content/translations/en.DM00039084.pdf)
* [STM32F407
  datasheet](http://www.st.com/content/ccc/resource/technical/document/datasheet/ef/92/76/6d/bb/c2/4f/f7/DM00037051.pdf/files/DM00037051.pdf/jcr:content/translations/en.DM00037051.pdf)

The first one contains the full documentation for the microcontroller, with all the registers and
how to use them. You will probably need this at some point when ChibiOS's drivers are not enough for
you (it will come sooner than you might think).

The second one is the one that will interest us now. It lets us know which functions are behind
which pin and to what they are wired on the board. For example if we are looking for which pins control the 4 LEDs on the board, we can see that they are PD12-15.

The third one also lets us know which functions are behind which pin, nevertheless it is the only
one to mention which alternate fuctions these functions are.

Since each pin can have multiple functions there is a need to say which one is used, this is the
alternate function number mentionned above.

Here we will want to control the LEDs on the board, thus we are going to use the PWM4 which is the
Alternate Function 2 of the pins PD12-15.

Note: If you found this part a bit tricky it's perfectly normal, you will get used to it after some
time :)

# Configuring the PWM

You have to touch two configuration files `halconf.h` and `mcuconf.h` in order to properly use your
PWM.

In the first one you have to enable the PWM subsystem by setting `HAL_USE_PWM` to `TRUE`.

In the second one you have the followong defines related to PWM

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

The first line allows you to activate the advanced functions of TIM1 and TIM8, you will probably not
need this for now.

Then you have the `STM32_PWM_USE_TIM*` which allow you to use the driver.

Finally you have the `STM32_PWM_TIM*_IRQ_PRIORITY` which allow you to set the priority of the
interruptions generated by this timer, for now the default values are good enough and we will not
have to touch these.

# Configuring a PWM driver.

The configuration structure is a PWMConfig whose definition is the following for the
stm32f407dicovery, if you are using another board go to
[this page]({filename}/blog/stm_find_port_hal.md) to find the appropriate configuration.

```c 
/**
 * @brief   Type of a PWM driver configuration structure.
 */
typedef struct {
  /** 
   * @brief   Timer clock in Hz.
   * @note    The low level can use assertions in order to catch invalid
   *          frequency specifications.
   */
  uint32_t                  frequency;
  /** 
   * @brief   PWM period in ticks.
   * @note    The low level can use assertions in order to catch invalid
   *          period specifications.
   */
  pwmcnt_t                  period;
  /** 
   * @brief Periodic callback pointer.
   * @note  This callback is invoked on PWM counter reset. If set to
   *        @p NULL then the callback is disabled.
   */
  pwmcallback_t             callback;
  /** 
   * @brief Channels configurations.
   */
  PWMChannelConfig          channels[PWM_CHANNELS];
  /* End of the mandatory fields.*/
  /** 
   * @brief TIM CR2 register initialization data.
   * @note  The value of this field should normally be equal to zero.
   */
  uint32_t                  cr2;
#if STM32_PWM_USE_ADVANCED || defined(__DOXYGEN__)
  /** 
   * @brief TIM BDTR (break & dead-time) register initialization data.
   * @note  The value of this field should normally be equal to zero.
   */                                                                     \   
   uint32_t                 bdtr;
#endif
   /** 
    * @brief TIM DIER register initialization data.
    * @note  The value of this field should normally be equal to zero.
    * @note  Only the DMA-related bits can be specified in this field.
    */
   uint32_t                 dier;
} PWMConfig;
```

Let's go over each parameter:

* frequency: Be careful to note that this is the frequency of the clock, not the frequency of the
  square wave !
* period: This is the period in ticks, thus the frequency of the wave is frequency / period.
* callback: Pointer to a function called each time a period of the timer is over.
* channels: see below.
* cr2, btdr and dier: set them to zero, you will probably never use them anyway.

## PWMChannelConfig

Here is the definition of a PWMChannelConfig:

```c
/**
 * @brief   Type of a PWM driver channel configuration structure.
 */
typedef struct {
  /**
   * @brief Channel active logic level.
   */
  pwmmode_t                 mode;
  /**
   * @brief Channel callback pointer.
   * @note  This callback is invoked on the channel compare event. If set to
   *        @p NULL then the callback is disabled.
   */
  pwmcallback_t             callback;
  /* End of the mandatory fields.*/
} PWMChannelConfig;
```

The mode can be one of the following three:

* `PWM_OUTPUT_DISABLED`: Output not driven, callback only.
* `PWM_OUTPUT_ACTIVE_HIGH`: Positive PWM logic, active is logic level one.
* `PWM_OUTPUT_ACTIVE_LOW`: Inverse PWM logic, active is logic level zero.

The callback is a function that will be called each time the state goes from active to inactive for
that channel.

## Example configuration

Here is a simple configuration that uses the first three channel of a PWM and which has a period of
~0.01s.

```c
static const PWMConfig led_pwm_config = {
  100000,   /* 100Khz PWM clock frequency
  1024,     /* PWM period of 1024 ticks ~ 0.01 second*/
  NULL,     /* No callback at the end of a period. */
  { 
    {PWM_OUTPUT_ACTIVE_HIGH, NULL}, /* First channel used as an active PWM with no callback. */
    {PWM_OUTPUT_ACTIVE_HIGH, NULL}, /* Second channel used as an active PWM with no callback. */
    {PWM_OUTPUT_ACTIVE_HIGH, NULL}, /* Third channel used as an active PWM with no callback. */
    {PWM_OUTPUT_DISABLED, NULL} /* Fourth channel not used */
  },
  0,        /* Zero, as the doc says. */
  0,        /* Zero, as the doc says. */
};
```

# Using a PWM driver

Now that we know how to write a PWMConfig we may want to use it on a PWMDriver and also finding out
what can be done with such a driver.

## What can be done with a driver.

The functions that are the most useful to us will be:

```
void pwmStart(PWMDriver *pwmp, const PWMConfig *config);
void pwmStop(PWMDriver *pwmp);
void pwmChangePeriod(PWMDriver *pwmp, pwmcnt_t period);
void pwmEnableChannel(PWMDriver *pwmp,
                      pwmchannel_t channel,
                      pwmcnt_t width);
void pwmDisableChannel(PWMDriver *pwmp, pwmchannel_t channel);
```

Note that `PWMDriver` structs (and those for each other driver too) are global objects defined by
ChibiOS, thus if you want to use the driver of the 4th PWM, just use PWMD4 (which is defined by
ChibiOs).

### pwmStart

This starts a PWM driver with the given configuration.

A driver needs to be started before being used.

```c
static const PWMConfig dummy_conf {
    // ....
}

void init_leds_pwm(void) {
    pwmStart(&PWMD4, &dummy_conf);
    // Do things with the PWMDriver.
}
```

### pwmStop

This stops the driver and it thus cannot be used afterwards (unless started again), you will
probably never use it.

```c
pwmStart(&PWMD4, &dummy_conf); // Start the driver.
// Do things with the driver.
pwmStop(&PWMD4); // We are done with the driver.
```

### pwmChangePeriod

Changes the period in ticks, pretty straightforward.

### pwmEnableChannel

This is what you will use the most.

Allows you to set the number of ticks after which the PWM becomes inactive (the duty cycle), note
that this is given in tick.

```c
// Here we are using the led_pwm_config defined above.
pwmEnableChannel(&PWMD4, 0, 256); // on a quarter of the time.
pwmEnableChannel(&PWMD4, 0, 512); // on half of the time.
pwmEnableChannel(&PWMD4, 0, 768); // on three quarters of the time.
```

Note that `pwmchannel_t` start at 0.

### pwmDisableChannel

This disables the channel, meaning that there is no output any more and that the callback is not
called any more.

To make it enabled again, call `pwmEnableChannel`.

## Example: Fading a LED

Here is an example that has a LED fade:

Start by copying the hello led project, then we will have a few changes to make.

First you will need to activate the PWM subsystem in `halconf.h`.

```c
#define HAL_USE_PWM                 TRUE
```

Looking at the documentation linked above we can see that the blue LED on PD15 is linked to the
fourth channel of PWM4, thus we will need to activate PWMD4.

In order to do so, change the `mcuconf.h` so that you have:

```c
#define STM32_PWM_USE_TIM4                  TRUE
```

Then we will need to set the alternate function of PD15, looking at the document we can see that
`TIM4_CH4` is the alternate function 2. For this tutorial we will not use the `board.h` to do that,
but the `palSetPadMode` function seen before.

```c
#include "ch.h"
#include "hal.h"

static const PWMConfig led_pwm_config = {
  100000,   /* 100Khz PWM clock frequency */
  1024,     /* PWM period of 1024 ticks ~ 0.01 second*/
  NULL,     /* No callback at the end of a period. */
  { 
    {PWM_OUTPUT_DISABLED, NULL},
    {PWM_OUTPUT_DISABLED, NULL},
    {PWM_OUTPUT_DISABLED, NULL},
    {PWM_OUTPUT_ACTIVE_HIGH, NULL}, // Only the blue LED activated.
  },
  0,        /* Zero, as the doc says. */
  0,        /* Zero, as the doc says. */
};

int main(void) {
    halInit();
    chSysInit();

    palSetPadMode(GPIOD, 15, PAL_MODE_ALTERNATE(2));

    pwmStart(&PWMD4, &led_pwm_config);

    int intensity = 0;

    while(1) {
        pwmEnableChannel(&PWMD4, 3, (intensity++) % 1024);
        chThdSleepMilliseconds(1); // sleeps for 1ms
    }
    
    return 0;
}
```

## Example: Regular pwm using only callbacks.

Here we will do the same thing that we did before but by using callbacks.

FIXME: this does not work, but why ? Note that this is supposed to work in theory...

```c
#include "ch.h"
#include "hal.h"

static void clear_pad(PWMDriver* dummy) {
    (void) dummy;
    palClearPad(GPIOD, 15);
}

static void set_pad(PWMDriver* dummy) {
    (void) dummy;
    palSetPad(GPIOD, 15);
}

static const PWMConfig led_pwm_config = {
  100000,   /* 100Khz PWM clock frequency */
  1024,     /* PWM period of 1024 ticks ~ 0.01 second*/
  clear_pad,     /* Set the led on at the end of the period. */
  { 
    {PWM_OUTPUT_DISABLED, NULL},
    {PWM_OUTPUT_DISABLED, NULL},
    {PWM_OUTPUT_DISABLED, NULL},
    {PWM_OUTPUT_DISABLED, set_pad}, /* Set the led off when the timer changes state. */
  },
  0,        /* Zero, as the doc says. */
  0,        /* Zero, as the doc says. */
  0,        /* Zero, as the doc says. */
};

int main(void) {
    halInit();
    chSysInit();

    palSetPadMode(GPIOD, 15, PAL_MODE_OUTPUT_PUSHPULL); 

    int intensity = 0;

    pwmStart(&PWMD3, &led_pwm_config);

    while(1) {
        pwmEnableChannel(&PWMD3, 3, (intensity++)%1024);
        chThdSleepMilliseconds(1); // sleeps for 1ms
    }

    return 0;
}
```

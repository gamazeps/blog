---
title: Finding the hal configurations for your board
date: 2016-07-04 19:00:00
Category: ChibiOS
Tags: chibios, stm32, tutorial
author: Felix Raimundo
---

In many articles I refer to the configuration structures used in the HAL for the stm32f407
microcontroller, but there are many more microcontrollers in the world and you may have another one,
thus I am going to tell you how to find the configuration for your board.

First go to your folder containing ChibiOS/RT's sources, then do
```bash
cd os/hal/ports
```

You can find the various ports there:
```bash
➜  ports git:(master) ✗ ls
AVR  common  KINETIS  LPC  simulator  STM32
➜  ports git:(master) ✗ ls AVR  # show AVR's port headers
adc_lld.c  avr_pins.h    gpt_lld.c  hal_lld.c  i2c_lld.c  icu_lld.c  pal_lld.c  platform.mk
pwm_lld.h     serial_lld.h  spi_lld.h  st_lld.h
adc_lld.h  avr_timers.h  gpt_lld.h  hal_lld.h  i2c_lld.h  icu_lld.h  pal_lld.h  pwm_lld.c
serial_lld.c  spi_lld.c     st_lld.c
➜  ports git:(master) ✗ ls STM32 # show STM32 port headers
LLD  STM32F0xx  STM32F1xx  STM32F37x  STM32F3xx  STM32F4xx  STM32F7xx  STM32L0xx  STM32L1xx
STM32L4xx
```

For example if we wanted to see the PWM headers for stm32f407 we would look at:
```bash
➜  ports git:(master) ✗ ls STM32/LLD/TIMv1 
gpt_lld.c  gpt_lld.h  icu_lld.c  icu_lld.h  pwm_lld.c  pwm_lld.h  st_lld.c  st_lld.h  stm32_tim.c
stm32_tim.h  tim_irq_mapping.txt
```

Note that LLD stands for `Low Level Driver`, here the file that we were looking for is `pwm_lld.h`.

I hope this helps you find your ports hal headers.

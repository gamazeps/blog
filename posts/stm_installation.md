---
title: Installation
date: 2016-02-19 19:36:00
Category: ChibiOS
Tags: chibios, stm32, tutorial
author: Felix Raimundo
---

# Cross Compiler

In order to be able to compile and load your programs on a chip you will need some toolings.

In our case we will compile code for an stm32f407 chip (with an ARM cortex M4 processor), this
means that the code will be executed on this processor and not your computer's one.

The thing is that most personal computer have Intel processor, either 32 or 64 bits
(x86 or x86-64), and your targeted processor may very well have a different architecture. 
In our case the targetted architecture is a 32 bits ARM processor, so binaries generated
for my 64 bits Intel processor will definitely not run on our targetted processor.

This is why we need `cross compilation`. This allows you to compile code for a different
architecture on your computer.

Since I (and most likely you too) have an Intel processor and will target an ARM processor
you will need a cross compilation toolchain to work.

The recommended one is `arm-none-eabi`, it contains a compiler, debugger, disassembler and
much more.

You can find it [there](https://launchpad.net/gcc-arm-embedded), follow the
[README](https://launchpadlibrarian.net/231136492/readme.txt) for the installation.

BIG FAT WARNING: DO NOT USE THE 2015Q4 VERSION !
Indeed chibios causes ld to crash on this version of gcc, thus use the previous one
(or the next one when it is out there).

If you are too lazy to follow it you can do the following on linux:

```bash
# put what you want as $install_dir, for me it is /opt/ARM
cd $install_dir && tar xjf gcc-arm-none-eabi-*-yyyymmdd-mac.tar.bz2
echo 'PATH="$PATH:$install_dir/gcc-arm-none-eabi-*/bin"' >> ~/.zshrc # or .bashrc if you want.

# On 64 bit system you will need a 32 bit version of libc and libncurses
apt-get install libc6-i386 libncurses5:i386
```

You should be able to compile a dummy file like

```c
int main() {
    return 0;
}
```

with the following command:

```bash
arm-none-eabi-gcc -c test.c
```

# ChibiOS/RT

This is the embedded RT/OS that we will use in this tutorial, so we kinda have to get it too.

There are two ways of getting it:

*  From the [download page](http://www.chibios.org/dokuwiki/doku.php?id=chibios:downloads:start)
of the project that will lead you to sourceforge.
*  From the [github repository]().

I recommand the second one as sourceforge is currently a source of all sorts of malware, but you
are adults (maybe).

You should now have ChibiOS/RT's sources on your computer I will ask you to follow the same
structure as I do, this will be easier for everybody this way.

```bash
tree
.
├── ChibiOS
# many stuffs inside chibi
└── src
```

Now just try:

```bash
cd ChibiOS/STM32/HAL-STM32F407-DISCOVERY
make
```

This should give an output like this:

```
Compiler Options
arm-none-eabi-gcc -c -mcpu=cortex-m4 -O2 -ggdb -fomit-frame-pointer -falign-functions=16 -ffunction-sections -fdata-sections -fno-common -flto -Wall -Wextra -Wundef -Wstrict-prototypes -Wa,-alms=build/lst/ -DCORTEX_USE_FPU=FALSE -DTHUMB_PRESENT -mno-thumb-interwork -DTHUMB_NO_INTERWORKING -MD -MP -MF .dep/build.d -I. -I../../../os/common/startup/ARMCMx/compilers/GCC -I../../../os/common/startup/ARMCMx/devices/STM32F4xx -I../../../os/common/ext/CMSIS/include -I../../../os/common/ext/CMSIS/ST/STM32F4xx -I../../../os/hal/osal/os-less/ARMCMx -I../../../os/hal/include -I../../../os/hal/ports/common/ARMCMx -I../../../os/hal/ports/STM32/STM32F4xx -I../../../os/hal/ports/STM32/LLD/ADCv2 -I../../../os/hal/ports/STM32/LLD/CANv1 -I../../../os/hal/ports/STM32/LLD/DACv1 -I../../../os/hal/ports/STM32/LLD/DMAv2 -I../../../os/hal/ports/STM32/LLD/EXTIv1 -I../../../os/hal/ports/STM32/LLD/GPIOv2 -I../../../os/hal/ports/STM32/LLD/I2Cv1 -I../../../os/hal/ports/STM32/LLD/MACv1 -I../../../os/hal/ports/STM32/LLD/OTGv1 -I../../../os/hal/ports/STM32/LLD/RTCv2 -I../../../os/hal/ports/STM32/LLD/SDIOv1 -I../../../os/hal/ports/STM32/LLD/SPIv1 -I../../../os/hal/ports/STM32/LLD/TIMv1 -I../../../os/hal/ports/STM32/LLD/USARTv1 -I../../../os/hal/ports/STM32/LLD/xWDGv1 -I../../../os/hal/boards/ST_STM32F4_DISCOVERY -I../../../os/various main.c -o main.o

Compiling crt0_v7m.s
Compiling crt1.c
Compiling vectors.c
Compiling osal.c
Compiling hal.c
Compiling st.c
Compiling hal_buffers.c
Compiling hal_queues.c
Compiling hal_mmcsd.c
Compiling pal.c
Compiling serial.c
Compiling nvic.c
Compiling hal_lld.c
Compiling stm32_dma.c
Compiling st_lld.c
Compiling pal_lld.c
Compiling serial_lld.c
Compiling board.c
Compiling main.c
Linking build/ch.elf
Creating build/ch.hex
Creating build/ch.bin
Creating build/ch.dmp

   text    data     bss     dec     hex filename
   3184     448  131072  134704   20e30 build/ch.elf
Creating build/ch.list

Done
```

# OpenOCD

OpenOCD is an "Open On-Chip Debugger", this is what we will use to put programs on the board,
stop a program, inspect the register and more.

On Ubuntu you can simply apt-get it (if it is not allready installed):

```bash
apt-get install openocd
```

And that's it you have installed most things to be able to program your board.

Now that you have done the boring stuff you can grab a beer (or any other liquid you feel
confortable with).

In the next part I will quickly explain what ChibiOS/RT does for us and why we use it.

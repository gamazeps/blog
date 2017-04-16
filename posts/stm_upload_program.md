---
title: Upload your programs to your board
date: 2016-06-20 16:47:00
Category: ChibiOS
Tags: chibios, stm32, tutorial, openocd, armn-none-eabi-gdb, tooling
author: Felix Raimundo
---

In a previous article we saw how to compile a "Hello LED", but did not actually run this program
on a board, thus it was a bit useless.

Let's now see how we can put a program on a board and what are the tools involved in this operation.

# Launch an openocd server

First you will need to launch an openocd server, this allows you to connect yourself to your board.

The command here (on ubuntu at least) is:

```bash
openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg
```

The -f option allows you to specify the path to the configuration file that will be used to connect 
to the board.  
Such a file provides information about the link type, the frequency of the transmission, the
endianness and so on... You will never have to write such a file yourself in this tutorial
and will probably never have to write one at all (except if your job is firmware engineer).

You should have an output looking like:

```
Open On-Chip Debugger 0.9.0 (2015-09-02-10:42)
Licensed under GNU GPL v2
For bug reports, read
    http://openocd.org/doc/doxygen/bugs.html
Info : The selected transport took over low-level target control. The results might differ compared
to plain JTAG/SWD
adapter speed: 2000 kHz
adapter_nsrst_delay: 100
none separate
srst_only separate srst_nogate srst_open_drain connect_deassert_srst
Info : Unable to match requested speed 2000 kHz, using 1800 kHz
Info : Unable to match requested speed 2000 kHz, using 1800 kHz
Info : clock speed 1800 kHz
Info : STLINK v2 JTAG v25 API v2 SWIM v0 VID 0x0483 PID 0x3748
Info : using stlink api v2
Info : Target voltage: 2.891618
Info : stm32f4x.cpu: hardware has 6 breakpoints, 4 watchpoint
```

If the output looks like:

```
Open On-Chip Debugger 0.9.0 (2015-09-02-10:42)
Licensed under GNU GPL v2
For bug reports, read
    http://openocd.org/doc/doxygen/bugs.html
Info : The selected transport took over low-level target control. The results might differ compared
to plain JTAG/SWD
adapter speed: 2000 kHz
adapter_nsrst_delay: 100
none separate
srst_only separate srst_nogate srst_open_drain connect_deassert_srst
Info : Unable to match requested speed 2000 kHz, using 1800 kHz
Info : Unable to match requested speed 2000 kHz, using 1800 kHz
Info : clock speed 1800 kHz
Error: open failed
in procedure 'init' 
in procedure 'ocd_bouncer'
```

This means that you have not plugged your board in, or that it is not recognized by your computer.

# Launch arm-none-eabi-gdb

Now that we have an interface to the board we will have to interract with it in some ways, that's
where gdb comes at play !

gdb is the GNU debugger, it allows us to controll the flow of execution of our program, and in this
instance to do that on the board, from our own computer.

First launch gdb and provide it a path to the binary that we are going to use (here the Hello
LED one).

```bash
arm-none-eabi-gdb build/ch.elf
```

You should see:

```
➜  project arm-none-eabi-gdb build/ch.elf
GNU gdb (GNU Tools for ARM Embedded Processors) 7.8.0.20150604-cvs
Copyright (C) 2014 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "--host=i686-linux-gnu --target=arm-none-eabi".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from build/ch.elf...done.
```

## Connect to the board

Now that we have a running gdb we will need to connect ourselve to the board, that's why we launched
(and kept running) opencd.

In order to connect to it, type the following command in the gdb prompt.

```
(gdb) target extended-remote localhost:3333
```

Here we tell gdb that our target is a remote one (not on your machine) and that we can conect
to it through port 3333 (which has been open by openocd).

## Put the program on the board

Once this is done you now have control over the board.

First you will want to stop the program currently beeing executed with:

```
(gdb) mon halt
```

Then you will want to load your program on the board

```
(gdb) load
```

And then you can either tell the board to reset itself (with the new program) or you can launch it
and surveil it with gdb

```
(gdb) mon reset
```

```
(gdb) continue
```

If you did that you should see a blue LED blink on your board.  
Congratulation you just upload your first program to a board (at least to this one) !

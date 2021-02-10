---
layout: post
title: "Why does DOS needs multiple stacks"
---

In CP/M and DOS systems, it is customary that a module of code uses its own stack area.
This is to be contrasted to the single-stack model that got popular with C and unix.

This happened in a time where memory was quite a scarcity, so stacks were kept rather small.
IBM PC compatible machines have a 8259 interrupt controller which allows for nestable hardware interrupts.
This created the risk of overflowing the stack of software modules.
To accomodate this risk, MS-DOS shipped with the `STACKS=` functionality.
When enabled in the `CONFIG.SYS`, this hooked into the interrupt vectors and installed code that activated a stack dedicated for the handling of this interrupt request.

When a user program was running (with a limited stack) and a hardware interrupt triggered, the user program stack only needed space to accomodate the interrupt return frame (iret).
The stack data used by the interrupt handler was not present in the space of the user program, which was less likely to suffer a stack overflow.

## The question

Reading the documentation for the `STACKS=` directive in DOS, i was thrown off by the fact that MS-DOS doesn't allocate one big, but several stacks.
DOS is a single-tasking system, there is no multi-taking, so all stacks inherently have an inner/outer order, with inner stacks being switched to after a call, and outer stacks being switched to before a return.

Example: When a interrupt routine interrupts an user program and temporarily uses its own stack, the stack for the interrupt handler is what i call 'inner' and the user stack is what i call 'outer'.
Before a return to the user program, the inner stack needs to be disabled and the outer stack activated, because thats where the return address into the user program is.
This forces some linear order between all stacks of different modules.

But, if the stacks have a linear order, why does MS-DOS use multiple stacks inside itself?
It could use a single stack, and instead of allocating a new inner stack, just continue to use the outer stack for the same purpose.
Omitting that switch would make calls and returns across drivers and resident programs (which are separate modules) much easier.

## The answer

I spent several hours consulting physical books.
None of the DOS books i own explained this seemingly odd choice, not even "DOS Internals" from Robert S. Lai.

The MS-DOS Bible (also from the Waite Group) didn't explain it, but it gave the decisive hint - the stack switching was located in Chapter 13 "Terminate and Stay Resident Programs", subchapter "The Problem of Reentry".

Thinking through possible scenarios of re-entry, i found a edge case that actually breaks if the kernel only has a single, large stack:

1. The DOS kernel gets invoked as part of a DOS syscall
2. The kernel switches to its own stack, processes the syscall and calls out to a driver (imagine a disk driver for file access)
3. The driver is a software module on its own, and as such, sets up an own stack for itself
4. During the stack switching the previous pointer for the kernel stack is recorded by the driver
5. While the driver is processing, a hardware interrupt triggers
6. Control goes to the kernel, via the entry point for the hardware interrupt
7. The kernel is supposed to switch from the previous stack (from the driver) to the 'inner' stack area.
   The correct address to continue on the kernel stack is only known to the driver at this point.
   The kernel would be unable to correctly determine the new stack pointer.

The DOS kernel works around this problem by switching to a completely new stack area, and leaving the previous one untouched.
This is sufficient to explain that the kernel alone needs at least two stacks.

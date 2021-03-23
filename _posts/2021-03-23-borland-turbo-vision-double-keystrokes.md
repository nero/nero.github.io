---
layout: post
title: "DOS: Keystroke duplication with Borland Turbo Vision"
---

To keep it short: Programs compiled with Turbo Vision (including their IDE itself) exhibit a bug in QEMU and dosbox.

The bug manifests in that certain keypresses are duplicated, like arrow keys or PgUp and PgDown.
The keys in specific are keys that use a two-byte scancode instead of a single byte.
The bug could only be reproduced on emulators, like QEMU and DOSBox, but not on real hardware.

Another user from the FreeDOS channel provided me with assembly source of keyboard handling code that seems to be inserted into every compiled program.
I translated the source from the assembly dialect it was it (probably TASM) to the NASM syntax, and was able to successfully reproduce this issue.

The keyboard controller of the IBM AT and up sits at IO ports 0x60 and up, reading from IO port 0x60 will fetch the byte that is currently in the keyboard receive buffer.
The Borland code hooks into the IRQ 1 (Interrupt 9h) and does some sort of special handling for certain key combinations.
To do this handling, it reads the value of the keyboard receive buffer to detect whether a key requires special handling.
After that, it proceeds to the original BIOS handler, which reads the IO port again to do regular keyboard processing.

On real hardware, the Borland code and BIOS will read the same keycode, so the BIOS is able to properly place the keydown word in the Bios Data Area.

In emulators, reading from port 0x60 has the side effect of advancing the read pointer for the emulated keyboard controller buffer.
Reading the IO port twice results in different byte values, meaning that the BIOS will not be able to see certain bytes.

The details on how the BIOS is unable to correctly handle this situations is unclear, but via experimentation i found out that the prefix for key-up events (which add another byte to the 1- or 2-byte sequences) gets lost to the BIOS.
This resulted in the KeyUp event being mistakenly interpreted as a KeyDown event. KeyDown and KeyUp makes two, thats where the duplication comes from.

Since the Borland code only added special handling for 5 key combinations (Alt+Space, and Alt+ and Ctrl+ for Del and Ins each), a trivial workaround was possible:

By blocking the request to replace interrupt vector 9, the interrupt chaining does not take place, and the BIOS handles the keycodes alone without interference.
This does not create additional hazzle since the compiled programs still use the regular keyboard buffer from the BIOS to read the keyboard input.

Related discussions:

- https://www.virtualbox.org/ticket/58
- https://qemu-devel.nongnu.narkive.com/EfYtQYUC/patch-0-of-1-fix-for-dos-keyboard-problems

The NASM source for the TSR program that prevents interrupt 9 modification is following.

```
		org 0x100

		jmp setup

int21handler:	; check if program wants to replace int 9
		cmp ax, 0x2509
		jne chain
		; just return to program, do nothing
		iret
chain:		; other syscall, jump to DOS
		; addr is overwritten by set-up
		jmp 0xFFFF:0x0000

setup:		; get old vector
		mov ax, 0x3521
		int 0x21
		; bail out if we detect ourselves
		cmp bx, int21handler
		je .ret
		; vector is now in ES:BX, save it
		mov [chain+1], bx
		mov [chain+1+2], es
		; install our own handler
		mov ah, 0x25
		mov dx, int21handler
		int 0x21
		; print our banner
		mov dx, banner
		mov ah, 9
		int 0x21
		; terminate and stay resident
		mov ax, 0x3100
		mov dx, 0x11 ; PSP + 16 bytes
		int 0x21
.ret:		ret

banner:		db "kbd interrupt locked",0x0A,0x0D,"$"
```

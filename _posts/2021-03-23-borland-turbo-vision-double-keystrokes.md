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
This does not create additional hassle since the compiled programs still use the regular keyboard buffer from the BIOS to read the keyboard input.

Related discussions:

- [https://www.virtualbox.org/ticket/58](https://www.virtualbox.org/ticket/58)
- [https://qemu-devel.nongnu.narkive.com/EfYtQYUC/patch-0-of-1-fix-for-dos-keyboard-problems](https://qemu-devel.nongnu.narkive.com/EfYtQYUC/patch-0-of-1-fix-for-dos-keyboard-problems)
- [https://github.com/Ringdingcoder/qemu/commit/4160700f875b780e73099624938cffb7f82141ff](https://github.com/Ringdingcoder/qemu/commit/4160700f875b780e73099624938cffb7f82141ff)

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

The code for the reproduction program is following here:

```
		org 0x100

main:		mov word [outpos], 0

		; get old vector
		mov ax, 0x3509
		int 0x21
		; vector is now in ES:BX, save it
		mov [oldint9], bx
		mov [oldint9+2], es
		; install our own handler
		mov ah, 0x25
		mov dx, int9handler
		int 0x21

		; loop reading data
read:		xor ax, ax
		int 0x16

		cmp ax, 0x011B
		je end

		push ax
		call printf
		db "From buffer: ",2,0x0A,0x0D,0

		call flush

		jmp read

end:		; restore keyb handler
		lds dx, [cs:oldint9]
		mov ax, 0x2509
		int 0x21
		ret

section .bss

printr:
.ax:	resw 1
.cx:	resw 1
.dx:	resw 1
.bx:	resw 1

section .text

; Stack contents
; ret-addr arg1 arg2 arg3 ...

printf:		mov [cs:printr.ax], ax
		mov [cs:printr.cx], cx
		mov [cs:printr.dx], dx
		mov [cs:printr.bx], bx
		pop bx

.loop:		mov al, [cs:bx]
		inc bx

		cmp al, 0
		je .end
		cmp al, 1
		je .byte
		cmp al, 2
		je .word

		call pputc

		jmp .loop

.end:		push bx
		mov ax, [cs:printr.ax]
		mov cx, [cs:printr.cx]
		mov dx, [cs:printr.dx]
		mov bx, [cs:printr.bx]
		ret

.word:		pop dx
		call pdx
		jmp printf.loop

.byte:		pop dx
		mov dh, dl
		call pdx.l1
		jmp printf.loop

pdx:		; this double-call is essentially a 4 times repeating loop
		call .l1
.l1:		call .l2
.l2:		; set up cl for bit shifts
		mov cl, 4
		; grab highest nibble from dx
		mov al, dh
		; remove highest nibble from dx
		shl dx, cl
		; shift away second-highest nibble that we accidentally copied
		shr al, cl
		; map 0-9 to ascii codes for '0' to '9'
		add al, 0x30
		; if result is larger than '9', ...
		cmp al, 0x3a
		jl pputc
		; ... add 7 so we continue at 'A'
		add al, 7
pputc:		jmp putc

section .bss

outpos:		resb 2 ; l=in, h=out
outbuf:		resb 256

section .text

flush:		push bx
.loop:		mov bx, word [outpos]
		; return if buffer empty
		cmp bl, bh
		je .ret
		; read char
		xchg bh, bl
		mov bh, 0
		mov al, [outbuf+bx]
		; update read ptr
		inc bl
		mov [outpos+1], bl
		; send char to bios
		mov ah, 0x0e
		xor bx, bx
		int 0x10
		jmp .loop
.ret:		pop bx
		ret

putc:		push bx
		mov bx, word [cs:outpos]
		; skip if buffer full
		inc bl
		cmp bl, bh
		je .ret
		; store character
		mov bh, 0
		dec bl
		mov [cs:outbuf+bx], al
		inc bl
		; write back updated ptr
		mov byte [cs:outpos], bl
.ret		pop bx
		ret

putnib:		push ax
		and al, 0xF
		cmp al, 0xA
		jc .noadj
		add al, 7
.noadj:		add al, 0x30
		call putc
		pop ax
		ret

putbyte:	push ax
		push cx
		mov cl, 4
		shr ax, cl
		pop cx
		call putnib
		pop ax
		call putnib
		ret

putword:	xchg ah, al
		call putbyte
		xchg ah, al
		call putbyte
		ret

section .rodata

scSpaceKey:	equ	0x39
scInsKey:	equ	0x52
scDelKey:	equ	0x53

kbShiftKey:	equ	0x03
kbCtrlKey:	equ	0x04
kbAltKey:	equ	0x08

KeyConvertTab:	db scSpaceKey,kbAltKey
		dw 0x0200
		db scInsKey,kbCtrlKey
		dw 0x0400
		db scInsKey,kbShiftKey
		dw 0x0500
		db scDelKey,kbCtrlKey
		dw 0x0600
		db scDelKey,kbShiftKey
		dw 0x0700
.end:

KeyConvertCnt:	equ ((KeyConvertTab.end-KeyConvertTab)/4)

section .bss

oldint9:	resb 4

section .text

KeyFlags:	equ 0x17
KeyBufHead:	equ 0x1A
KeyBufTail:	equ 0x1C
KeyBufOrg:	equ 0x1E
KeyBufEnd:	equ 0x3E

int9handler:	push ds
		push di
		push ax
		; set bios segment
		mov ax, 0x40
		mov ds, ax
		; save current tail ptr of buffer
		; we later check if it has changed
		mov di, word [KeyBufTail]
		; read the value from hw
		in al, 0x60

		push ax
		call printf
		db "Int9: 0x60 read AL=",1,0x0A,0x0D,0

		; second read for debugging
		; feel free to comment out
		in al, 0x60
		push ax
		call printf
		db "Int9: secondary 0x60 read AL=",1,0x0A,0x0D,0

		mov ah, byte [KeyFlags]
		; simulate interrupt to upstream handler
		pushf
		call far [cs:oldint9]
		; ignore key-ups
		test al, 0x80
		jne .l09

		push si
		push cx
		; load ptr and length of key table
		mov si,[cs:KeyConvertTab]
		mov cx,KeyConvertCnt

		; search for key in keytab
		; compare scancode
.l01:		cmp al, byte [cs:si]
		jne .l02
		; bit-test modifier key flags
		test ah, [cs:si+1]
		jnz .l03
.l02:		; go forward in loop, count down CX
		add si, 4
		loop .l01
		; jump out after exhausting CX
		jmp short .l08
.l03:		; we copied KeyBuftail contents earlier
		; if its changed, it means that bios inserted a key
		; and we can replace the value written by bios
		cmp di, [KeyBufTail]
		jne .l05
		; test if we are at end of keyboard buffer
		mov ax, di
		inc ax
		inc ax
		cmp ax, KeyBufEnd
		jne .l04
		; revert to start of buffer if we are
		mov ax, KeyBufOrg
.l04:		; bail out of head == tail, keyboard buffer full
		cmp ax, [KeyBufHead]
		je .l08
		; update keyboard in ptr
		mov [KeyBufTail],ax
		mov di, ax
		; insert our keycode into buffer
.l05:		mov ax, [cs:si+2]
		mov [ds:di], ax
		; restore registers
.l08:		pop cx
		pop si
.l09:		pop ax
		pop di
		pop ds
		iret
```

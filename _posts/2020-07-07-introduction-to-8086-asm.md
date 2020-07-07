---
layout: post
title: "Introduction to 8086 assembly"
---

The [8086](https://en.wikipedia.org/wiki/Intel_8086) is a microprocessor designed and produced by Intel.
It got popular with the IBM PC, from which the market-dominating x86 architecture developed from.

This post focuses on helping people to quickly get a simple program running.

As precondition, you need to have the following programs installed in your unix system:

- the `nasm` assembler
- `qemu-system-x86_64` (other x86 variants work as well)

## Basic explanation of assembly

Assembly code shows one instruction per line.
Instructions can make use of registers, immediate values and various forms of memory accesses.

```
	mov dl, 0x37
```

This loads the DL register with the hexadecimal number for a '7' digit.
DL refers to the lower 8 bits of the 16 bit DX register (D Low).
After an instruction was executed, the CPU will go for the instruction on the next line unless its a jump or similar instruction.

```
	mov al, dl
```

This transfers the '7' into al.

```
	mov ah, 0x0e
	int 0x10
```

This interfaces with the bios routines: `int 0x10` invokes the software interrupt 16, which is per convention the entry point for video display functions.
What these interrupts do can be read in the [RBIL](http://www.ctyme.com/intr/int.htm).
The AH register is used to identify a specific subfunction of the interrupt service.
The arguments are placed in pre-defined registers (character in AL in our case).

```
loop:	
	jmp loop
```

The `loop` isn't an instruction here, its a label.
A label refers to the address where it was written.
The jump command transfers control to the instruction at the position of the label.
Because this is the jump instruction itself, this is a infinite loop to prevent the computer from crashing.

## Building a basic program

Save the following program in a file (conventionally, assembly code has the .asm extension).

```
	; absolute address where our code will be loaded by the BIOS
	org 0x7C00

	mov dl, 0x37
	mov al, dl
	mov ah, 0x0e
	int 0x10
loop:
	jmp loop

	; fill area with zeros until we get to the position of the boot sector signature
	times (0x1FE - ($-$$)) db 0
	dw 0xAA55
```

With `nasm -o prog.bin prog.asm` you can compile the assembly code into a binary file, with `qemu-system-x86_64 -hda prog.bin` you can launch it.

The code above has a proper boot sector signature 510 bytes into the assembled binary.
QEMU will pass it as hard disk to the guest system.
The guest BIOS will see the boot signature, recognize it as bootable disk, load the first 512 bytes at absolute address 0x7C00 in memory and execute it with a jump.

If everything worked correctly, the code will print out the '7' that was written into DL.

## Next steps

The [NASM Appendix A](http://www.posix.nl/linuxassembly/nasmdochtml/nasmdoca.html) has an extensive list of supported instructions and registers.
Take note that not any instruction can take all form of operands, and that not all registers can be used as a pointer.

[Ralf Browns Interrupt List](http://www.ctyme.com/intr/int.htm) has a extensive list of BIOS interrupt services.
Take note that not every function documented there is available in the bootsector environment, where our code runs.

## Proper initialisation

Directly after the `org` statement, you should set up the segment registers and stack pointer to make sure they are in a defined state:

```
	org 0x7C00

	; Set AX to zero (we dont know what BIOS left in there)
	mov ax, 0

	; DS and ES set the base address for memory accesses, for example: mov ax, [0x413]
	mov ds, ax
	mov es, ax

	; A proper stack allows us to back up register values
	mov ss, ax
	mov sp, 0x7C00 ; stack grows to lower addresses, towards 0

```

## Procedure calls

Example procedure:

```
putc:
	mov ah, 0x0e
	mov bx, 7
	int 0x10
	ret
```

This procedure is invoked via `call putc`.
The argument is given here via AL and not touched until being passed to the interrupt function.
You are free to decide how arguments will be passed to your procedure (in C, this would be part of the ABI definition).

One thing that needs to be considered: If you place the procedure above your main code, the CPU might directly run into it in error and might return to a random place in memory and behave in unwanted ways - a 'crash'.
You can avoid this with a jump instruction at the beginning of your code, which jump to a label preceding your main code.

## Saving registers

The 8086 only has 8 general purpose registers, and one of them is the stack pointer and thus not normally usable for normal calculations.
You can temporarily save registers to the stack:

```
	; set AX to an important value

	push ax

	; set AX to something else

	pop ax ; restore AX to old value
```

## Debugging

If you are fine with printf-style debugging, you can download my [debug rom](https://yin.neocities.org/rdos/debug.rom) and add it to your qemu command line with `-option-rom debug.rom`.

If its loaded, everytime you let the CPU execute an `int 3` instruction, it prints the 8086 register set with its values in hexadecimal.

It also catches some kinds of fatal errors, printing some useful information instead of letting the machine silently crash.

## Observing the binary result

By adding `-l prog.lst` to the nasm command line, assembling will also generate a listing file containing both a hexdump of the binary instructions and their corresponding source line.

To disassemble your binary, run `ndisasm -b 16 -o 0x7C00 prog.bin`. This will not result in your original sourcecode, but might help you understanding whats going on in a binary.

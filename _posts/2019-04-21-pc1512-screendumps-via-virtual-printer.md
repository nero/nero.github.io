---
layout: post
title: "PC1512: Screendumps via virtual printer"
---

A while ago i got a Amstrad Schneider PC1512 from a hacker, who himself got it from their granddad.

Early 2019, i felt tempted to write an OS for this.
For documenting the journey, i felt it necessary to have a way to extract display data.
The Amstrad BIOS already has screendump functionality that works regardless of the currently running OS/program, as long as the screen is used in text and not in graphics mode.

Said functionality copies the contents of the text screen buffer to the printer port, which is a female DB-25 port.
The protocol is simple - it has 8 data ports and 3 lines for bidirectional synchronisation.

To get the data into another computer, i thought out to use a Arduino Nano to read the parallel data and emit it via serial console.
The Nano already has:

- a stable clock source of 16MHz, so the baud rate for the serial is reliable
- an on-board USB-to-Serial converter, so im able to interface it via MicroUSB
- enough pins to actually read the data
- several unused specimens in my stuff boxes

Traditionally, i program these using C + avr-gcc + avrdude.

The only port the Nano has that is completely wired out is PORTD.
Unfortunately, PD1 is the serial output port, so i split up the data lines between the lower nibble of PORTB (PB0-PB3) and the upper nibble of PORTD (PD4-PD7).

The non-standalone C program (the uart_tx is a driver from my avr-firmwares.git):

```
#include "drivers/uart_tx.h"
#include <avr/io.h>
#include <util/delay.h>

void wait_strobe_on() { // active low
	while((PIND >> PD2) & 1) {};
}

void wait_strobe_off() {
	while(~(PIND >> PD2) & 1) {};
}

void ack_on() { // active low
	PORTD &= ~(1 << PD3);
}

void ack_off() {
	PORTD |= (1 << PD3);
}

void busy_on() { // active high
	PORTB |= (1 << PB4);
}

void busy_off() {
	PORTB &= ~(1 << PB4);
}

int main(void) {
	// STROBE input is on PD2
	// PB0-PB3 and PD4-PD7 are data inputs
	DDRD = (1 << PD3); // ACK output
	DDRB = (1 << PB4); // BUSY output

	// pull-up per default
	PORTD |= (1 << PD2) |  (1 << PD3);

	uint8_t i, data;

	for(;;) {
		wait_strobe_on();
		data = (PIND & 0xF0) | (PINB & 0x0F);
		busy_on();
		ack_on();
		_delay_us(10); // 5 us minimum
		ack_off();

		// this blocks until written
		uart_putc(data);

		busy_off();
		// make sure we are not reading the same char again
		wait_strobe_off();
	}
}
```

The synchronous operation of the parallel port makes the program synchronous as well and keeps it simple.

I soldered the 8 data lines, 3 control lines and ground from the Nano to a male DB25 port, connected both ends and `cat`'ed the tty device after configuring it.

Pressing `Shift+PrtScr` on the PC1512 resulted in the screen buffer indeed appearing on my screen, except that non-ascii characters were garbled.
I typed some umlauts before repeating the screen dump, this time dumping the contents into a file.

With `hexdump -Cv` i inspected the byte values for the garbled characters and matched their values with the code pages tables on wikipedia, quickly identifying the US/Latin codepage 437.
This seems a bit off, since the machine itself is hard-coded into a german keyboard layout and also outputs german error messages.

By post-processing the screendumps via `iconv -f CP437 -t UTF-8`, i was able to produce unicode-compatible data:

```
                                                                                
A»FDD [A] C»HDD [C] F6ComDtct F8RomBoot                                         
(c)1986 AMSTRAD Consumer Electronics plc                                        
                                                                                
Zuletzt benutzt um 05:00 am 01 Januar 1980                                      
                                                                                
                                                                                
-=XTIDE Universal BIOS (XT)=- @ CE00h                                           
v2.0.0ß3+ (2013-04-03)                                                          
Released under GNU GPL v2                                                       
                                                                                
Master at 300h: SanDisk SDCFJ-512                                               
Booting A»A                                                                     
                                                                                
A>ECHO OFF                                                                      
--- MOUSE Geräte Treiber v5.00 installiert---                                   
                                                                                
A>ö=ä=ü=Ö=Ä=Ü=ß                                                                 
Befehl oder Dateiname falsch                                                    
                                                                                
A>                                                                              
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
```

# Uncomment lines below if you have problems with $PATH
#SHELL := /bin/bash
#PATH := /usr/local/bin:$(PATH)

all:
	@echo "Pick between: make arduino-mega, arduino-uno, midi-uno, midi-mega"

arduino-mega:
	-dfu-programmer atmega16u2 erase
	sleep 2
	dfu-programmer atmega16u2 flash Arduino-usbserial-mega.hex
	sleep 2
	dfu-programmer atmega16u2 reset

arduino-uno:
	-dfu-programmer atmega16u2 erase
	sleep 2
	dfu-programmer atmega16u2 flash Arduino-usbserial-uno.hex
	sleep 2
	dfu-programmer atmega16u2 reset

midi-mega:
	-dfu-programmer atmega16u2 erase
	sleep 2
	dfu-programmer atmega16u2 flash fakeyfakey-mega.hex
	sleep 2
	dfu-programmer atmega16u2 reset

midi-uno:
	-dfu-programmer atmega16u2 erase
	sleep 2
	dfu-programmer atmega16u2 flash fakeyfakey-uno.hex
	sleep 2
	dfu-programmer atmega16u2 reset

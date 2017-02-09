# Uncomment lines below if you have problems with $PATH
#SHELL := /bin/bash
#PATH := /usr/local/bin:$(PATH)

all:
	@echo "Pick between: make arduino-mega, arduino-uno, midi-uno, midi-mega"

arduino:
	-dfu-programmer atmega16u2 erase
	sleep 2
	dfu-programmer atmega16u2 flash Arduino-usbserial-mega.hex
	sleep 2
	dfu-programmer atmega16u2 reset

midi:
	-dfu-programmer atmega16u2 erase
	sleep 2
	dfu-programmer atmega16u2 flash fakeyfakey-mega.hex
	sleep 2
	dfu-programmer atmega16u2 reset

# Uncomment lines below if you have problems with $PATH
#SHELL := /bin/bash
#PATH := /usr/local/bin:$(PATH)

all:
	@echo "Pick between: make arduino and make midi"

arduino:
	dfu-programmer atmega16u2 erase
	dfu-programmer atmega16u2 flash Arduino-usbserial-uno.hex
	dfu-programmer atmega16u2 reset

midi:
	dfu-programmer atmega16u2 erase
	dfu-programmer atmega16u2 flash fakeyfakey.hex
	dfu-programmer atmega16u2 reset

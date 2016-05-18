#include <MIDI.h>

// Simple tutorial on how to receive and send MIDI messages.
// Here, when receiving any message on channel 4, the Arduino
// will blink a led and play back a note for 1 second.

MIDI_CREATE_DEFAULT_INSTANCE();

#define LED 13           // LED pin on Arduino Uno

void setup()
{
    pinMode(LED, OUTPUT);
    MIDI.begin(4);          // Launch MIDI and listen to channel 4
}

void loop()
{
  MIDI.sendNoteOn( 64, 127, 10 );
  delay(500);
  MIDI.sendNoteOff( 64, 127, 10 );
  delay(500);
}

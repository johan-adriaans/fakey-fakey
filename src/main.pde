#include <MIDI.h>
#include "RunningAverage.h"

MIDI_CREATE_DEFAULT_INSTANCE();

// Configuration
#define TOUCH_THRESHOLD  480
#define SERIAL_DEBUG_MODE

int touchPins[6] = {0,1,2,3,4,5}; // The analog pins that are to register touch events
int raw[6] = {1024, 1024, 1024, 1024, 1024, 1024}; // Raw analog input values
bool playing[6] = {false,false,false,false,false,false}; // Is the MIDI note playing or not
int midiNotes[6] = {64,65,66,67,68,69};

// Moving average object filters
RunningAverage avgFilter[6] = {
  RunningAverage(20),
  RunningAverage(20),
  RunningAverage(20),
  RunningAverage(20),
  RunningAverage(20),
  RunningAverage(20)
};

int touchPinCount = 0;

void setup()
{
  #ifdef SERIAL_DEBUG_MODE
    Serial.begin(31250);
  #else
    MIDI.begin(4); // Launch MIDI and listen to channel 4
  #endif

  touchPinCount = (int) sizeof(touchPins) / sizeof(int);
}

void loop()
{
  for ( int i = 0 ; i < touchPinCount; i++ ) {
    avgFilter[i].addValue( analogRead( touchPins[i] ) );
    raw[i] = avgFilter[i].getAverage();

    if ( raw[i]  <= TOUCH_THRESHOLD && !playing[i] ) {
      #ifdef SERIAL_DEBUG_MODE
        Serial.print( "Pin " );
        Serial.print( i );
        Serial.print( " was touched with power: " );
        Serial.print( raw[i] );
        Serial.print( "\n" );
      #else
        MIDI.sendNoteOn( midiNotes[i], 127, 10 );
      #endif
      playing[i] = true;
    }
    if ( playing[i] && raw[i] > TOUCH_THRESHOLD ) {
      #ifdef SERIAL_DEBUG_MODE
        Serial.print( "Pin " );
        Serial.print( i );
        Serial.print( " was released" );
        Serial.print( "\n" );
      #else
        MIDI.sendNoteOff( midiNotes[i], 127, 10 );
      #endif
      playing[i] = false;
    }
  }
}

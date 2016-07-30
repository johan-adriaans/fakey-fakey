#include <MIDI.h>
#include "RunningAverage.h"

MIDI_CREATE_DEFAULT_INSTANCE();

// Configuration
#define TOUCH_THRESHOLD  600
// TODO: Hier een max threshold voor de release inbouwen :)
#define SERIAL_DEBUG_MODE

int potPins[2] = {8,9};
int potNotes[2] = {12,13};
int potVal[2] = {0,0};
int prevPotVal[2] = {0,0};
int touchPins[6] = {0,1,2,3,4,5}; // The analog pins that are to register touch events
int raw[6] = {1024, 1024, 1024, 1024, 1024, 1024}; // Raw analog input values
bool playing[6] = {false,false,false,false,false,false}; // Is the MIDI note playing or not
int touchNotes[6] = {41,43,45,36,38,40};

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
int potPinCount = 0;

void setup()
{
  #ifdef SERIAL_DEBUG_MODE
    Serial.begin(31250);
  #else
    MIDI.begin(4); // Launch MIDI and listen to channel 4
  #endif

  touchPinCount = (int) sizeof(touchPins) / sizeof(int);
  potPinCount = (int) sizeof(potPins) / sizeof(int);
}

void loop()
{
  for ( int i = 0 ; i < potPinCount; i++ ) {
    potVal[i] = analogRead( potPins[i] );
    if ( abs( potVal[i] - prevPotVal[i] ) > 25 ) {
      #ifdef SERIAL_DEBUG_MODE
        Serial.print( "Pot value " );
        Serial.print( i );
        Serial.print( " is " );
        Serial.print( potVal[i] );
        Serial.print( "\n" );
      #else
        MIDI.sendControlChange( potNotes[i], potVal[i]/8, 10 );
      #endif
      prevPotVal[i] = potVal[i];
    }
  }
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
        MIDI.sendNoteOn( touchNotes[i], 127, 10 );
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
        MIDI.sendNoteOff( touchNotes[i], 127, 10 );
      #endif
      playing[i] = false;
    }
  }
}

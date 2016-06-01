#include <MIDI.h>
#include <MovingAverageFilter.h>

MIDI_CREATE_DEFAULT_INSTANCE();

MovingAverageFilter movingAverageFilter1(20);
MovingAverageFilter movingAverageFilter2(20);

int analogPin1 = 0;
int raw1 = 0;
bool playing1 = false;

int analogPin2 = 1;
int raw2 = 0;
bool playing2 = false;

void setup()
{
  //MIDI.begin(4);          // Launch MIDI and listen to channel 4
  Serial.begin(9600);
}

void loop()
{
  raw1 = movingAverageFilter1.process( analogRead( analogPin1 ) );
  if( raw1 ) {
    Serial.println(raw1);
  }

  /*
  raw1 = analogRead( analogPin1 );
  if( raw1 ) {
    raw1 = runningAverage( raw1 );
    if ( raw1 > 265 && !playing1 ) {
      MIDI.sendNoteOn( 64, 127, 10 );
      playing1 = true;
    }
    if ( playing1 && raw1 < 265 ) {
      MIDI.sendNoteOff( 64, 127, 10 );
      playing1 = false;
    }
  }

  // Hmm.. Hij meet nu het verschil tussen de algemene + en - en daardoor triggert hij altijd beide signalen..
  raw2 = analogRead( analogPin2 );
  if( raw2 ) {
    raw2 = runningAverage( raw2 );
    if ( raw2 > 265 && !playing2 ) {
      MIDI.sendNoteOn( 67, 127, 10 );
      playing2 = true;
    }
    if ( playing2 && raw2 < 265 ) {
      MIDI.sendNoteOff( 67, 127, 10 );
      playing2 = false;
    }
  }
  */
}

#include <MIDI.h>

MIDI_CREATE_DEFAULT_INSTANCE();

int analogPin1 = 0;
int raw1 = 0;
bool playing1 = false;

int analogPin2 = 1;
int raw2 = 0;
bool playing2 = false;

void setup()
{
  MIDI.begin(4);          // Launch MIDI and listen to channel 4
}

long runningAverage(float M) {
  #define LM_SIZE 25
  static float LM[LM_SIZE];
  static byte index = 0;
  static long sum = 0;
  static byte count = 0;

  // keep sum updated to improve speed.
  sum -= LM[index];
  LM[index] = M;
  sum += LM[index];
  index++;
  index = index % LM_SIZE;
  if (count < LM_SIZE) count++;

  return sum / count;
}

void loop()
{
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
}

#include <MIDI.h>

MIDI_CREATE_DEFAULT_INSTANCE();

int analogPin= 0;
int raw= 0;
int Vin= 5;
float Vout= 0;
float R1= 10000000;
float R2= 0;
float buffer= 0;

void setup()
{
  MIDI.begin(4);          // Launch MIDI and listen to channel 4
  //Serial.begin(31250);
}

long runningAverage(float M) {
  #define LM_SIZE 10
  static float LM[LM_SIZE];      // LastMeasurements
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
  raw= analogRead(analogPin);
  if( raw ) {
    raw = runningAverage( raw );
    buffer = raw * Vin;
    Vout = (buffer)/1024.0;
    if ( Vout > 2 ) {
      MIDI.sendNoteOn( 64, 127, 10 );
      delay(500);
      MIDI.sendNoteOff( 64, 127, 10 );
      //Serial.print("Vout: ");
      //Serial.println(Vout);
    }
    //delay(100);
  }
}

#include <MIDI.h>

MIDI_CREATE_DEFAULT_INSTANCE();

#define ledPin 13 // PORTB7 is used as a led to show if note 0 is detecting touch
#define timeTestPin 12 // PORTB6 is used as an output test pin for osc

// Configure debouncing
#define MAX_DETECT_COUNT 80
#define UPPER_THRESH 40
#define LOWER_THRESH 10

uint8_t potPins[4] = {9,11,13,15};
uint8_t potNotes[4] = {12,13,14,15};
uint16_t potVal[4] = {0,0,0,0};
uint16_t prevPotVal[4] = {0,0,0,0};

bool playing[8] = {false,false,false,false,false,false,false,false}; // Is the MIDI note playing or not
uint8_t touchNotes[8] = {41,43,45,36,38,40,39,37};

uint8_t dRead[8] = {0,0,0,0,0,0,0,0};
bool pinState[8] = {0,0,0,0,0,0,0,0};
uint8_t touchPinCount = 8;
uint8_t potPinCount = 4;

uint8_t pinBuffer;
uint8_t mask;

void setup()
{
  // Init debug ports, 13 for led, reacts to port 0, 12 shows interrupt duration
  DDRB |= (1 << 7);         // Set port 13 to output
  DDRB |= (1 << 6);         // Set port 12 to output

  MIDI.begin(4);            // Launch MIDI and listen to channel 4

  // initialize timer1
  noInterrupts();           // disable all interrupts
  TCCR1A = 0;
  TCCR1B = 0;

  TCNT1 = 61536;            // preload timer = 65536-16000000/4kHz
  TCCR1B |= (1 << CS10);    // 1 prescaler
  TIMSK1 |= (1 << TOIE1);   // enable timer overflow interrupt
  interrupts();             // enable all interrupts
}

ISR(TIMER1_OVF_vect)        // interrupt service routine that wraps a user defined function supplied by attachInterrupt
{
  PORTB |= (1 << 6);        // port 12
  TCNT1 = 61536;            // preload timer
  pinBuffer = PINC;
  mask = 1;
  for ( unsigned char i = 0; i < 8; i++ ) {
    if ( pinBuffer & mask ) {
      if ( dRead[i] > 0  ) {
        dRead[i]--;
        if ( dRead[i] < LOWER_THRESH ) {
          pinState[i] = false;
        }
      }
    } else {
      if ( dRead[i] < MAX_DETECT_COUNT ) {
        dRead[i]++;
        if ( dRead[i] > UPPER_THRESH ) {
          pinState[i] = true;
        }
      }
    }
    mask = mask << 1;
  }
  PORTB &= ~(1 << 6);
}

void loop()
{
  for ( int i = 0 ; i < touchPinCount; i++ ) {
    if ( pinState[i] && !playing[i] ) {
      MIDI.sendNoteOn( touchNotes[i], 127, 10 );
      playing[i] = true;
    }
    if ( playing[i] && !pinState[i] ) {
      MIDI.sendNoteOff( touchNotes[i], 127, 10 );
      playing[i] = false;
    }
  }

  for ( int i = 0 ; i < potPinCount; i++ ) {
    potVal[i] = analogRead( potPins[i] );
    if ( abs( potVal[i] - prevPotVal[i] ) > 25 ) {
      MIDI.sendControlChange( potNotes[i], potVal[i]/8, 10 );
      prevPotVal[i] = potVal[i];
    }
  }

  // Onboard led test
  if ( pinState[0] ) {
    PORTB |= (1 << 7); // Turn on port 13
  } else {
    PORTB &= ~(1 << 7); // Turn off port 13
  }
}

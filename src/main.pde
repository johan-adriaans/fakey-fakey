#include <MIDI.h>

// Atmega datasheet: http://www.atmel.com/Images/Atmel-2549-8-bit-AVR-Microcontroller-ATmega640-1280-1281-2560-2561_datasheet.pdf
// Pinmapping: https://www.arduino.cc/en/Hacking/PinMapping2560

// #define DEBUG 1

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

bool playing[4] = {false,false,false,false}; // Is the MIDI note playing or not
uint8_t touchNotes[4] = {36,38,40,41};

uint8_t dRead[4] = {0,0,0,0};
bool pinState[4] = {0,0,0,0};
uint8_t touchPinCount = 4;
uint8_t potPinCount = 4;

void setup()
{
  // Init debug ports, 13 for led, reacts to port 0, 12 shows interrupt duration
  DDRB |= (1 << 7);         // Set port 13 to output
  DDRB |= (1 << 6);         // Set port 12 to output

  #if defined DEBUG
    Serial.begin( 31250 );
  #else
    MIDI.begin(4);          // Launch MIDI and listen to channel 4
  #endif

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
  PORTB |= (1 << 6);        // Turn on port 12 for scope reading
  TCNT1 = 61536;            // preload timer

  // Define pins for direct port manipulation
  // PC7 = Digital pin 30
  // PC3 = Digital pin 34
  // PD7 = Digital pin 38
  // PL7 = Digital pin 42
  uint8_t pinPort[4] = {PINC, PINC, PIND, PINL};
  uint8_t pinMask[4] = {PC7, PC3, PD7, PL7};

  for ( unsigned char i = 0; i < 4; i++ ) {
    if ( pinPort[i] & (1 << pinMask[i]) ) {
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
  }

  PORTB &= ~(1 << 6); // Turn off port 12
}

void loop()
{
  for ( int i = 0 ; i < touchPinCount; i++ ) {
    if ( pinState[i] && !playing[i] ) {
      #if defined DEBUG
        Serial.print( "Pin is now playing: " );
        Serial.println( i, DEC );
      #else
        MIDI.sendNoteOn( touchNotes[i], 127, 10 );
      #endif
      playing[i] = true;
    }
    if ( playing[i] && !pinState[i] ) {
      #if defined DEBUG
        Serial.print( "Pin is now off: " );
        Serial.println( i, DEC );
      #else
        MIDI.sendNoteOff( touchNotes[i], 127, 10 );
      #endif
      playing[i] = false;
    }
  }

  for ( int i = 0 ; i < potPinCount; i++ ) {
    potVal[i] = analogRead( potPins[i] );

    // Invert pot direction
    potVal[i] = 1024 - potVal[i];

    if ( abs( potVal[i] - prevPotVal[i] ) > 10 ) {
      #if defined DEBUG
        Serial.print( "Pot " );
        Serial.print( i, DEC );
        Serial.print( " is now: " );
        Serial.println( potVal[i], DEC );
      #else
        MIDI.sendControlChange( potNotes[i], potVal[i]/8, 10 );
      #endif
      prevPotVal[i] = potVal[i];
    }
  }

  // Onboard led test for first pin
  if ( pinState[0] ) {
    PORTB |= (1 << 7); // Turn on port 13
  } else {
    PORTB &= ~(1 << 7); // Turn off port 13
  }
}

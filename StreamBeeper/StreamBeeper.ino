/**
 * StreamBeeper
 * Author: @Bradley_Dice for @WJCTECH
 * Send Morse messages via buzzer from Serial input.
 */

#include <morse.h>

#define PIN_SPEAKER	11

MorseSender *callsignSender;

void setup()
{
  Serial.begin(9600);
  callsignSender = new SpeakerMorseSender(PIN_SPEAKER, 440, CARRIER_FREQUENCY_NONE, 20);
  callsignSender->setup();
}

void loop()
{
  while(Serial.available()){
    char c = Serial.read();
    String outputLetter = String(c);
    outputLetter.toLowerCase();
    callsignSender->setMessage(outputLetter);
    Serial.write(c);
    callsignSender->sendBlocking();
  }
}

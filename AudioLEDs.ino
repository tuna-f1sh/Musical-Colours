/**
A script to pulse an RGB LED array depending on the amplitude of a sound input

John Whittington @j_whittington - June 2011
engineer.john-whittington.co.uk
**/

//LED Pins
int GLED = 3;
int RLED = 5;
int BLED = 6;
//Wave input
int phonoPin = A0;
//Program Variables
int phonoValue = 0;
int amp = 0;
int zero = 130;
int ampMax = 0;
int scale = 0;

void setup() {
//  Serial.begin(9600);
  //Define pins as outputs
  pinMode(GLED, OUTPUT);
  pinMode(RLED, OUTPUT);
  pinMode(BLED, OUTPUT);
  //Find the zero refernce at boot (start music after a few seconds for this reason)
  zero = analogRead(phonoPin);
}

void loop() {
  //Read the value of the ADC
  phonoValue = analogRead(phonoPin);
  //Get the relative value
  amp = abs(phonoValue - zero);
  
  //Find the max of the range for leveling
  if (amp > ampMax) {
    ampMax = amp;
  }   
  
  //Find the scale for the 8bit DAC 
  scale = 255/ampMax;
  //Write the scaled amp to the LED voltage
  analogWrite(3, amp*scale);
  analogWrite(5, amp*scale);
  analogWrite(6, amp*scale);
  
//  Serial.println(amp);
  //Delay the next run
  delay(100);
  
}




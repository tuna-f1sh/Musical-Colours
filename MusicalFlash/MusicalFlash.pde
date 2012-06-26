/**
This script simply uses the BeatDetect function to flash the RGB LED on the beat.

John Whittington @j_whittington - June 2012
**/

//Import
import processing.serial.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import cc.arduino.*;

Minim minim;
AudioInput song;
BeatDetect beat;
BeatListener bl;
Arduino arduino;

//Variables
int GreenPin =  6;    // Green Pin
int RedPin =  5;    // Red Pin
int BluePin =  3;    // Blue Pin
//Colour voltage definitions
int G = 255;
int R = 255;
int B = 255;

//Text size variable for beat display
float txtSize;

void setup() {
  size(512, 200, P3D);
  
  minim = new Minim(this);
  //Setup the arduino
  arduino = new Arduino(this, Arduino.list()[1], 57600);
  
  //Take the linein, this can be a song using minim.loadFile (see FreqEnergy example)
  song = minim.getLineIn(Minim.STEREO, 512);
  // set to SOUND_ENERGY mode (not args)
  beat = new BeatDetect();
  beat.setSensitivity(10);  
  txtSize = 16;
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, song);  
  textFont(createFont("Helvetica", 16));
  textAlign(CENTER);
    
  //Setup arduino outputs
  arduino.pinMode(GreenPin, Arduino.OUTPUT);    
  arduino.pinMode(RedPin, Arduino.OUTPUT);  
  arduino.pinMode(BluePin, Arduino.OUTPUT); 
 
}

void draw() {
  background(0);
  fill(255,0,0);
 
  //Making the LEDs flash          
  if(beat.isOnset()) { //Bass flashes on a beat
    arduino.analogWrite(GreenPin, G);
    arduino.analogWrite(RedPin, R);
    arduino.analogWrite(BluePin, B);
    txtSize = 32; 
  }
  //Turn off LEDs between beats, I just turn bass off so it really flashes on a beat.
  //turning the others other creates a nasty strobe effect
  arduino.analogWrite(GreenPin, 0);    // set the LED off
  arduino.analogWrite(RedPin, 0);    // set the LED off
  arduino.analogWrite(BluePin, 0);    // set the LED off
    
  //Visually show a beat on screen  
  textSize(txtSize);
  text("BEAT", width/2, height/2);
  txtSize = constrain(txtSize * 0.95, 16, 32);
  
}

void stop() {
  // always close Minim audio classes when you are finished with them
  song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}

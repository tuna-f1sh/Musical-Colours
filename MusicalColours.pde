/**
This script takes the line in of the computer sound card and extracts Forward Fourier Transform (FFT). The spectrum is then
broken into Bass, Mid and Treble and amplitude of each used to flash an LED. The Bass section is only flashed on detection of a beat,
using BeatDetect.

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
FFT fft;

//Variables
int GreenPin =  6;    // Green Pin
int RedPin =  5;    // Red Pin
int BluePin =  3;    // Blue Pin
//Colour voltage definitions
int G = 255;
int R = 255;
int B = 255;

//Freq range variables
int BassAmp = 0;
int MidAmp = 0;
int TreAmp = 0;
int MaxBass = 0;
int MaxMid = 0;
int MaxTre = 0;

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
  beat.setSensitivity(300);  
  txtSize = 16;
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, song);  
  textFont(createFont("Helvetica", 16));
  textAlign(CENTER);
  
  fft = new FFT(song.bufferSize(),song.sampleRate());
  
  //Setup arduino outputs
  arduino.pinMode(GreenPin, Arduino.OUTPUT);    
  arduino.pinMode(RedPin, Arduino.OUTPUT);  
  arduino.pinMode(BluePin, Arduino.OUTPUT); 
 
}

void draw() {
  background(0);
  fill(255,0,0);
  stroke(255);
  
  fft.forward(song.mix);
  
  //Get the amplitudes of sound ranges
  for(int i = 0; i <= 20; i++) {
    BassAmp = BassAmp + floor(fft.getBand(i));   
  }
  
  for(int i = 20; i <= 60; i++) {
    MidAmp = MidAmp + floor(fft.getBand(i));
  }
  
  for(int i = 60; i < fft.specSize(); i++) {
    TreAmp = TreAmp + floor(fft.getBand(i));
  }
  
  //Audio leveling (the amplitude depends on the volume of your line in and so need leveling)
  if (BassAmp > MaxBass) {
      MaxBass = BassAmp;
  }
  
  if (MidAmp > MaxMid) {
      MaxMid = MidAmp;
  }
  
  if (TreAmp > MaxTre) {
      MaxTre = TreAmp;
  }
  
  int BassLvl = 255 - MaxBass;
  int TreLvl = 0;
  int MidLvl = 0;
  if (TreAmp > 5) {
    TreLvl = 255 - MaxTre;
  } else {
    TreLvl = 0;
  }
  
  if (MidAmp > 5) {
    MidLvl = 255 - MaxMid;
  } else {
    MidLvl = 0;
  }
  
  //Making the LEDs flash          
  if(beat.isOnset()) { //Bass flashes on a beat
    arduino.analogWrite(GreenPin, G);
    txtSize = 32; }
  //The others flash around the beats, depending on the amplitude  
  else {
    arduino.analogWrite(RedPin, TreLvl+TreAmp);
    arduino.analogWrite(BluePin, MidLvl+MidAmp);
  }
    
//  }
  
  //Turn off LEDs between beats, I just turn bass off so it really flashes on a beat.
  //turning the others other creates a nasty strobe effect
  arduino.analogWrite(GreenPin, 0);    // set the LED off
//  arduino.analogWrite(RedPin, 0);    // set the LED off
//  arduino.analogWrite(BluePin, 0);    // set the LED off
    
  //Visually show a beat on screen  
  textSize(txtSize);
  text("BEAT", width/5, height/2);
  txtSize = constrain(txtSize * 0.95, 16, 32);
  text(BassAmp, 2*width/5, height/2);
  text(MidAmp, 3*width/5, height/2);
  text(TreAmp, 4*width/5, height/2);
  for(int i = 0; i < fft.specSize(); i++) {
    line(i, height, i, height - fft.getBand(i)*4);
  }
  
  //Reset the amplitude values between samples
  BassAmp = 0;
  MidAmp = 0;
  TreAmp = 0;
  
}

void stop() {
  // always close Minim audio classes when you are finished with them
  song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}

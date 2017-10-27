//Adapted from Rain by Daniel Shiffman and Processing_SimpleColor_1Continuous
//Takes in two continuous inputs
//Outputs rain color based on person's position
//Plays sound with volume mapped to eyes open

import ddf.minim.*;
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

Minim minim;
AudioPlayer player;

//Parameters of sketch
float myHue;
float myVol;

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("ff")) { // looking for 2 control values
        float receivedHue = theOscMessage.get(0).floatValue();
        float receivedVol = theOscMessage.get(1).floatValue();
        myHue = map(receivedHue, 0, 1, 125, 180);
        myVol = map(receivedVol, 0, 1, 0, -60);
     } else {
        println("Error: unexpected OSC message received by Processing: ");
        theOscMessage.print();
      }
 }
}

//Sends current parameter (hue) to Wekinator
void sendOscNames() {
  OscMessage msg = new OscMessage("/wekinator/control/setOutputNames");
  msg.add("hue");
  msg.add("vol");
  oscP5.send(msg, dest);
}

class Drop {
  
  float x;
  float y;
  float z;
  float len;
  float yspeed;

  Drop() {
    x  = random(width);
    y  = random(-500, -50);
    z  = random(0, 20);
    len = map(z, 0, 20, 10, 20);
    yspeed  = map(z, 0, 20, 1, 20);
  }

  void fall() {
    y = y + yspeed;
    float grav = map(z, 0, 20, 0, 0.2);
    yspeed = yspeed + grav;

    if (y > height) {
      y = random(-200, -100);
      yspeed = map(z, 0, 20, 4, 10);
    }
  }

  void show() {
    float thick = map(z, 0, 20, 1, 2);
    strokeWeight(thick);
    stroke(myHue, 255, 255);
    line(x, y, x, y+len);
  }
}

Drop[] drops = new Drop[500];

void setup() {
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
  minim = new Minim(this);
  player = minim.loadFile("rain.mp3");
  
  player.play();
  player.setGain(-60);
  
  colorMode(HSB);
  fullScreen(P3D);
  smooth();

  myHue = 0;
  sendOscNames();

  for (int i = 0; i < drops.length; i++) {
    drops[i] = new Drop();
  }
}

void draw() {
  background(145, 30, 200);
  
  player.setGain(myVol);
  
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();
    drops[i].show();
  }
}
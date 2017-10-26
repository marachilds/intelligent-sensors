import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

//Parameters
PFont myFont;

float myPos;
float myFrame;
float myAlpha;

//Called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("ff")) { // looking for 2 control values
        float receivedFrame = theOscMessage.get(0).floatValue();
        float receivedAlpha = theOscMessage.get(1).floatValue();
        myFrame = map(receivedFrame, 0, 1, 1, 60);
        myAlpha = map(receivedAlpha, 0, 1, 0, 200);
     } else {
        println("Error: unexpected OSC message received by Processing: ");
        theOscMessage.print();
      }
 }
}

//Sends current parameter to Wekinator
void sendOscNames() {
  OscMessage msg = new OscMessage("/wekinator/control/setOutputNames");
  msg.add("frame");
  msg.add("alpha");
  oscP5.send(msg, dest);
}

void setup() {
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
  size(400, 400);
  myFont = createFont("Helvetica", 50);
  background(255);
  frameRate(1);
  
  myFrame = 1;
  myAlpha = 255;
  sendOscNames();
}

void draw() {
  background(255);
  frameRate(myFrame);
  for(int i=-0; i<200; i=i+10) {
    for(int j=-0; j<800; j=j+80) {
      fill(random(abs(i-300)), random(abs(i-500)), random(abs(i-1000)), myAlpha);
      textFont(myFont, random(abs(i)));
      text("you", i, random(j+1));
    }
  }
}
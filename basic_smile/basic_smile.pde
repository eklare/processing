import processing.video.*;
import pSmile.PSmile;

Capture cap;
PSmile smile;
PImage img;
float res, factor;
PFont font;
int w, h;
PShape s;


void setup() {
  size(640,480);
  w = width/2;
  h = height/2;
  s = loadShape("donut.svg");

  cap = new Capture(this, width, height,25); 
  cap.start();
  img = createImage(w,h,ARGB);
  smile = new PSmile(this,w,h);

  res = 0.0;
  factor = 0.0;
  font = loadFont("SansSerif.plain-16.vlw");
  textFont(font,16);
  textAlign(CENTER);
  noStroke();
  fill(0,200,0);
  rectMode(CORNER);
}

void draw() {
  img.copy(cap,0,0,width,height,0,0,w,h);
  img.updatePixels();
  image(cap,0,0);
  res = smile.getSmile(img);
  
  
  println(res);
  
  if (res>0) {
    factor = factor*0.8 + res*0.2;
    float t_h = factor*30;
    //rect(width-50,height-t_h,40,t_h);
    
    for(int i=0; i<res; i++){
      shape(s, random(640), random(480), 80, 80);
    }
    
  }
  String str = nf(res,1,4);
  text(str,width-100,height-10);
}

void captureEvent(Capture _c) {
  _c.read();
}

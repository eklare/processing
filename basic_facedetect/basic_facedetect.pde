import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

void setup() {
  size(640, 480);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();
}

void draw() {
  scale(2);
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  stroke(255, 255, 0);
  strokeWeight(1);
  Rectangle[] faces = opencv.detect();
  println(faces.length);

  for (int i = 0; i < faces.length; i++) {
    println(faces[i].x + "," + faces[i].y);
    
    int w = faces[i].width;
    int h = faces[i].height;
    int xcoord = faces[i].x;
    int ycoord = faces[i].y;
    
    //ellipse(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
    
    rect(xcoord, ycoord, w, h);
    
    //stroke(0,0,255);
    //ellipse(xcoord + w/2, ycoord + h/2, w, h);
 
  }
  
  
}

void captureEvent(Capture c) {
  c.read();
}

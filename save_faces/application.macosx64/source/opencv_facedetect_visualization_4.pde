import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;



// A list of my Face objects
ArrayList<Face> faceList;
ArrayList <Mover> bouncers;

JSONArray values; 

// how many have I found over all time
int faceCount = 0;

int movement = 5;


int day;
int id;
int pixc;


void setup() { 
  size(1200, 800);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  bouncers = new ArrayList();
  
  values = loadJSONArray("json/data.json");
  faceCount = values.size();
  id= faceCount;
  println("length of image array: " +faceCount);
  
  faceList = new ArrayList<Face>();
  video.start();
  
 /* imagedata = loadJSONObject("json/data.json");
  JSONArray pastImages = imagedata.getJSONArray("images");
  JSONObject firstImage = images.getJSONObject(0);
  
  JSONObject snippet = firstImage.getJSONObject("snippet");
  day = snippet.getInt("day");
  println(day);
  
 */ 
  smooth();
  background (#000000);
  frameRate (300);
  
  
  //testing mover class
  /*for(int i=0; i<600; i++){
    Mover m = new Mover();
    bouncers.add (m);
 }*/
 
 //TODO: execute once on start up
 
 //for all images saved in JSON 
 for(int i=0; i<faceCount; i++){
    //JSONArray pastImages = values.getJSONArray(i);
   // println("retrieved array value at: "+ i);

   JSONObject image = values.getJSONObject(i);
   println("retrieved object value at: "+ i + " " + image);
   
  // JSONObject snippet = image.getJSONObject("snippet");
  // println("retrieved snippet: "+ i + " "+ snippet);

   id = image.getInt("id");
   day = image.getInt("day");
   pixc = image.getInt("color");
   
   Mover m = new Mover(id, day, pixc);
   println("Created mover for: "+ i);
   bouncers.add (m);
   
   println("faceCount is: " + faceCount);
   
 }
 
 
}

void draw() {
  scale(2);


 
 
 
 //load video
  opencv.loadImage(video);

 // image(video, 0, 0 ); //don't show video on run
    
  //noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  
  //start detecting new faces
  Rectangle[] faces = opencv.detect();

  
    // SCENARIO 1: faceList is empty
  if (faceList.isEmpty()) {
    // Just make a Face object for every face Rectangle
    for (int i = 0; i < faces.length; i++) {
      faceList.add(new Face(faces[i].x,faces[i].y,faces[i].width,faces[i].height));
    }
  // SCENARIO 2: We have fewer Face objects than face Rectangles found from OPENCV
  } else if (faceList.size() <= faces.length) {
    boolean[] used = new boolean[faces.length];
    // Match existing Face objects with a Rectangle
    for (Face f : faceList) {
       // Find faces[index] that is closest to face f
       // set used[index] to true so that it can't be used twice
       float record = 50000;
       int index = -1;
       for (int i = 0; i < faces.length; i++) {
         float d = dist(faces[i].x,faces[i].y,f.r.x,f.r.y);
         if (d < record && !used[i]) {
           record = d;
           index = i;
         } 
       }
       // Update Face object location
       used[index] = true;
       f.update(faces[index]);
    }
    // Add any unused faces
    for (int i = 0; i < faces.length; i++) {
      if (!used[i]) {
        faceList.add(new Face(faces[i].x,faces[i].y,faces[i].width,faces[i].height));
      }
    }
  // SCENARIO 3: We have more Face objects than face Rectangles found
  } else {
    // All Face objects start out as available
    for (Face f : faceList) {
      f.available = true;
    } 
    // Match Rectangle with a Face object
    for (int i = 0; i < faces.length; i++) {
      // Find face object closest to faces[i] Rectangle
      // set available to false
       float record = 50000;
       int index = -1;
       for (int j = 0; j < faceList.size(); j++) {
         Face f = faceList.get(j);
         float d = dist(faces[i].x,faces[i].y,f.r.x,f.r.y);
         if (d < record && f.available) {
           record = d;
           index = j;
           
         } 
       }
       // Update Face object location
       Face f = faceList.get(index);
       f.available = false;
       f.update(faces[i]);
    } 
    // Start to kill any left over Face objects
    for (Face f : faceList) {
      if (f.available) {
        f.countDown();
        if (f.dead()) {
          f.delete = true;
        } 
      }
    } 
  }
  
  // Delete any that should be deleted
    for (int i = faceList.size()-1; i >= 0; i--) {
    Face f = faceList.get(i);
    if (f.delete) {
      faceList.remove(i);
    } 
  }
  
 //Draw all the faces
 /* for (int i = 0; i < faces.length; i++) {
    noFill();
    stroke(255,0,0);
    rect(faces[i].x,faces[i].y,faces[i].width,faces[i].height);
  }
  
  for(Face f : faceList) {
    f.display();
  } */
  
  

  //background (#57385c);
 fill (#000000, 40);
  noStroke();
  rect (0, 0, width, height);

   int i = 0;
  while (i < bouncers.size () )
  {
    Mover m = bouncers.get(i);
    if(movement != 5) m.update (movement);
    else
    {
      m.flock (bouncers);
      m.move();
      m.checkEdges();
      m.display();
    }
 
    i = i + 1;
  }



}

void captureEvent(Capture c) {
  c.read();
 
}

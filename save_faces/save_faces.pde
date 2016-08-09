import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;



// A list of my Face objects
ArrayList<Face> faceList;


// how many have I found over all time
int faceCount = 0;


float[] angle, rad, speed, sx, sy, diam, a, gender;
color[] c;
color[] happyColors = {color(241,255,30), color(255,153,6)};
color[] sadColors = {color(5,122,209), color(4,167,188)};
int[] nbConnex;
int nbPts;

final static int RADIUS = 25;

JSONArray values;
int count,id, day, hour;
float sex,  glasses, confidence,  mouth,  eyes,  age,  smile;
String emotion;


void setup() { 
  
  //frame.dispose();  
  //frame.setUndecorated(true);
  frame.setLocation(1680,0);
  size(1000, 800);
  video = new Capture(this, 640/2, 480/2, 60);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  
  String loadtotal[]=loadStrings("http://localhost:8888/countenance/sql_select.php?var=count");
  int total = int(loadtotal[0]);
  println("total: "+ total);
  //values = loadJSONArray("json/data.json");
  faceCount = total;//values.size();
  id= faceCount;
  println("length of image array: " +faceCount);
  
  faceList = new ArrayList<Face>();

   //video.start();
    
    nbPts = id;
    angle = new float[nbPts];
    //a = new float[nbPts];
    c = new color[nbPts];
    rad = new float[nbPts];
    speed = new float[nbPts];
    gender = new float[nbPts];
    sx = new float[nbPts];
    sy = new float[nbPts];
    diam = new float[nbPts];
    nbConnex = new int[nbPts];
    
   initialize();
}

void initialize(){

    for (int i = 0; i<nbPts; i++) {
        println(i);
        String loadday[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ i + "&var=day");
        day = int(loadday[0]);
        println("day: "+ day);
        String loadhour[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ i + "&var=hour");
        hour = int(loadhour[0]);
        println("hour: "+ hour);
        String loadage[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ i + "&var=age");
        age = int(loadage[0]);
        println("age: "+ age);
        String loadsmile[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ i + "&var=smile");
        smile = float(loadsmile[0])+0.001;
        println("smile: "+ smile);
        String loadsex[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ i + "&var=sex");
        sex = float(loadsex[0]);
        println("sex: "+ sex);
        String loademotion[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ i + "&var=emotion");
        emotion = loademotion[0];
        println("emotion: "+ emotion);
       
        angle[i] = random(TWO_PI);
        rad[i] =(int)day * RADIUS;
        //rad[i] = (int)day%12 * RADIUS;
        //speed[i] = random(-.03*smile, .03*smile);
        speed[i] = random(-.015, .015);
        println("current speed: " + speed[i]);
        
       
         
        if(emotion.equals("happy") == true){ //<>//
          //c[i]=happyColors[i%2]; 
          c[i]= color(241,255,30);
        }
        else if(emotion.equals("sad") == true){
         // c[i]=sadColors[i%2];
          c[i]=color(5,122,209);
        }
        else if(emotion.equals("confused") == true){
          c[i]=color(6,147,93);
        }
        else if(emotion.equals("angry") == true){
          c[i]=color(186,61,12);
        }
        else if(emotion.equals("surprised") == true){
          c[i]=color(255,153,6);
        }
        else if(emotion.equals("calm") == true){
          c[i]=color(4,167,188);
        }
        else c[i]=color(6,147,93);
        
        sx[i] = width/2;
        sy[i] = height/2;
        nbConnex[i] = 0;
        diam[i] = (int)age/2;
        gender[i] = sex;
    }
}

 
 


void draw() {
  //background(0);
 
 //load video
  opencv.loadImage(video);

 //image(video, 0, 0 ); //don't show video on run
    
  //noFill();
 // stroke(0, 255, 0);
 // strokeWeight(3);
  
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
/*  
 //Draw all the faces
  for (int i = 0; i < faces.length; i++) {
    noFill();
    stroke(255,0,0);
    rect(faces[i].x,faces[i].y,faces[i].width,faces[i].height);
  }
  
  for(Face f : faceList) {
    f.display();
    
  } 
  */
  background(#191919);
  
  /* stroke(255,40);
    for (int i=0; i<nbPts; i++) {
        for (int j=i+1; j<nbPts; j++) {
            if (dist(sx[i], sy[i], sx[j], sy[j])<RADIUS+10) {
                line(sx[i], sy[i], sx[j], sy[j]);
                nbConnex[i]++;
                nbConnex[j]++;
            }
        }
    }*/
  noStroke();
  for (int i=0; i<nbPts; i++) {
     drawSubject(i);

  }
 


}

void drawSubject(int id){
  
        angle[id] += (speed[id]*2);
        sx[id] = ease(sx[id], width/2 + cos(angle[id])*rad[id], 0.1);
        sy[id] = ease(sy[id], height/2 + sin(angle[id])*rad[id], 0.1);
       
        smooth();
         
        fill(c[id]);
          
        if(gender[id]<0.5){
         
          ellipse(sx[id], sy[id], diam[id], diam[id]);
        }
        else{
       
          //fill(c[id]);
          rect(sx[id]-(diam[id]-diam[id]/2), sy[id]-(diam[id]-diam[id]/2), diam[id], diam[id]);
        }
        nbConnex[id] = 0;
    
}

float ease(float variable, float target, float easingVal) {
    float d = target - variable;
    if (abs(d)>1) variable+= d;//*easingVal;
    return variable;
}
void captureEvent(Capture c) {
  c.read();
 
}

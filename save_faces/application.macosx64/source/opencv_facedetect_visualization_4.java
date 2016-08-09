import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import gab.opencv.*; 
import processing.video.*; 
import java.awt.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class opencv_facedetect_visualization_4 extends PApplet {





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


public void setup() { 
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
  background (0xff000000);
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

public void draw() {
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
 fill (0xff000000, 40);
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

public void captureEvent(Capture c) {
  c.read();
 
}

class Face {
  
  // A Rectangle
  Rectangle r;
  
  // Am I available to be matched?
  boolean available;
  
  // Should I be deleted?
  boolean delete;
  
  // How long should I live if I have disappeared?
  int timer = 127;
  
  // Assign a number to each face
  int id;
  //JSONArray imagedata;
  //imagedata = loadJSONArray("json/data.json");
  
  String imgc;
   
  // Make me
  Face(int x, int y, int w, int h) {
    r = new Rectangle(x,y,w,h);
    available = true;
    delete = false;
    id = faceCount;
    day = day();
    pixc = get(r.width/2,r.height/2);
    println("Pixel color at: " + r.width/2 +", " + r.height/2 );
    imgc = hex(pixc,6);
    //saveFrame("data/day"+day+"-img"+id+".jpg");
    video.read();
    video.save("data/day"+day+"-img"+id+".jpg");
   
   
     JSONObject data = new JSONObject();
     data.setInt("id", id);
     data.setInt("day", day);
     data.setInt("color", pixc);
     data.setString("filepath", "data/day"+day+"-img"+id+".jpg");
     
     values.setJSONObject(id, data);
     println("values set in JSONObject");
 
     saveJSONArray(values, "json/data.json");
     println("JSONArray saved as data.json");
    
    Mover m = new Mover();
    bouncers.add (m);
    
    faceCount++;
    
   
  
  

  }

  // Show me
  public void display() {
    fill(0,0,255,timer);
    stroke(0,0,255);
    rect(r.x,r.y,r.width, r.height);
    fill(255,timer*2);
    text(""+id,r.x+10,r.y+30);
    

  }
 
  
 
 
  //load all past dots. 
  /* void loadPrev(){
    println("made it to loadPrev method");
    //load the data
   imagedata = loadJSONArray("json/data.json");

    //get the length of the array for the loop
    prevCount = imagedata.length;
    
    //set the id to the count so you don't overwrite old ids with new data
    id = prevCount;

    //loop to display 
    for(int i=0; i<id; i++ ){
      Mover m = new Mover();
      bouncers.add (m);
    }
  
  }*/

  // Give me a new location / size
  // Oooh, it would be nice to lerp here!
  public void update(Rectangle newR) {
    r = (Rectangle) newR.clone();
  }

  // Count me down, I am gone
  public void countDown() {
    timer--;
  }

  // I am deed, delete me
  public boolean dead() {
    if (timer < 0) return true;
    return false;
  }
  
}
class Mover
{
  PVector direction;
  PVector location;

  float speed;
  float SPEED;

  float noiseScale;
  float noiseStrength;
  float forceStrength;

  float ellipseSize;
  
  int c;


  Mover () // Konstruktor = setup der Mover Klasse
  {
    setValues();
  }

  Mover (float x, float y) // Konstruktor = setup der Mover Klasse
  {
    setValues ();
  }
  
    Mover (int id, int day, int pixc) // Konstruktor = setup der Mover Klasse
  {
    setValues (id, day, pixc);
  }

  // SET ---------------------------

  public void setValues ()
  {
    location = new PVector (random (width), random (height));
    ellipseSize = random (4, 15);

    float angle = random (TWO_PI);
    direction = new PVector (cos (angle), sin (angle));

    speed = random (4, 7);
    SPEED = speed;
    noiseScale = 80;
    noiseStrength = 1;
    forceStrength = random (0.1f, 0.2f);
    
    c = pixc;
   /* int colorDice = (int) random (4);

    if (colorDice == 0) c = #3F9A82;
    else if (colorDice == 1) c = #A1CD73;
    else if (colorDice == 2) c = #ECDB60;
    else c = #427676;*/
  }
  
    public void setValues (int id, int day, int pixc)
  {
    location = new PVector (random (width), random (height));
    ellipseSize = random (4, 15);

    float angle = random (TWO_PI);
    direction = new PVector (cos (angle), sin (angle));

    speed = random (4, 7);
    SPEED = speed;
    noiseScale = 80;
    noiseStrength = 1;
    forceStrength = random (0.1f, 0.2f);
    
    c = pixc;

  }

 /* void setRandomColor ()
  {
    int colorDice = (int) random (4);

    if (colorDice == 0) c = #ffedbc;
    else if (colorDice == 1) c = #A75265;
    else if (colorDice == 2) c = #ec7263;
    else c = #febe7e;
  }
*/
  // GENEREL ------------------------------

  public void update ()
  {
    update (0);
  }

  public void update (int mode)
  {
    if (mode == 0) // bouncing ball
    {
      speed = SPEED * 0.7f;
      move();
      checkEdgesAndBounce();
    }
    else if (mode == 1) // noise
    {
      speed = SPEED * 0.7f;
      addNoise ();
      move();
      checkEdgesAndRelocate ();
    }
    else if (mode == 2) // steer
    {
      steer (mouseX, mouseY);
      move();
    }
    else if (mode == 3) // seek
    {
      speed = SPEED * 0.7f;
      seek (mouseX, mouseY);
      move();
    }
    else // radial
    {
      speed = SPEED * 0.7f;
      addRadial ();
      move();
      checkEdges();
    }

    display();
  }

  // FLOCK ------------------------------

  public void flock (ArrayList <Mover> boids)
  {

    PVector other;
    float otherSize ;

    PVector cohesionSum = new PVector (0, 0);
    float cohesionCount = 0;

    PVector seperationSum = new PVector (0, 0);
    float seperationCount = 0;

    PVector alignSum = new PVector (0, 0);
    float speedSum = 0;
    float alignCount = 0;

    for (int i = 0; i < boids.size(); i++)
    {
      other = boids.get(i).location;
      otherSize = boids.get(i).ellipseSize;

      float distance = PVector.dist (other, location);


      if (distance > 0 && distance <70) //align + cohesion
      {
        cohesionSum.add (other);
        cohesionCount++;

        alignSum.add (boids.get(i).direction);
        speedSum += boids.get(i).speed;
        alignCount++;
      }

      if (distance > 0 && distance < (ellipseSize+otherSize)*1.2f) // seperate bei collision
      {
        float angle = atan2 (location.y-other.y, location.x-other.x);

        seperationSum.add (cos (angle), sin (angle), 0);
        seperationCount++;
      }

      if (alignCount > 8 && seperationCount > 12) break;
    }

    // cohesion: bewege dich in die Mitte deiner Nachbarn
    // seperation: renne nicht in andere hinein
    // align: bewege dich in die Richtung deiner Nachbarn

    if (cohesionCount > 0)
    {
      cohesionSum.div (cohesionCount);
      cohesion (cohesionSum, 1);
    }

    if (alignCount > 0)
    {
      speedSum /= alignCount;
      alignSum.div (alignCount);
      align (alignSum, speedSum, 1.3f);
    }

    if (seperationCount > 0)
    {
      seperationSum.div (seperationCount);
      seperation (seperationSum, 2);
    }
  }

  public void cohesion (PVector force, float strength)
  {
    steer (force.x, force.y, strength);
  }

  public void seperation (PVector force, float strength)
  {
    force.limit (strength*forceStrength);

    direction.add (force);
    direction.normalize();

    speed *= 1.1f;
    speed = constrain (speed, 0, SPEED * 1.5f);
  }

  public void align (PVector force, float forceSpeed, float strength)
  {
    speed = lerp (speed, forceSpeed, strength*forceStrength);

    force.normalize();
    force.mult (strength*forceStrength);

    direction.add (force);
    direction.normalize();
  }

  // HOW TO MOVE ----------------------------

  public void steer (float x, float y)
  {
    steer (x, y, 1);
  }

  public void steer (float x, float y, float strength)
  {

    float angle = atan2 (y-location.y, x -location.x);

    PVector force = new PVector (cos (angle), sin (angle));
    force.mult (forceStrength * strength);

    direction.add (force);
    direction.normalize();

    float currentDistance = dist (x, y, location.x, location.y);

    if (currentDistance < 70)
    {
      speed = map (currentDistance, 0, 70, 0, SPEED);
    }
    else speed = SPEED;
  }

  public void seek (float x, float y)
  {
    seek (x, y, 1);
  }

  public void seek (float x, float y, float strength)
  {

    float angle = atan2 (y-location.y, x -location.x);

    PVector force = new PVector (cos (angle), sin (angle));
    force.mult (forceStrength * strength);

    direction.add (force);
    direction.normalize();
  }

  public void addRadial ()
  {

    float m = noise (frameCount / (2*noiseScale));
    m = map (m, 0, 1, - 1.2f, 1.2f);

    float maxDistance = m * dist (0, 0, width/2, height/2);
    float distance = dist (location.x, location.y, width/2, height/2);

    float angle = map (distance, 0, maxDistance, 0, TWO_PI);

    PVector force = new PVector (cos (angle), sin (angle));
    force.mult (forceStrength);

    direction.add (force);
    direction.normalize();
  }

  public void addNoise ()
  {

    float noiseValue = noise (location.x /noiseScale, location.y / noiseScale, frameCount / noiseScale);
    noiseValue*= TWO_PI * noiseStrength;

    PVector force = new PVector (cos (noiseValue), sin (noiseValue));
    //Processing 2.0:
    //PVector force = PVector.fromAngle (noiseValue);
    force.mult (forceStrength);
    direction.add (force);
    direction.normalize();
  }

  // MOVE -----------------------------------------

  public void move ()
  {

    PVector velocity = direction.get();
    velocity.mult (speed);
    location.add (velocity);
  }

  // CHECK --------------------------------------------------------

  public void checkEdgesAndRelocate ()
  {
    float diameter = ellipseSize;

    if (location.x < -diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
    }
    else if (location.x > width+diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
    }

    if (location.y < -diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
    }
    else if (location.y > height + diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
    }
  }


  public void checkEdges ()
  {
    float diameter = ellipseSize;

    if (location.x < -diameter / 2)
    {
      location.x = width+diameter /2;
    }
    else if (location.x > width+diameter /2)
    {
      location.x = -diameter /2;
    }

    if (location.y < -diameter /2)
    {
      location.y = height+diameter /2;
    }
    else if (location.y > height+diameter /2)
    {
      location.y = -diameter /2;
    }
  }

  public void checkEdgesAndBounce ()
  {
    float radius = ellipseSize / 2;

    if (location.x < radius )
    {
      location.x = radius ;
      direction.x = direction.x * -1;
    }
    else if (location.x > width-radius )
    {
      location.x = width-radius ;
      direction.x *= -1;
    }

    if (location.y < radius )
    {
      location.y = radius ;
      direction.y *= -1;
    }
    else if (location.y > height-radius )
    {
      location.y = height-radius ;
      direction.y *= -1;
    }
  }

  // DISPLAY ---------------------------------------------------------------

  public void display ()
  {
  noStroke();
    fill (c);
    ellipse (location.x, location.y, ellipseSize, ellipseSize);
  }
}

public void keyPressed ()
{
  if (key == 'n')
  {
    float noiseScale = random (5, 400);
    float noiseStrength = random (0.5f, 6);
    float forceStrength = random (0.5f, 4);

    for (int i = 0; i < bouncers.size(); i++)
    {
      Mover currentMover = bouncers.get(i);
      currentMover.noiseScale = noiseScale;
      currentMover.noiseStrength = noiseStrength;
      currentMover.forceStrength = forceStrength;
    }
  }
}

public void mousePressed ()
{
  if (mouseButton == LEFT)
  {
    movement++;
    if (movement > 5)
    {
      movement = 0;
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "opencv_facedetect_visualization_4" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

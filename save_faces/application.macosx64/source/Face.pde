
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
  void display() {
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
  void update(Rectangle newR) {
    r = (Rectangle) newR.clone();
  }

  // Count me down, I am gone
  void countDown() {
    timer--;
  }

  // I am deed, delete me
  boolean dead() {
    if (timer < 0) return true;
    return false;
  }
  
}


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
    hour = hour();
    //pixc = get(r.width/2,r.height/2);
    //println("Pixel color at: " + r.width/2 +", " + r.height/2 );
    //imgc = hex(pixc,6);
    //saveFrame("data/day"+day+"-img"+id+".jpg");
    video.read();
    String filename="day"+day+"-img"+id+".jpg";
    video.save("data/day"+day+"-img"+id+".jpg");
     //delay(10000);
     //call to PHP with face image to generate JSON
     
     println("new file: " + filename); //displays "Hello"
     //String a[]=loadStrings("http://localhost:8888/countenance/sql_insert.php?id="+id+"&value="+ filename+"&day="+day+"&hour="+hour);

    
    //delay(10000);
    
       String loadday[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ id + "&var=day");
        day = int(loadday[0]);
        println("new file day: "+ day);
       if(day !=0){
            String loadhour[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ id + "&var=hour");
              hour = int(loadhour[0]);
              println("new file hour: "+ hour);
            String loadage[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ id + "&var=age");
              age = int(loadage[0]);
              println("new file age: "+ age);
            String loadsmile[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ id + "&var=smile");
              smile = float(loadsmile[0])+0.001;
              println("new file smile: "+ smile);
            String loadsex[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ id + "&var=sex");
              sex = float(loadsex[0]);
              println("new file sex: "+ sex);
            String loademotion[]=loadStrings("http://localhost:8888/countenance/sql_select.php?value="+ id + "&var=emotion");
              emotion = loademotion[0];
              println("new file emotion: "+ emotion);
      
        
    
    
            faceCount++;
            nbPts++;
            angle = expand(angle, angle.length+1);
             // a = expand(a, a.length+1);
            c = expand(c, c.length+1);
            rad = expand(rad, rad.length+1);
            speed = expand(speed, speed.length+1);
            gender = expand(gender, gender.length+1);
            sx = expand(sx, sx.length+1);
            sy = expand(sy, sy.length+1);
            diam = expand(diam, diam.length+1);
            nbConnex = expand(nbConnex, nbConnex.length+1);
    
            angle[id] = random(TWO_PI);
            rad[id] = (int)day * RADIUS;
            speed[id] = random(-.01, .01);
            println("new file current speed: " + speed[id]);
    
            if(emotion.equals("happy") == true){
                  //c[i]=happyColors[i%2]; 
                  c[id]= color(241,255,30);
                }
                else if(emotion.equals("sad") == true){
                 // c[i]=sadColors[i%2];
                  c[id]=color(5,122,209);
                }
                else if(emotion.equals("confused") == true){
                  c[id]=color(6,147,93);
                }
                else if(emotion.equals("angry") == true){
                  c[id]=color(186,61,12);
                }
                else if(emotion.equals("surprised") == true){
                  c[id]=color(255,153,6);
                }
                else if(emotion.equals("calm") == true){
                  c[id]=color(4,167,188);
                }
                else c[id]=color(6,147,93);
                
        
    
    
              sx[id] = width/2;
              sy[id] = height/2;
              nbConnex[id] = 0;
              diam[id] = (int)age/2;
              gender[id] = sex;
       }

  }

  // Show me
  void display() {
    //fill(255,255,255,timer);
    stroke(255,255,255);
    rect(r.x,r.y,r.width, r.height);
    fill(255,timer*2);
    text(""+id,r.x+10,r.y+30);
     

  }
 
  

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

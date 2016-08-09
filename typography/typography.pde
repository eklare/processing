
import geomerative.*;

int whiteBlack =0;
int turns = 0;
int tempo = 0;

int sizeWIDTH = 1200;
int sizeHEIGHT = 800;

int numberPoints = 10;

int[] NumbersArrayX = new int[numberPoints];
int[] NumbersArrayY = new int[numberPoints];

int[] Rnd_NumbersArrayX = new int[numberPoints];
int[] Rnd_NumbersArrayY = new int[numberPoints];

int countMouse=0;
int MX = sizeWIDTH/2;
int MY = sizeHEIGHT/2;

char typedKey = 'a';
float spacing = 20;
float spaceWidth = 150; // width of letter ' '
int fontSize = 200;
float lineSpacing = fontSize;
float stepSize = 2;
float danceFactor = 1;
float letterX = 50;
float textW = 50;
float letterY = lineSpacing;


RFont font;
RGroup grp;
RPoint[] pnts;

boolean freeze = false;
boolean red = false;

void setup() {
  size(1200,800); 
  // make window resizable
  frame.setResizable(true);  
  smooth();

  frameRate(15);

  // allways initialize the library in setup
  RG.init(this);
  font = new RFont("FreeSansNoPunch.ttf", fontSize, RFont.LEFT);

  //  ------ get the points on the curve's shape  ------
  // set style and segment resolution

  RCommand.setSegmentStep(10);
  RCommand.setSegmentator(RCommand.UNIFORMSTEP);

  RCommand.setSegmentLength(25);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  //RCommand.setSegmentAngle(random(0,HALF_PI));
  //RCommand.setSegmentator(RCommand.ADAPTATIVE);

  grp = font.toGroup("");
  textW = letterX = 0;
  letterY = lineSpacing;
  pnts = grp.getPoints(); 

  background(255);
  
  frameRate(20);
   smooth();
   background(255,255,255);
   size(sizeWIDTH, sizeHEIGHT);
   
   for(int i = 0; i < numberPoints; i++){
        NumbersArrayX[i] = sizeWIDTH/2;
        NumbersArrayY[i] = sizeHEIGHT/2;
   }
   
   for(int i = 0; i < numberPoints; i++){
        Rnd_NumbersArrayX[i] = sizeWIDTH/2;
        Rnd_NumbersArrayY[i] = sizeHEIGHT/2;
   }
}

void draw() {
  
  
turns++;
  
  if(turns > 100) {
     fill(255,255,255,10);
     noStroke();
     rect(-40,-40,sizeWIDTH+40, sizeHEIGHT+40);
     turns = 0;
  }
  
  tempo++;
  if (mousePressed == true){
       MX = mouseX;
       MY = mouseY;
  }
  else {
      if(tempo>15){
        MX = int(random (50,sizeWIDTH-50));
        MY = int(random (100,sizeHEIGHT-100));
        tempo = 0;
       }
  }
  
  countMouse ++;
  if(countMouse < numberPoints) {
      if((MX > 40) && (MX < sizeWIDTH-40)){
          NumbersArrayX[countMouse] = MX;
          Rnd_NumbersArrayY[countMouse] = MY + int(random(-10,10));
      }
  }
  else {
    countMouse = 0;
  }
  
  whiteBlack++;
  if(whiteBlack > 400){
       whiteBlack = 0;
  }
  
  if(turns == 50){
      strokeWeight(15);
  }
  else {
      strokeWeight(1);
  }
  
  if(turns == 300) {
      strokeWeight(15);
  }
  else {
      strokeWeight(1);
  }
  
  for(int i=0; i < numberPoints; i++) {
      if((i>0) && (i < numberPoints)) {
           stroke(10,10,10,20);
          line(Rnd_NumbersArrayX[i], Rnd_NumbersArrayY[i], Rnd_NumbersArrayX[i-1], Rnd_NumbersArrayY[i-1]); 
          if(whiteBlack < 200) {
              stroke(5,5,5,80);
          }
          else {
              stroke(255,255,255,90);
          }
          line(NumbersArrayX[i], NumbersArrayY[i], Rnd_NumbersArrayX[i-1], Rnd_NumbersArrayY[i-1]);
            
    
  }
      
      NumbersArrayX[i] = NumbersArrayX[i] + int(random(-10,10));
      NumbersArrayY[i] = NumbersArrayY[i] + int(random(-10,10));
      
      Rnd_NumbersArrayX[i] = Rnd_NumbersArrayX[i] + int(random(-10,10));
      Rnd_NumbersArrayY[i] = Rnd_NumbersArrayY[i] + int(random(-10,10));
      
    if (NumbersArrayX[i]<0 || NumbersArrayX[i] > width) NumbersArrayX[i] = (int)random(0,width);
    if (NumbersArrayY[i]<0 || NumbersArrayY[i]  >height) NumbersArrayY[i] = (int)random(0,height);
    
    if (Rnd_NumbersArrayX[i]<0 || Rnd_NumbersArrayX[i]>width) Rnd_NumbersArrayX[i] = (int)random(0,width);
    if (Rnd_NumbersArrayY[i]<0 || Rnd_NumbersArrayY[i]>height) Rnd_NumbersArrayY[i] = (int)random(0,height);
  }
  
  
  noFill();
  pushMatrix();

  // translation according the amoutn of letters
  translate(letterX,letterY);
  
   // distortion on/off
        if (mousePressed) danceFactor = map(mouseX, 0,width, 1,3);
        else danceFactor = 1;
      
        // are there points to draw?
        if (grp.getWidth() > 0) {
          // let the points dance
          for (int i = 0; i < pnts.length; i++ ) {
      pnts[i].x += random(-stepSize,stepSize)*danceFactor;
      pnts[i].y += random(-stepSize,stepSize)*danceFactor;  
    } 

    //  ------ lines: connected rounded  ------
    strokeWeight(0.01);  
    stroke(0,0,0);
    if(red == true)
      stroke(200,0,0);
    beginShape();
    // start controlpoint
    curveVertex(pnts[pnts.length-1].x,pnts[pnts.length-1].y);
    // only these points are drawn
    for (int i=0; i<pnts.length; i++){
      curveVertex(pnts[i].x, pnts[i].y);
    }
    curveVertex(pnts[0].x, pnts[0].y);
    // end controlpoint
    curveVertex(pnts[1].x, pnts[1].y);
    endShape();

    //  ------ lines: connected straight  ------
    strokeWeight(0.5);
    stroke(0);
    beginShape();
    for (int i=0; i<pnts.length; i++){
      vertex(pnts[i].x, pnts[i].y);
      ellipse(pnts[i].x, pnts[i].y, 2, 2);
    }
    vertex(pnts[0].x, pnts[0].y);
    endShape();
  }

  popMatrix();
}

void keyReleased() {
  if (keyCode == SHIFT) {
    // switch loop on/off
     freeze = !freeze;
    if (freeze == true) noLoop();
    else loop();
  } 
  
  // ------ pdf export ------
  // press CONTROL to start pdf recordPDF and ALT to stop it
  // ONLY by pressing ALT the pdf is saved to disk!
 
 
}

void keyPressed() {
  if (key != CODED) {
    switch(key) {
    case ENTER:
    case RETURN:
      grp = font.toGroup(""); 
      letterY += lineSpacing;
      textW = letterX = 20;
      break;
    case ESC:
    case TAB:
      break;
    case BACKSPACE:
    case DELETE:
      background(255);
      grp = font.toGroup(""); 
      textW = letterX = 0;
      letterY = lineSpacing;
      freeze = false;
      loop();
      break;
    case ' ':
      grp = font.toGroup(""); 
      letterX += spaceWidth;
      freeze = false;
      loop();
      break;
    case 'v':
      red = true; 
      textW += spacing;
      letterX += textW;
      grp = font.toGroup("v");
      textW = grp.getWidth();
      pnts = grp.getPoints(); 
      freeze = false;
      loop();
      break;
    case 'o':
      red = true; 
      textW += spacing;
      letterX += textW;
      grp = font.toGroup("o");
      textW = grp.getWidth();
      pnts = grp.getPoints(); 
      freeze = false;
      loop();
      break;
     case 'i':
      red = true; 
      textW += spacing;
      letterX += textW;
      grp = font.toGroup("i");
      textW = grp.getWidth();
      pnts = grp.getPoints(); 
      freeze = false;
      loop();
      break;
     case '-':
      red = true; 
      textW += spacing;
      letterX += textW;
      grp = font.toGroup("d");
      textW = grp.getWidth();
      pnts = grp.getPoints(); 
      freeze = false;
      loop();
      break;
    default:
      typedKey = key;
      red=false;
      // add to actual pos the letter width
      textW += spacing;
      letterX += textW;
      grp = font.toGroup(typedKey+"");
      textW = grp.getWidth();
      pnts = grp.getPoints(); 
      freeze = false;
      loop();
    }
  } 
}

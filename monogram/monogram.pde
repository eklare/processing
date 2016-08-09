PFont myFont;
void setup(){
  size(800,800);
  background(255,255,255);
  myFont = createFont("Futura-MediumCondensed",48);
  textFont(myFont, 202);
  translate(400,400);
  
  for(int i=0;i<6;i++){
    fill(0,0,0);
    textAlign(CENTER);
    pushMatrix();
    rotate(PI*i/2);
    text("LMN",0,0);
    popMatrix();
  }
}

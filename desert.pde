/*
 Yoki Xue
 Decoding Nature
 Final Project
 12 December 2021
 
Desert Simulator 

Reference:

http://natureofcode.com
 
https://github.com/jbenno/nyuad_decoding_nature/wiki

https://editor.p5js.org/amgalnyu/sketches/Byxzjk3Re

https://editor.p5js.org/EliLevy/sketches/igxdujBnb

https://discourse.processing.org/t/ecosystem-simulation-with-processing/3651

https://www.youtube.com/watch?v=RbGQJ_F4PgM

*/




World world; 
PImage b,h,g,c; //background
Boolean intro;
int value=0;
PFont myFont;

void setup() {
  size(1000, 800);
  b = loadImage("desert.jpeg");
  h = loadImage("hawk.png");
  g = loadImage("grasshopper.png");
  c = loadImage("cactus.png");
  frameRate(60);
  world = new World(150, 50, 10);
  intro = true;
  myFont = createFont("Krungthep-20.vlw", 20);
}

void draw() {
  background(217, 183, 74);
  image(b, 0,0);
  world.update();
  fill(50);
  textFont(myFont);
  textSize(12);
  text("Cactus:" + (int)world.getCactusNum(), 20, 20);
  text("hrasshopper:" + (int)world.getGrasshopperNum(), 20, 40);
  text("hawk:" + (int)world.getHawkNum(), 20, 60);
  
  rect(120, 7, 20, 12);//click bottom-cactus
  rect(120, 27, 20, 12);//click bottom-grasshopper
  rect(120, 47, 20, 12);//click bottom-hawk
  fill(250);
  
  //minus signs
  rect(125, 12, 10, 3);
  rect(125, 32, 10, 3);
  rect(125, 52, 10, 3);


  //instruction panel
  if (intro) {
    fill(0, 200);
    rect(width/4, height/4, width/2, height/2-60, 30);
    textSize(30);
    fill(250);
    textFont(myFont);
    text("INSTRUCTION", width/2-70, height/4+60);
    textSize(20);
    textFont(myFont);
    text("—Press “i” to close/show instruction page", width/4+20, height/4+100);
    text("—The current number of each species is shown", width/4+20, height/4+130);
    text("at the upper-left corner", width/4+20, height/4+160);
    text("—Press “1” to add cactus",width/4+20,height/4+190);
    text("—Press “2” to add grasshopper",width/4+20,height/4+220);
    text("—Press “3” to add hawk",width/4+20,height/4+250);
    text("—Click the minus bottom to reduce",width/4+20,height/4+280);
}
}


//click minus bottom to reduce
void mouseClicked() {
  //print(0);
  if (mouseX>120&&mouseX<140&&mouseY>7&&mouseY<19) {
    world.reduceCactus();
  } else if (mouseX>120&&mouseX<140&&mouseY>27&&mouseY<39) {
    world.reduceGrasshopper();
  } else if (mouseX>120&&mouseX<140&&mouseY>47&&mouseY<59) {
    world.reduceHawk();
  }
}


//press key to show/exit instruction
//press keys to add 
void keyPressed() {
  if (key == 'i') {
    if (intro) {
      intro = false;
    } else {
      intro = true;
    }}
      else if (key == '1') {
      world.addCactus(new PVector(mouseX, mouseY));
    } else if (key == '2') {
      world.addGrasshopper(new PVector(mouseX, mouseY));
    } else if (key == '3') {
      world.addHawk(new PVector(mouseX, mouseY));
    }
  }

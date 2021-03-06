import processing.serial.*;
import ddf.minim.*;

AudioPlayer player;
Minim minim;


final int CANVAS_WIDTH = 1000;
final int CANVAS_HEIGHT = screen.height - 100;
int numBalls = 5;
float gravity = 0.005;
float friction = -0.0;
Ball[] balls = new Ball[numBalls];
int xpos = 0, ypos = 0;
char keypress = 'l';
int count = 0;
int score = 0;
int angle = 0;
PFont fontA;
Boolean bool[] = new Boolean[numBalls];
int stage = 1;
Boolean stageone = true;
Boolean stagetwo = false;
Boolean stagethree = false;
PrintWriter output = createWriter("data/data.txt");
String[] scoreRecord = new String[1];
String[] lines;
int highestScore = 0;

void setup() 
{  
  __setup(this);
  // read score
  lines = loadStrings("scores.txt");
  highestScore = Integer.parseInt(lines[0]);

  // save score
  //PrintWriter output = createWriter("data/data.txt");

  //for score  
  fontA = loadFont("CourierNew36.vlw");
  textFont(fontA, 32);  
  
  size(CANVAS_WIDTH, CANVAS_HEIGHT);
  noStroke();
  smooth();   
 
 
}

final static int DISPLAY_TIME = 300;

void soundCall(int blow)
{
  //audio
  minim = new Minim(this);
  if(blow == 0) player = minim.loadFile("baloonPopping.mp3");
  player.play(); 
  delay(1000);  
  player.close();
  minim.stop();
}

void displayInstruction()
{
  String instruction = (score >= 5) ? "Level 2: Rotate Tube to Match the Balloon's color " : "Level 1: Blow Balloons by moving the tube";
  
  if (count < DISPLAY_TIME) {
    fill (100, 100, 100);
    textAlign(CENTER);
    text(instruction, CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2);
  }
}

void draw() 
{
  // needed for all stages
  background(255);
  
  draw_pointer();
  displayScore();
  
  if (stageone == true) {    
    // tex
     // ball for stage 1     
    for (int b = 0; b < numBalls; b++){
      bool[b] = true;
      balls[b] = new Ball(random(width), 70, random(50, 80), 1, balls);    
    }
    stageone = false;
  }
  
  if (score >= 5 && stagetwo == false) {
    stagetwo = true;
    count = 0;
    for (int b = 0; b < numBalls; b++){
      bool[b] = true;
      balls[b] = new Ball(random(width), 70, random(50, 80), 1, balls);    
    }    
  }
      
  while(port.available() > 0) {
    serialEvent(port.read());
  }
    
  //stage 1
  
      firstStage();
      
  displayInstruction();
  checkGameState();
  endGame();
}

class Ball {
  float x, y;
  float diameter;
  float vx = 0;
  float vy = 0;
  int id;
  int colors;
  char ballcol;
  Ball[] others;  
 
  Ball(float xin, float yin, float din, int idin, Ball[] oin) {    
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    others = oin;
    
    if (stageone == true) colors = int(random(0,1));
    else if (stagetwo == true) colors = int(random(1,4));
   
  } 
  
  void move() {
    vy += gravity;
    x += vx;
    y += vy;
    if (x + diameter/2 > width) {
      x = width - diameter/2;
      vx *= friction; 
    }
    else if (x - diameter/2 < 0) {
      x = diameter/2;
      vx *= friction;
    }
    if (y + diameter/2 > height) {
      y = height - diameter/2;
      vy *= friction; 
    } 
    else if (y - diameter/2 < 0) {
      y = diameter/2;
      vy *= friction;
    }
  }
  
  void display() {
    switch (this.colors) {
      case 0:
        fill(0, 0, 0);
        ballcol = 'l';
        break;
      case 1:
        fill(0, 255, 0);
        ballcol = 'g';
        break;
      case 2:
        fill(0, 0, 255);
        ballcol = 'b';
        break;     
      case 3:
        fill(255, 0, 0);
        ballcol = 'r';
        break;        
    }    
    ellipse(x, y, diameter, diameter);
  }
}

void checkGameState()
{
  if (stageone == true || stagetwo == true) {
    return;
  }
  
  for (int z = 0; z < numBalls; z++) {
    if(bool[z] == true) {
      return;
    }
  }
  
  textAlign(CENTER);
  text("Game Over", CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2);
  textAlign(CENTER);
  text("Blow hard to restart", CANVAS_WIDTH / 2, CANVAS_HEIGHT - 50);
  //int tempCount = count;
  printToFile();
  if (fsr > 30) restart_game();
}



void restart_game()
{
  println("HERE");
  stageone = true;
  stagetwo = false;
  score = 0;
  count = 0;  
  // read score
  lines = loadStrings("scores.txt");
  highestScore = Integer.parseInt(lines[0]);
}

int onceEndGame = 1;
int onceEndGameCount = -1;

void endGame()
{
  if (score < 5) return;
  
  if (stageone == true || stagetwo == false) {
    return;
  }
  
  for (int z = 0; z < numBalls; z++) {
    if(bool[z] == true) {
      return;
    }
  }
  textAlign(CENTER);
  text("Congratulations! Your score: " + score, CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2);
  textAlign(CENTER);
  text("Blow hard to restart", CANVAS_WIDTH / 2, CANVAS_HEIGHT - 50);

  if (onceEndGame == 1) {
    onceEndGameCount = count;
  }
  onceEndGame &= ~onceEndGame;
  
  printToFile();
  if (count > (onceEndGameCount + 50) && fsr > 30) restart_game();
  
}

void printToFile()
{
  //println("hello");
  lines = loadStrings("scores.txt");
  println(lines);
  scoreRecord[0] = Integer.toString(score);
  if(score > highestScore) saveStrings("scores.txt", scoreRecord);
//  output.print("score");
//  output.flush();  // Actually writes the bytes to the file
  //output.close();  // Close the file
}



void firstStage()
{
  if (fsr > 10) {   
    popBalloon();
  }
    
  for (int b = 0; b<numBalls; b++)
  {
    if(count>=b*100 && bool[b] == true)
    {
      balls[b].move();
      balls[b].display();
    }    
  }
  
  count++;    
  for (int z = 0; z < numBalls; z++) if (balls[z].y >=(CANVAS_HEIGHT - 50)) bool[z] = false;   
  
}


void secondStage()
{
  for (int i = 0; i < numBalls; i++) balls[i].x = 20;  
  
}





void popBalloon()
{
    float xpos = calibrate_x();
    float ypos = calibrate_y();
    
    createExplosion();
    
    for(int z = 0; z<numBalls; z++){
      float rx = balls[z].x + 70;
      float lx = balls[z].x - 70;
      float uy = balls[z].y + 70;
      float ly = balls[z].y - 70;
    
      if (score >= 5) {
        if((xpos>=lx&&xpos<=rx)&&(ypos<=uy&&ypos>=ly) && setCol()==balls[z].ballcol && bool[z] != false) {
          bool[z] = false;     
          score++;   
          ThreadThing tt = new ThreadThing(this);
          tt.start();     
        }
      } else {
        if((xpos>=lx&&xpos<=rx)&&(ypos<=uy&&ypos>=ly)&& balls[z].ballcol == 'l' && bool[z] != false){
          bool[z] = false;
          score++;
          ThreadThing tt = new ThreadThing(this);
          tt.start();
        }
      }
    }
}

void draw_pointer()
{
    float w = 20, h = 20;
    float xpos = 0, ypos = 0;
    
    xpos = calibrate_x();
    ypos = calibrate_y();    
    
    if (score >= 5) {
      if (setCol() == 'r') fill(255, 0, 0);
      else if(setCol() == 'g') fill(0, 255, 0);
      else if(setCol() == 'b') fill(0, 0, 255);
    } else {  
      fill(0, 0, 0);
    }
      ellipse((float)xpos, (float)ypos, w, h);    
}

char setCol()
{
  char col = 'r';
  
  if (deg >= 0 && deg < 120) col = 'r';
  else if (deg >= 120 && deg < 240) col = 'g';
  else if (deg >= 240 && deg < 360) col = 'b';
  
  return col;
    
}

void displayScore()
{   
  fill(0);
  if (score < 5) text("Stage 1", 500, 30);
  else if (score >= 5) text("Stage 2", 500, 30);
  fill(200, 100, 50);
  text("Score: " + score, 820, 30);
  text("Top Score: " + highestScore, 820, 50);    
}

void createExplosion()
{
  float xpos = calibrate_x();
  float ypos = calibrate_y();
  if (fsr >= 10) {
    angle += 10;
    float val = cos(radians(angle)) * (float)fsr;
    for (int a = 0; a < 360; a += 75) {
      float xoff = cos(radians(a)) * val;
      float yoff = sin(radians(a)) * val;
      
      if (score >= 5) {
        if (setCol() == 'r') fill(255, 0, 0);
        else if(setCol() == 'g') fill(0, 255, 0);
        else if(setCol() == 'b') fill(0, 0, 255);
      }
      else fill(0);  
      
      ellipse(xpos + xoff, ypos + yoff, val, val);
    }
    fill(255);
    ellipse(xpos, ypos, 2, 2);
  }
  
}



/* for computer input
 * 
 */
void mousePressed()
{
  
    xpos = mouseX;
    ypos = mouseY;
    
    for(int z = 0; z<numBalls; z++){
      float rx = balls[z].x + 50;
      float lx = balls[z].x - 50;
      float uy = balls[z].y + 50;
      float ly = balls[z].y - 50;
    
      if (score >= 5) {
        if((xpos>=lx&&xpos<=rx)&&(ypos<=uy&&ypos>=ly) && keypress==balls[z].ballcol && bool[z] != false) {
          bool[z] = false;     
          score++;     
          ThreadThing tt = new ThreadThing(this);
          tt.start();
        }
      } else {
        if((xpos>=lx&&xpos<=rx)&&(ypos<=uy&&ypos>=ly)&& balls[z].ballcol == 'l' && bool[z] != false){
          bool[z] = false;
          score++;
          ThreadThing tt = new ThreadThing(this);
          tt.start();
        }
      }
      
  }
  
  
  
}
void keyPressed()
{
    switch (key) {
        case ('r'):
            keypress = 'r';
            break;
        case ('g'):
            keypress = 'g';
            break;
        case ('b'):
            keypress = 'b';
    } 
}



// multi thread our sound effect
public class ThreadThing implements Runnable {
  Thread thread;

  public ThreadThing(PApplet parent) {
    parent.registerDispose(this);
  }

  public void start() {
    thread = new Thread(this);
    thread.start();
  }

  public void run() {
    // do something threaded here
    soundCall(0);
  }

  public void stop() {
    thread = null;
  }

  // this will magically be called by the parent once the user hits stop
  // this functionality hasn't been tested heavily so if it doesn't work, file a bug
  public void dispose() {
    stop();
  }
} 




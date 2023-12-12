import processing.video.*;
import controlP5.*;

ControlP5 cp5;
ControlFont font;
PFont pfont;
PFont tfont;

Capture video;
PImage bg;
PImage display; 
color[][] video_color;
color[][] bg_color;
color[][] display_color;

int resolution = 4;
boolean start = false;
boolean captured = false;
boolean xLocked = false;
boolean yLocked = false;
boolean buttonPressed = false;
int threshold = 100;



Pixel[][] grid;
Pixel[][] prev;
int[] seedsX = {300,300};
int[] seedsY = {300,800};

float dA = 1;
float dB = 0.5;
float feed = 0.055;
float kill = 0.062;
color cLow = color(8,2,163);
color cMidL = color(255,75,145);
color cMidH = color(255,118,118);
color cHigh = color(255,205,75);


int row, col;
int seed_size = 1;
int alpha = 50;

void setup() {
  size(1780, 960);
  frameRate(240);
  colorMode(RGB, 255,255,255,100);
  noStroke();
  //String[] fontList = PFont.list();
  //printArray(fontList);
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, 1280, 960, cameras[0]);
  video.start();
  println(video.width, video.height);
  bg = createImage(1280, 960, RGB);
  display = createImage(1280, 960, RGB);
  
  // set the buttons
  cp5 = new ControlP5(this);
  font = new ControlFont(createFont("MS Gothic",24));
  pfont = createFont("MS Gothic", 24);
  tfont = createFont("Georgia", 40);
  

  cp5.addButton("Dot")
   .setPosition(1350,350)
   .setSize(150,45)
   .setFont(font)
   ;
  
  // default
  cp5.addButton("Curl")
   .setPosition(1350,400)
   .setSize(150,45)
   .setFont(font)
   ;
   
  cp5.addButton("Bulk")
   .setPosition(1350,450)
   .setSize(150,45)
   .setFont(font)
   ;
   
  cp5.addButton("Stripe")
   .setPosition(1350,500)
   .setSize(150,45)
   .setFont(font)
   ;
   
  // default
  cp5.addButton("Mushroom")
   .setPosition(1550,350)
   .setSize(150,45)
   .setFont(font)
   ;
   
  cp5.addButton("Snake")
   .setPosition(1550,400)
   .setSize(150,45)
   .setFont(font)
   ;
   
  cp5.addButton("Giraffe")
   .setPosition(1550,450)
   .setSize(150,45)
   .setFont(font)
   ;
   
  cp5.addButton("Coral")
   .setPosition(1550,500)
   .setSize(150,45)
   .setFont(font)
   ;
   
  cp5.addSlider("Feed")
   .setPosition(1350,620)
   .setSize(300,40)
   .setRange(0.01,0.1)
   .setDecimalPrecision(3) 
   .setValue(0.055)
   .setFont(font)
   ;
   
  cp5.addSlider("Kill")
   .setPosition(1350,670)
   .setSize(300,40)
   .setRange(0.045,0.07)
   .setDecimalPrecision(3) 
   .setValue(0.062)
   .setFont(font)
   ;
   
  cp5.addButton("Reset")
   .setPosition(1375,800)
   .setSize(300,45)
   .setFont(font)
   ;
   

  
  
  // initialize the 2D arrays
  row = floor( video.height / resolution);
  col = floor( video.width / resolution);
  grid = new Pixel[row][col];
  prev = new Pixel[row][col];
  video_color = new color[row][col];
  bg_color = new color[row][col];
  display_color = new color[row][col];
  for (int y = 0; y < row; y++) {
    for (int x = 0; x < col; x++) {
      grid[y][x] = new Pixel(x, y, 1, 0);
      prev[y][x] = new Pixel(x, y, 1, 0);
      video_color[y][x] = color(255,0);
      bg_color[y][x] = color(255,0);
      display_color[y][x] = color(255,0);
    }
  }

}



void draw() {
  background(0);
  fill(155,184,205);
  rect(video.width, 0, 500,video.height);
  fill(0);
  textSize(42);
  textFont(tfont);
  text("Morphing Nature", 1375,80);
  textFont(pfont);
  textSize(30);
  text("Presets", 1475,285);
  text("Customize", 1460,600);
  textSize(24);
  text("Patterns", 1375,330);
  text("Colors", 1585,330);
  textSize(20);
  text("Instructions:", 1348,130);
  text("MouseX corresponds to exposure.", 1350,160);
  text("MouseY corresponds to transparency.", 1350,180);
  text("Press 'x','y' to lock/unlock the values.", 1350,200);
  text("Press/Drag mouse to set pattern seeds.", 1350,220);


  // clear the edge
  for (int x = 0; x < col; x++) {
    grid[0][x].a = 0;
    grid[0][x].b = 0;
    grid[row-1][x].a = 0;
    grid[row-1][x].b = 0;
  }
  
  for (int y = 0; y < row; y++) {
    grid[y][0].a = 0;
    grid[y][0].b = 0;
    grid[y][col-1].a = 0;
    grid[y][col-1].b = 0;
  }


  //Calculate a/b density
  for (int y = 1; y < row-1; y++) {
    for (int x = 1; x < col-1; x++) {
      //feed = map(y, 1, row-1, 0.02, 0.065);
      float a = prev[y][x].a;
      float b = prev[y][x].b;
      grid[y][x].a = a +
        ((dA * laplaceA(x, y)) -
        (a * b * b) +
        (feed * (1 - a))) * 1;
      grid[y][x].b = b +
        ((dB * laplaceB(x, y)) +
        (a * b * b) -
        ((kill + feed) * b)) * 1;

      grid[y][x].a = constrain(grid[y][x].a, 0, 1);
      grid[y][x].b = constrain(grid[y][x].b, 0, 1);
    }
  }
 

  // capture video
  if (video.available() == true) {
    video.read();
  }
  //display.copy(video, 0, 0, video.video.width, video.video.height, 0, 0, bg.video.width, bg.video.height);
  video.loadPixels();
  display.loadPixels();
  
  // store the low-resolution data into 2d array
  for (int y = 0; y < row; y ++) {
    for (int x = 0; x < col; x ++) {
      int i = (y * resolution * col + x) * resolution;
      color c = video.pixels[i];
      video_color[y][col-1-x] = c;
    }
  }
  

  // compare the current video containing user with the plain background image
  if (captured == false) {
    fill(51);
    rect(0,0,video.width, video.height);
    textSize(24);
    fill(255);
    text("Awaits background image", 500,450);
    text("Press 'c' to capture", 500,480);
  } else {
    for (int y = 0; y < row; y++ ) {
      for (int x = 0; x < col; x++ ) {
        //int i = x + y * col;
        color currentColor = video_color[y][x];
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);
        color bgColor = bg_color[y][x];
        float r2 = red(bgColor);
        float g2 = green(bgColor);
        float b2 = blue(bgColor);
  
        float dsq = distSq(r1, g1, b1, r2, g2, b2);
        
        // display with reduced resolution
        int tsq = floor(threshold*threshold);
        if (dsq <= tsq) {
          fill(0);
          rect(x*resolution, y*resolution, resolution, resolution);
        } else {
          fill(r1,g1,b1);
          rect(x*resolution, y*resolution, resolution, resolution);
          // draw pattern
          float a = grid[y][x].a;
          float b = grid[y][x].b;
          int c = floor((a - b) * 255);
          c = constrain(c, 0, 255);
          //int red = floor(map(c,0,255,14,236));
          //int green = floor(map(c,0,255,33,83));
          //int blue = floor(map(c,0,255,160,192));
          if ( c > 200) {
            fill(cLow,alpha);
          } else if ( c > 150) {
            fill(cMidL,alpha);
          } else if ( c > 100) {
            fill(cMidH,alpha);
          } else {
            fill(cHigh, alpha);
          }
          rect(x*resolution, y*resolution, resolution, resolution);
        }
      }
    }
  }

  image(bg, 0, 0, 128, 96);
  image(video, 128, 0, 128, 96);
  
  
  // adjustable parameters
  if (mouseX > 0 && mouseX < video.width && mouseY > 0 && mouseY < video.height) {
    if (xLocked == false) {
      threshold = int(map(mouseX, 0, video.width, 0, 200));
    } else {
      fill(255);
      text("xLock", 1200,900);
    }
    if (yLocked == false) {
      alpha = floor(map(mouseY,video.height,0,0,100));
    } else {
      fill(255);
      text("yLock", 1200,930);
    }
  }
  
  prev = grid;
}

void mouseDragged() {
  if (mouseX > 2*resolution && mouseX < video.width-2*resolution && mouseY > 2*resolution && mouseY < video.height-2*resolution) {
    for (int j = floor(mouseY/resolution) - seed_size; j < floor(mouseY/resolution) + seed_size; j++) {
      for (int i = floor(mouseX/resolution) - seed_size; i < floor(mouseX/resolution) + seed_size; i++) {
        prev[j][i].b = 1;
        grid[j][i].b = 1;
      }
    }
  }
}

void mousePressed() {
  if (mouseX > 2*resolution && mouseX < video.width-2*resolution && mouseY > 2*resolution && mouseY < video.height-2*resolution) {
    for (int j = floor(mouseY/resolution) - seed_size; j < floor(mouseY/resolution) + seed_size; j++) {
      for (int i = floor(mouseX/resolution) - seed_size; i < floor(mouseX/resolution) + seed_size; i++) {
        prev[j][i].b = 1;
        grid[j][i].b = 1;
      }
    }
  }
}



void keyPressed() {
  if (key == 'x' || key == 'X') {
    xLocked = !xLocked;
  } else if (key == 'y' || key == 'Y') {
    yLocked = !yLocked;
  } else if (key == 'c' || key == 'C') {
    bg.copy(video, 0, 0, video.width, video.height, 0, 0, bg.width, bg.height);
    bg.updatePixels();
    for (int y = 0; y < row; y ++) {
      for (int x = 0; x < col; x ++) {
        bg_color[y][x] = video_color[y][x];
      }
    }
    captured = true;
  }
}


public void Dot() {
  kill = 0.062;
  feed = 0.03;
  
}

public void Curl() {
  kill = 0.062;
  feed = 0.055;
}

public void Bulk() {
  kill = 0.05184;
  feed = 0.11026;
}

public void Stripe() {
  kill = 0.06390;
  feed = 0.06495;
}

public void Mushroom() {
  cLow = color(8,2,163);
  cMidL = color(255,75,145);
  cMidH = color(255,118,118);
  cHigh = color(255,205,75);
}

public void Snake() {
  cLow = color(69,69,69);
  cMidL = color(255,96,0);
  cMidH = color(255,165,89);
  cHigh = color(255,230,199);
}

public void Giraffe() {
  cLow = color(245,204,160);
  cMidL = color(228,143,69);
  cMidH = color(153,77,28);
  cHigh = color(107,36,12);
}

public void Coral() {
  cLow = color(254,187,204);
  cMidL = color(255,204,204);
  cMidH = color(255,221,204);
  cHigh = color(255,238,204);
}

public void Feed(float fval) {
  feed = fval;
}

public void Kill(float kval) {
  kill = kval;
}

public void Reset() {
  for (int y = 0; y < row; y++) {
    for (int x = 0; x < col; x++) {
      grid[y][x].a = 1;
      grid[y][x].b = 0;
      prev[y][x].a = 1;
      prev[y][x].b = 0;
    }
  }
}






float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}


float laplaceA(int x, int y) {
  float sumA = 0;
  sumA += prev[y][x].a * -1;
  sumA += prev[y][x - 1].a * 0.2;
  sumA += prev[y][x + 1].a * 0.2;
  sumA += prev[y + 1][x].a * 0.2;
  sumA += prev[y - 1][x].a * 0.2;
  sumA += prev[y - 1][x - 1].a * 0.05;
  sumA += prev[y - 1][x + 1].a * 0.05;
  sumA += prev[y + 1][x + 1].a * 0.05;
  sumA += prev[y + 1][x - 1].a * 0.05;
  return sumA;
}

float laplaceB(int x, int y) {
  float sumB = 0;
  sumB += prev[y][x].b * -1;
  sumB += prev[y][x - 1].b * 0.2;
  sumB += prev[y][x + 1].b * 0.2;
  sumB += prev[y + 1][x].b * 0.2;
  sumB += prev[y - 1][x].b * 0.2;
  sumB += prev[y - 1][x - 1].b * 0.05;
  sumB += prev[y - 1][x + 1].b * 0.05;
  sumB += prev[y + 1][x + 1].b * 0.05;
  sumB += prev[y + 1][x - 1].b * 0.05;
  return sumB;
}
